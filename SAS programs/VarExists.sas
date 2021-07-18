/*=====================================================================
Program Name            : VAREXISTS.sas
Purpose                 : Check if a variable Exists in a SAS dataset.
SAS Version             : 9.4
Input Data              : N/A
Output Data             : N?A
Macros Called           : N/A
Originally Written by   : SUBHRO KAR
Date                    : 22JUL2020
Program Version #       : 1.0
=======================================================================
The %VAREXISTS macro uses Variable functions in a data step and to 
check if a variable exists in SAS and returns the variable info. It will 
return attributes of the variable when appropriate parameters are passed 
in the INFO parameter. 

If no value is passed, it returns the column position of the variable by 
default.

Subhro Kar(subhro@9to5sas.com)
For SAS tutorials, please refer to https://www.9to5sas.com/.
=======================================================================
Modification History    : Original version
Programmer              : SUBHRO KAR
Date                    : 22JUL2020
---------------------------------------------------------------------*/

options symbolgen mprint mlogic;
%macro varexist(data,var,info);
%local macro parmerr dsis rc varnum;
%let macro = &sysmacroname;
%let dsid = %sysfunc(open(&data));
 
%if (&dsid) %then %do;
   %let varnum = %sysfunc(varnum(&dsid,&var));
 
   %if (&varnum) %then %do;
      %if (%length(&info)) %then %do;
         %if (&info eq NUM) %then %do;
&varnum
         %end;
         %else %do;
%sysfunc(var&info(&dsid,&varnum))
         %end;
      %end;
      %else %do;
&varnum
      %end;
   %end;
 
   %else 0;
 
   %let rc = %sysfunc(close(&dsid));
%end;
 
%else 0;
%mend;
 
/******* END OF FILE *******/
%put EXISTS:   %varexist(sashelp.class,age);        /* EXISTS: 3 */
%put VARNUM:   %varexist(sashelp.class,age,num);    /* VARNUM: 0 */
%put LENGTH:   %varexist(sashelp.class,age,len);    /* LENGTH: 8 */ 
%put FORMAT:   %varexist(sashelp.air,date,fmt);     /* FORMAT: MONYY.*/
%put INFORMAT: %varexist(sashelp.class,age,infmt);  /* INFORMAT: */
%put LABEL:    %varexist(sashelp.class,age,label);  /* LABEL: */
%put TYPE:     %varexist(sashelp.class,age,type);   /* TYPE: N */
