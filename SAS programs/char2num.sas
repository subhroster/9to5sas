data class;
	input name $ marks1 $ marks2 $ marks3 $;
	datalines;
Alfred 50 61 91                                    
Alice 35 82 82                                         
Barbara 75 63 73                                        
;
run;

proc sql noprint;
	select count(name) into :cnt from dictionary.columns where 
		libname=upcase("WORK") and memname=upcase("CLASS") and type="char";
quit;

%put &cnt.;

data _null_;
	set class end=lastobs;
	ARRAY VARS [*] _CHARACTER_;
	ARRAY flag{&cnt} _temporary_;

	DO M=1 TO DIM(VARS);
		flag[m]=ifn ((input(vars[m], ?? 3.) eq .), 0, 1);
	END;

	if lastobs then
		do;
			length varlist $ 32767;

			do j=1 to &cnt;

				if flag{j} then
					varlist=catx(' ', varlist, vname(vars{j}));
			end;
			call symputx('varlist', varlist);
		end;
run;

%put &varlist;
%let nvars=%sysfunc(countw(&varlist));
%put &nvars;
data class2;
	set class;
	array charx{&nvars} &varlist;
	array x{&nvars};

	do i=1 to &nvars;
		x{i}=input(charx{i}, 3.);
	end;

	do i=1 to &nvars;
		drop &varlist i;
		%renamer;
	end;
run;

%macro renamer;
	%do i=1 %to &nvars;
		rename x&i=%scan(&varlist, &i);
	%end;
%mend renamer;
