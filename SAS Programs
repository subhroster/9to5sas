proc export data=sashelp.class 
		outfile='/home/9to5sas/inputs/one.xlsx' dbms=xlsx replace;
run;
proc export data=sashelp.class 
		outfile='/home/9to5sas/inputs/two.xlsx' dbms=xlsx replace;
run;
proc export data=sashelp.class 
		outfile='/home/9to5sas/inputs/three.xlsx' dbms=xlsx replace;
run;

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
