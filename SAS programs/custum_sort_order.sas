
proc format;
	value $delayfmt 'No Delay'=1 '1-10 Minutes'=2 '11+ Minutes'=3;
run;

proc sql;
	select * from flightdelays order by put(delaycategory, $delayfmt.);
quit;

data flightdelays2;
	set flightdelays;
	neworder=put(delaycategory, delayfmt.);
run;

proc sort data=flightdelays2;
	by neworder;
	quit;

proc sql;
	select * from flightdelays order by case when delaycategory='No Delay' then 1 
		when delaycategory='1-10 Minutes' then 2 when delaycategory='11+ Minutes' 
		then 3 end;
quit;

