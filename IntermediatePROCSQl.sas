/*Count */
proc sql;
	select count(*) as row_count from sashelp.shoes;
quit;

proc sql;
	select count(product) as non_missing_row_count from sashelp.shoes;
quit;

/* Summarizing Data Down Rows */

proc sql;
	select avg(sales) as average_sales format=dollar10.2 from sashelp.shoes where 
		upcase(product) in ("SPORT SHOE");
quit;
/* Summarizing data across columns */
proc sql;
	select product, stores, inventory, (stores/inventory) as average_price 
		format=dollar8.5 from sashelp.shoes;
quit;

/* selecting a range of values */
proc sql outobs=5;
	select * from sashelp.shoes where upcase(product)='SANDAL';
quit;

/* Testing for null or missing values */
data shoes;
	set sashelp.shoes;

	if _n_ in (4, 7, 8, 9) then
		call missing(subsidiary);
run;

proc sql;
	select * from shoes where subsidiary is null;
quit;

/* finding patterns in a string (pattern matching % and _) */
proc sql outobs=5;
	select * from sashelp.shoes where product like 'Men%';
quit;

proc sql outobs=5;
	select * from sashelp.shoes where upcase(product) like '%DRESS%';
quit;

proc sql outobs=5;
	select * from sashelp.shoes where upcase(product) like 'S______';
quit;

proc sql outobs=5;
	select * from sashelp.shoes where product like '_o%';
quit;

*/ testing for the existence of a value */
proc sql;
select custnum, custname, custcity from sql2.customers c where exists
(select * from sql2.purchases p where c.custnum=p.custnum);
quit;
