/*****************************************************************************************************************
SAS file name: update-sas-datasets
Purpose: To demonstrate the UPDATE statement in the SAS data step.
Author: Subhro Kar
Creation Date: 09/01/2022
Program Version : 1.0
_________________________________________________________________________________________________________________
This program supports the examples for "An exhortation to Merge? Isn’t It Time to UPDATE?" on 9to5sas.com
For more information, please refer to https://www.9to5sas.com/sas-update-statement/.
=======================================================================
Modification History : Original version
=======================================================================
 *****************************************************************************************************************/
libname sql '/home/subhroster20070/Datasets/sql';
libname cert '/home/subhroster20070/Datasets/cert';
/*A Basic Update Example*/

/*Transaction dataset */

option yearcutoff=1930;

data paylist_update;
	input IdNum $ gender $ Jobcode $ Salary Birth hired;
	informat birth hired date7.;
	format birth hired date7.;
	datalines;
1401 M TA3 38822 13DEC55 17NOV93
1919 M TA2 34376 12SEP66 04JUN87
2021 F TA3 35000 01MAY89 01JAN22
;
run;

proc sort data=sql.paylist2;
	by idnum;
run;

proc sort data=paylist_update;
	by idnum;
run;

data Paylist_new;
	update sql.paylist2 paylist_update;
	by idnum;
run;

/* Updating By Renaming Variables */
/*Transaction Data Set*/

data health_update;
	input IdNum weight;
	datalines;
7258 195
6726 130
1025 150
;
run;

/* Sort both data sets by IDNum */
proc sort data=health_update;
	by idnum;
	quit;

proc sort data=cert.health;
	by idnum;
	quit;

	/* Update Master with Transaction */
data health_new;
	length STATUS $11;
	update cert.health(rename=(weight=Original) in=a) health_update(in=b);
	by idnum;

	if a and b then
		do;
			Change=abs(Original - weight);

			if weight<Original then
				status='Reduced';
			else if weight>Original then
				status='Increased';
			else
				status='Same';
		end;
	else
		do;
			status='No Updates';
			weight=original;
		end;
run;


/* Updating with Missing Values */


data paylist_update;
	input IdNum $ gender $ Jobcode $ Salary Birth hired;
	informat birth hired date7.;
	format birth hired date7.;
	missing A _;
	datalines;
1401 M TA3 . 13DEC55 17NOV93
1919 M TA2 . 12SEP66 04JUN87
1350 F FA3 33000 31AUG55 29JUL91
;
run;

/*Missing values*/
data paylist_update;
	input IdNum $ gender $ Jobcode $ Salary Birth hired;
	informat birth hired date7.;
	format birth hired date7.;
	datalines;
1401 M TA3 . 13DEC55 17NOV93
1919 M TA2 . 12SEP66 04JUN87
1350 F FA3 33000 31AUG55 29JUL91
1499 M . 23025 26APR74 07JUN92
;
run;

proc sort data=paylist_update;
	by idnum;
run;

data Paylist_new;
	update sql.paylist2 paylist_update updatemode=nomissingcheck;
	by idnum;
run;

/*Special Missing Values*/

data paylist_update;
	input IdNum $ gender $ Jobcode $ Salary Birth hired;
	informat birth hired date7.;
	format birth hired date7.;
	missing Z;
	datalines;
1401 M TA3 . 13DEC55 17NOV93
1919 M TA2 Z 12SEP66 04JUN87
1350 F FA3 33000 31AUG55 29JUL91
1499 M Z 23025 26APR74 07JUN92
;
run;

proc sort data=paylist_update;
	by idnum;
run;

data Paylist_new;
	update sql.paylist2 paylist_update;
	by idnum;
run;

/*Undesrcore missing values*/
data paylist_update;
	input IdNum $ gender $ Jobcode $ Salary Birth hired;
	informat birth hired date7.;
	format birth hired date7.;
	missing _;
	datalines;
1401 M TA3 _ 13DEC55 17NOV93
1919 M TA2 _ 12SEP66 04JUN87
1350 F FA3 33000 31AUG55 29JUL91
1499 M _ 23025 26APR74 07JUN92
;
run;

proc sort data=paylist_update;
	by idnum;
run;

data Paylist_new;
	update sql.paylist2 paylist_update;
	by idnum;
run;

data paylist_update;
	input IdNum $ gender $ Jobcode $ Salary Birth hired;
	informat birth hired date7.;
	format birth hired date7.;
	missing A _;
	datalines;
1401 M TA3 . 13DEC55 17NOV93
1919 M TA2 _ 12SEP66 04JUN87
1350 F FA3 A 31AUG55 29JUL91
1499 F _ 23025 26APR74 07JUN92
	
;
run;
/******* END OF FILE *******/
