
%include "/home/9to5sas/Sharepoint/token.sas";
 %TOKEN_REFRESH;

* Temporary file for http output *; 
filename resp TEMP; 
%let hostname = 9to5sas.sharepoint.com;
%let sitepath = /sites/9to5sas;
proc http url="https://graph.microsoft.com/v1.0/sites/&hostname.:&sitepath.:/drive"
     oauth_bearer="&access_token"
     out = resp;
	 run;
* JSON libname to access JSON structure response content *; 
libname jresp json fileref=resp;

/*proc datasets lib=jresp; quit;*/
title 'Top-level drive identifier (SharePoint Online)';
proc print data=jresp.root;
run;
title;
/*
 This creates a data set with the one record for the drive.
 Need this object to get the Drive ID
*/

data drive;
 set jresp.root;
run;

/* store the ID value for the drive in a macro variable */
proc sql noprint;
 select id into: driveId from drive;
quit;

/*** LIST TOP LEVEL FOLDERS/FILES ****/

/*
 To list the items in the drive, use the /children verb with the drive ID
*/
* Temporary file for http output *; 
filename resp TEMP; 
proc http url="https://graph.microsoft.com/v1.0/me/drives/&driveId./items/root/children"
     oauth_bearer="&access_token"
     out = resp;
	 run;
%echofile(resp);

libname jresp json fileref=resp;
proc datasets lib=jresp; quit;

title 'LIST OF TOP LEVEL FOLDERS/FILES';
proc print data=jresp.value(obs=5);
var createdDateTime id lastModifiedDateTime	name webURL size;
run;
title;
/* Create a data set with the top-level paths/files in the drive */
data paths;
 set jresp.value;
run;

/*** LIST OF FILES IN A PARTICULAR FOLDER ****/
/* Find the ID of the folder you want */
proc sql;
 select name,id,webURL into :name,:folderId,:webURL from paths
  where upcase(name)="SAS";
quit;
* Temporary file for http output *; 
filename resp TEMP; 
proc http url="https://graph.microsoft.com/v1.0/me/drives/&driveId./items/&folderId./children"
     oauth_bearer="&access_token"
     out = resp;
	 run;

%echofile(resp);
libname jresp json fileref=resp;
/*proc datasets lib=jresp; quit; */
data folderItems;
 set jresp.value;
run;
title 'FOLDER ITEMS';
proc print data=jresp.value(obs=5);
var createdDateTime id lastModifiedDateTime	name webURL size;
run;
title;

/**** READ FROM SHAREPOINT***/
/* Find the ID of the folder you want */
proc sql no print;
 select id into: fileId from folderItems
  where name="iris.xlsx";
quit;

*	https://9to5sas.sharepoint.com/sites/9to5sas/Shared%20Documents/sas;
*proc http url="https://graph.microsoft.com/v1.0/me/drives/&driveId./items/iris.xlsx/content";

filename fileout "%sysfunc(getoption(WORK))/iris.xlsx";
proc http url="https://graph.microsoft.com/v1.0/me/drives/&driveId./items/&fileId./content"
     oauth_bearer="&access_token"
     out = fileout;
     debug level = 2;
	 run;
%echofile(fileout);

proc import file=fileout 
 out=iris
 dbms=xlsx replace;
run;

/*** WRITE TO SHAREPOINT ****/
proc sql;
 select name,id,webURL into :name,:folderId,:webURL from paths
  where upcase(name)="SAS";
quit;
 
/* Create a simple Excel file to upload */
%let targetFile=class.xlsx;
filename tosave "%sysfunc(getoption(WORK))/&targetFile.";
ods excel(id=upload) file=tosave;
ods exclude all;
proc print data=sashelp.class;
run;
ods exclude none;
ods excel(id=upload) close;
 
filename details temp;
proc http url="https://graph.microsoft.com/v1.0/me/drives/&driveId./items/&folderId.:/&targetFile.:/content"
  method="PUT"
  in=tosave
  out=details
  oauth_bearer="&access_token";
run;
 %echofile(details);
/*
  This returns a json response that describes the item uploaded.
  This step pulls out the main file attributes from that response.
*/
libname attrs json fileref=details;
data newfileDetails(keep=filename createdDate modifiedDate filesize);
 length filename $ 100 createdDate 8 modifiedDate 8 filesize 8;
 set attrs.root;
 filename = name;
 modifiedDate = input(lastModifiedDateTime,anydtdtm.);
 createdDate  = input(createdDateTime,anydtdtm.);
 format createdDate datetime20. modifiedDate datetime20.;
 filesize = size;
run;

proc print;

/*** SAVE SAS DATASET TO SHAREPOINT ****/
proc sql;
 select name,id,webURL into :name,:folderId,:webURL from paths
  where upcase(name)="DATASETS";
quit;


/*Get the physical path of a library using PATHNAME function*/
%LET LOC = %SYSFUNC(PATHNAME(SASDSN)); 
%PUT &LOC.;

%let targetFile=cars.sas7bdat;

filename filein "&loc./&targetFile.";
                                                                                                                       
 /* Note: %if/%then in open code supported in 9.4m5 */
%if (%sysfunc(fileref(filein)) ne 0) %then %do;
%put %sysfunc(sysmsg());
%end;

filename details temp;
proc http url="https://graph.microsoft.com/v1.0/me/drives/&driveId./items/&folderId.:/&targetFile.:/content"
  method="PUT"
  in=filein
  out=details
  oauth_bearer="&access_token";
run;


libname attrs json fileref=details;

data fileDetails(keep=filename createdDate modifiedDate filesize);
 length filename $ 100 createdDate 8 modifiedDate 8 filesize 8;
 set attrs.root;
 filename = name;
 modifiedDate = input(lastModifiedDateTime,anydtdtm.);
 createdDate  = input(createdDateTime,anydtdtm.);
 format createdDate datetime20. modifiedDate datetime20.;
 filesize = size;
run;
proc print;