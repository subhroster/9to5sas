/*Copy Specified SAS Data Set or Copying an Entire Library */
proc copy in=sashelp out=work memtype=data;
	select cars;
run;

proc datasets nolist;
	copy out=work memtype=data;
	run;
quit;

proc datasets library=sashelp nowarn;
   copy out=work;
run;

/*Copy All SAS Data Sets */
proc copy in=sashelp out=work memtype=data;
run;

/*Move Specified Data Set */
proc datasets nolist;
	copy in=work out=sasdsn memtype=data move;
	select cars;
	run;
quit;

/*Move All Data Sets */
proc datasets nolist;
	copy in=work out=sasdsn memtype=data move;
	run;
quit;

/*Exclude datasets from Copy*/
proc copy in=sashelp out=work memtype=data;
	exclude cars;
run;
/*Exclude datasets from move*/
proc datasets nolist;
	copy in=work out=sasdsn memtype=data move;
	exclude cars;
	run;
quit;

