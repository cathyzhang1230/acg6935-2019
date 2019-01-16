
rsubmit;
libname myfiles "~"; 

/* get only data for firms that are in a_funda -- this is an example of inner join */
proc sql;
	create table myfiles.b_fundq as

	select key, std(roa) as std_roa from
	 	(
		select a.key, b.niq / b.atq as roa 
		from myfiles.a_funda a, comp.fundq b
		where
			a.gvkey = b.gvkey 
		and a.fyear -4 <= b.fyearq <= a.fyear
		)
	group by key
	having count(*) >= 12
;
quit;

proc download data=myfiles.b_fundq out=b_fundq;run;
endrsubmit;
