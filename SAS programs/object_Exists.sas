options mprint symbolgen mlogic;

/* Verifying the Existence of a Data Set */
%let dsname=sashelp.classs;

%macro dsnexits(name);
	%if %sysfunc(exist(&name, DATA)) %then
		%put NOTE: Data set &name exist.;
	%else
		%put %sysfunc(sysmsg());
%mend dsnexits;

%dsnexits(&dsname);

/* Verifying the Existence of a Data View */

%let view=sashelp.vformat;

%macro viewexits(name);
	%if %sysfunc(exist(&name, VIEW)) %then
		%put NOTE: &name exist.;
	%else
		%put %sysfunc(sysmsg());
%mend viewexits;

%viewexits(&view);

/*variable exists*/
%macro VarExist(ds, var);
	%if %sysfunc(exist(&ds, DATA)) %then
		%do;
			%let dsid = %sysfunc(open(&ds));

			%if %sysfunc(varnum(&dsid, &var)) > 0 %then
				%put NOTE: Var &var exists in &ds;
			%else
				%put %sysfunc(sysmsg());
			%let rc = %sysfunc(close(&dsid));
		%end;
	%else
		%put %sysfunc(sysmsg());
%mend VarExist;

%VarExist(sashelp.class, name);

/*File exists*/
%let fpath=/home/subhroster20070/SAS Programs/Multiple_excel_files.sas;

%macro fileexists(filepath);
	%if %sysfunc(fileexist(&filepath)) %then
		%put NOTE: The external file &filepath exists.;
	%else
		%put %sysfunc(sysmsg());
%mend fileexists;

%fileexists(&fpath);

/* File reference exists */
filename mytest '/home/subhroster20070/SAS Programs/Multiple_excel_files.sas';
%let fref=mytest;

%macro filerefexists(fref);
	%if %sysfunc(fexist(&fref)) %then
		%put NOTE: The external file &fref exists.;
	%else
		%put %sysfunc(sysmsg());
%mend filerefexists;

%filerefexists(&fref);

/*Libref*/
%macro libexits(libref);
	%if %sysfunc(libref(&libref)) %then
		%put %sysfunc(sysmsg());
	%else
		%put NOTE: &libref exists;
%mend libexits;

%libexits(sashelp);

/*Check if a Format or Informat exits*/
proc sql;
	create table test as select libname, fmtname, source, fmttype from 
		dictionary.formats where source='B' or source='C';
quit;

/*SASHELP.VFORMAT conatins SAS supplied formats*/
data SASFmts;
	set sashelp.vcformat(keep=libname fmtname source fmttype);
	where source='B';
run;

/*SASHELP.VCFORMAT nconatins user defined formats*/
/*A user defined format*/
proc format;
	value $genderFmt 'M'='Male' 'F'='Female' Other='Error';
run;

data CFmts;
	set sashelp.vcformat;
run;

/*Macro exits*/

%put %nrstr(%sysmacexist(test))=%sysmacexist(test);

%macro test;
	%put this is a macro;
%mend;

%put %nrstr(%sysmacexist(test))=%sysmacexist(test);
%test;
%put %nrstr(%sysmacexist(test))=%sysmacexist(test);

/*Macro variable exists*/
%let x=gloablvar;

%macro test;
	%let y=localvar;
	%put %nrstr(%symglobl(x))= %symglobl(x);
	%put %nrstr(%symexist(x))= %symexist(x);
	%put %nrstr(%symexist(y))= %symexist(x);
	%put %nrstr(%symexist(z))= %symexist(z);
%mend test;

%test;
