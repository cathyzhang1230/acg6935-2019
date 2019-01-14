/*
	Monday - lab session to discuss assignment 1
*/
* filter;



* all gvkeys where someVar eq 0;
data test_zero (keep = gvkey);
set mycomp;
if someVar eq 0;
run;

/* unique gvkeys */
proc sort data = test_zero nodupkey; by gvkey;run;

/* keep everything where it is not 0 */
data test_not_zero ;
set mycomp;
if someVar ne 0;
run;


libname a "C:\temp4\somefolder";



* alternative sql;

proc sql;
	create table test as select * from mycomp where
		gvkey in (
			select distinct gvkey from mycomp where someVar eq 0
		);
quit;


data a.test;
x = 1;
output; output;
x = 2;
run;

data a.test;
x = 1;
output; output;
x = 2;
output;
run;

data a.funda ; 
set work.a_funda; run;


data total;
set mycomp;
by gvkey;
retain sumsale;
if first.gvkey then sumsale = 0;
sumsale = sumsale + sale;
if first.gvkey then do;
	output;output;
end;
if last.gvkey then output;
run;


data somedata;
  input @01 id        1.
        @03 year2010  4.
		@08 year2011  4.
        @13 year2012  4.
		@18 year2013  4.
	;
datalines;
1 1870 1242 2022 1325
2 9822 3186 1505 8212
3      1221 4321 9120
4 4701 2323 3784
run;


data test;
set somedata;
value = year2010; year = 2010; output;
value = year2011; year = 2011; output;
value = year2012; year = 2012; output;
value = year2013; year = 2013; output;
run;

/*
4. Header variables
Some variables in Funda are 'header' (that means, all firms' rows get updated if the value changes).
Verify if the variables 'CIK' (central index key) and 'conm' (Company name) change over the fyears or not 
(if it doesn't change, it means it is a header variable).
*/

rsubmit;
endrsubmit;
%let wrds = wrds-cloud.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;
signon username=_prompt_;

rsubmit;
data myComp4 (keep = gvkey fyear datadate cik conm ni at sale ceq prcc_f csho sich);
set comp.funda;
if cmiss (of at sale ceq ni) eq 0;
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
run;
proc download data=myComp4 out=myComp4;run;
endrsubmit;

proc sort data=mycomp4; by gvkey; run;

data header (keep = gvkey fyear cik conm cik_prev conm_prev fyear_check cik_check conm_check);
set myComp4;
by gvkey;
retain cik_prev conm_prev;
if first.gvkey then do;
	cik_prev = cik;
	conm_prev = conm;
end;
if cik_prev ne cik or conm_prev ne conm then output;
run;


data header_check (keep = gvkey fyear cik conm cik_prev conm_prev fyear_check cik_check conm_check cik_fyear conm_fyear);
set header;
retain cik_fyear conm_fyear;
cik_fyear = 0;
conm_fyear = 0;
cik_fyear = cik_fyear + (cik_check ^= fyear_check);
conm_fyear = conm_fyear + (conm_check ^= fyear_check);
run;
 
/*Since both cik_fyear and conm_fyear are zero for all gvkeys, we can say that they are headers.*/


data seminar.q3; set comp.funda (keep=gvkey prcc_f fyear); run;
proc sort data=seminar.q3 nodupkey; by gvkey fyear; run;

data seminar.q3a; set seminar.q3;
by gvkey; retain first_missing;
if (first.gvkey) then do;
  if (prcc_f eq .) then do;
    first_missing=fyear;
  end;
end;
run;

data seminar.q3a; set seminar.q3;
by gvkey; retain missing_count flag;
if first.gvkey then do; 
	missing_count = 0;
	flag = 0;
end;
/* missing (and always been missing) */
if missing(prcc_f) eq 1 and flag eq 0 then missing_count = missing_count + 1;
if missing(prcc_f) eq 0 then flag = 1;
run;


rsubmit;

data myComp (keep = gvkey fyear prcc_f );
set comp.funda;
if 2001 <=fyear <= 2015;
/* prevent double records */
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
run;
proc download data=myComp out=myComp;run;
endrsubmit;

data mycomp_2; set mycomp;
by gvkey; retain first_missing;
if first.gvkey then first_missing = .;

if first.gvkey and missing(prcc_f) eq 1 then do;
  first_missing=fyear;
end;
run;

/* get the first record where prcc_f is not missing */
data mycomp_3; set mycomp_2; where prcc_f ne .; run;
proc sort data=mycomp_3; by gvkey fyear; run;
proc sort data=mycomp_3 nodupkey; by gvkey; run;

data mycomp_4; set mycomp_3;
pre_ipo_datapoints=fyear-first_missing; run;
