/*=====================================================================
Program Name            : MULTI_IMPORT.sas
Purpose                 : To Create a single SAS dataset by importing 
			  multiple excel files from a directory
SAS Version             : 9.4
Input Data              : N/A
Output Data             : MERGED

Macros Called           : N/A

Originally Written by   : SUBHRO KAR
Date                    : 17JUL2021
Program Version #       : 1.0

=======================================================================

This code is used to import multiple excel files with the same variable 
names from a folder and then merge data from all the data sets to a 
single data set.

Subhro Kar(subhro@9to5sas.com)

For SAS tutorials, please refer to https://www.9to5sas.com/.

=======================================================================

Modification History    : Original version

Programmer              : SUBHRO KAR
Date                    : 17JUL2021
---------------------------------------------------------------------*/

/*Creating sample Excel files*/
proc export data=sashelp.class 
		outfile='/home/9to5sas/inputs/one.xlsx' dbms=xlsx replace;
run;
proc export data=sashelp.class 
		outfile='/home/9to5sas/inputs/two.xlsx' dbms=xlsx replace;
run;
proc export data=sashelp.class 
		outfile='/home/9to5sas/inputs/three.xlsx' dbms=xlsx replace;
run;

/*Datastep Method*/
/*to get the list of all file names in a folder*/
filename indata '/home/9to5sas/inputs/*.xlsx';

data path_list_files;
	length fpath sas_data_set_and_path $100;
	retain fpath;
	infile indata truncover filename=sas_data_set_and_path;
	input;

	if fpath ne sas_data_set_and_path then
		do;
			fpath=sas_data_set_and_path;
			sysrc=filename('fnames', quote(trim(fpath)));

			if sysrc ne 0 then
				do;
					er1=sysmsg();
					error 'filename failed: ' er1;
					stop;
				end;
			call execute('
proc import dbms=xlsx out=_test
 datafile= fnames replace;
run;
proc append data=_test base=_test force; run;
');
			output;
		end;
	filename fnames clear;
	drop er1 sysrc;
run;

/*Macro Method*/

%macro multimp(dir=, out=);
	%let rc=%str(%"ls &dir.%");
	%put &rc.;
	filename myfiles pipe %unquote(&rc);
	%put path=%sysfunc(pathname(myfiles));

	data list;
		length fname $256.;
		infile myfiles truncover;
		input myfiles $100.;
		fname=quote(cats("&dir", myfiles));
		out="&out";
		call execute('
  proc import dbms=xlsx out= _test
            datafile= '||fname||' replace ;
  run;
  proc append data=_test base='||out||' force; run;
  *proc delete data=_test; run;
');
	run;

	filename myfiles clear;
%mend;

%multimp(dir=/home/subhroster20070/examples/region/, out=merged);

/******* END OF FILE *******/
