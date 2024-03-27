proc Print data=sql.employees;
	title;

	/*Using the SUM Function in PROC SQL*/
Proc SQl;
	select sum(salary) as Tot_Salary from sql.employees;
quit;

proc Summary data=sql.employees sum print;
	var salary;
	output out=Tot_Sal SUM(Salary)=Tot_Salary;
run;

proc Summary data=sashelp.class;
	var age height;
	output out=Tot_Sal SUM(age)=sum_age mean(height)=Avg_height;
run;

proc Means data=sql.employees sum;
run;

proc Univariate data=sql.employees;
	var salary;
run;

proc Univariate data=sql.employees;
	var salary;
	output out=tot_salary
		sum=Sum_salary;
run;
data sum_ex;
	set sql.employees;
	retain Sum_Salary;
	Sum_Salary = sum(Sum_Salary, salary);
run;

data sum_ex2;
	set sql.employees;
	sum_salary+salary;
run;

proc print data=sql.employees noobs;
sum Salary;
run;

proc tabulate data=sql.employees;
 Title 'Sum of Salaries';
 var salary ;
 table salary;
run;
Proc Report data=sql.employees;
 column fname salary;
 define fname /display;
 define salary /analysis sum;
 rbreak after /summarize;  
 compute after ;
 fname="total";
 endcomp;
run;

Proc Report data=sql.employees;
 column Salary;
 define Salary /analysis sum;
run;

/*Proc Univariate*/

proc univariate data=sql.employees novarcontents;
var salary;
run;
