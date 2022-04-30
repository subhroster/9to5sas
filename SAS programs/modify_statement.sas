/*****************************************************************************************************************
SAS file name: modify_statement
Purpose: To demonstrate the MODIFY statement in the SAS data step.
Author: Subhro Kar
Creation Date: 04/30/2022
Program Version : 1.0
_________________________________________________________________________________________________________________
This program supports the examples for "Modifying SAS Dataset using SAS Modify Statement" on 9to5sas.com
For more information, please refer to https://www.9to5sas.com/sas-modify-statement/.
=======================================================================
Modification History : Original version
=======================================================================
 *****************************************************************************************************************/
libname sql '/home/subhroster20070/Datasets/sql';
libname cert '/home/subhroster20070/Datasets/cert';

proc copy in=sql out=work memtype=data noclone datecopy;
	select payroll2;
run;

proc copy in=cert out=work memtype=data noclone datecopy;
	select donors;
run;

proc copy in=sql out=work memtype=data noclone datecopy;
	select paylist2;
run;

/* Modifying All Observations in a SAS Data Set */

data payroll2;
	modify payroll2;
	jobcode="SCP";
run;

/* Modifying Observations Using a Transaction Data Set */
data payroll_update;
	input IdNum $ Jobcode $;
	datalines;
1639 SCP
1221 SCP
1350 PT1
;
run;

data payroll2;
	modify payroll2 payroll_update;
	by IdNum;
run;

/*When match is not found*/
data payroll_update;
	input IdNum $ Jobcode $;
	datalines;
1639 SCP
1221 SCP
1350 PT1
1499 PT1
;
run;

data payroll2;
	modify payroll2 payroll_update;
	by IdNum;

	if _iorc_=0 then
		replace;
run;

proc print data=payroll2;
run;

/*Handling Missing Values*/
data payroll_update;
	input IdNum $ gender $ Jobcode $ Salary Birth hired;
	informat birth hired date7.;
	format birth hired date7.;
	datalines;
1639 M TA3 . 13DEC55 17NOV93
1221 M TA2 . 12SEP66 04JUN87
1350 F FA3 33000 31AUG55 29JUL91
;
run;

proc sort data=payroll_update;
	by idnum;
run;

data payroll2;
	modify payroll2 payroll_update updatemode=nomissingcheck;
	by idnum;
run;

/*Modifying Observations Located by Observation Number*/
data payroll_update;
	input obs newJobcode $;
	datalines;
1 SCP
2 SCP
3 PT1
;
run;

data paylist2;
	set payroll_update;
	modify paylist2 point=obs nobs=max_obs;

	if _error_=1 then
		do;
			put 'ERROR occurred for TOOL_OBS=' obs / 'during DATA step iteration' _n_ / 
				'OBS value might be out of range.';
			_error_=0;
			stop;
		end;
	jobcode=newJobcode;
run;

/*Modifying Observations Located by an Index*/

	/*Creating index*/
proc datasets library=work;
	modify payroll2;
	index create idnum / unique;
	run;

data payroll_update;
	input IdNum $ newJobcode $;
	datalines;
1639 SCP
1221 SCP
1350 PT1
;
run;

data payroll2;
	set payroll_update;
	modify payroll2 key=idnum;
	jobcode=newJobcode;
run;

/*Controlling the Update Process*/

DATA DONORS_UPDATE;
	INPUT ID UNITS_UPDATE;
	DATALINES;
1129 48	
1129 50	
1129 57	
2304 16
2486 63	
;
RUN;

proc datasets library=work;
	modify donors;
	index create id;
	run;

data donors;
	set DONORS_UPDATE;
	modify donors key=id;
	units=UNITS_UPDATE+5;

	if type='B' then
		remove;
	else if type='A' then
		replace;
	else if type='O' then
		output;
RUN;


/* Using IORC with %SYSRC */
DATA DONORS_UPDATE;
	INPUT ID UNITS_UPDATE;
	DATALINES;
1129 52	
2904 24	
;
RUN;

proc datasets library=work;
	modify donors;
	index create id;
	run;

data donors;
	set DONORS_UPDATE;
	modify donors key=id;

	if _IORC_=%sysrc(_sok) then
		do;
			units=UNITS_UPDATE;
			replace;
		end;
	else if _IORC_=%sysrc(_dsenom) then
		do;
			units=UNITS_UPDATE;
			output;
			_ERROR_=0;
		end;
run;
