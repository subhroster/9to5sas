data hearts;
	set sashelp.heart;
run;

proc format;
	value $missfmt ' '='Missing Values' other='Non-Missing';
	value missfmt .='Missing Values' other='Non-Missing';
run;

%macro varCounts (dsn=);
	%let dsid=%sysfunc(open(&dsn));
	%let cntvar=%sysfunc(attrn(&dsid, nvars));
	%put &dsid;
	%put &cntvar;

	proc contents data=&dsn varnum out=var(keep=name type) noprint;
	run;

	proc print data=var;
	data _null_;
		set var;
		suffix=put(_n_, 5.);
		call symputx(cats('Name', suffix), Name);
		call symputx(cats('Type', suffix), Type);
	run;

	%do i=1 %to &cntvar;

		proc freq data=&dsn noprint;
			tables &&name&i /missing nopercent nocum nofreq nopercent 
				out=out&i(drop=percent rename=(&&name&i=value));
			format &&name&i 
			%if &&type&i=2 %then
				%do;
					$missfmt. %end;
			%else
				%do;
					missfmt. %end;
			;
		run;

		data out&i;
			set out&i;
			varname="&&name&i";

			%if &&type&i=1 %then
				%do;
					value1=put(value, missfmt.);
				%end;
			%else %if &&type&i=2 %then
				%do;
					value1=put(value, $missfmt.);
				%end;
			drop value;
			rename value1=value;
		run;

	%end;

	data final;
		set %do i=1 %to &cntvar;
			out&i %end;
		;
	run;

	proc transpose data=final2 out=combine(drop=_:);
		by varname;
		id value;
		var count;
	run;

	proc print data=combine;
	%mend;

	%varCounts(dsn=hearts);
	
	proc print data=final2;
	