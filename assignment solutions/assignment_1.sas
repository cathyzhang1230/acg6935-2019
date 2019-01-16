/*
	Assignment 1 solutions

	Note: different approaches are possible for many of the problems
*/

/* dataset to work with */
%let wrds = wrds-cloud.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;
signon username=_prompt_;

rsubmit;
data myTable (keep = indyear gvkey fyear datadate sale sich prcc_f);
set comp.funda;
/* some years */
if fyear > 2000; 
/* sales nonmissing */
if sale ne .;
/* boilerplate filters */
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
run;
proc download data=myTable out=a_comp;run;
endrsubmit;

/*******************************************************  Assignment 1, problem 1 */

/* First compute sum of sales for each gvkey - sich combination */
proc sort data = a_comp; by sich gvkey; run;

proc means data=a_comp noprint;
output out=q1a sum= / autoname;
var sale;
by sich gvkey;
run;

/* Then sum by sich */
proc sort data = q1a; by sich; run;

/* sum by industry if sich is nonmissing */
proc means data=q1a (where=(sich ne .)) noprint;
output out=q1b sum= / autoname;
var sale_sum;
by sich;
run;

/* At least 20 firms  */
data q1b;
set q1b;
if _FREQ_ > 19;
run;

/*******************************************************  Assignment 1, problem 2 */

/* 	For the observations in Funda, compute by year how often SICH is missing.
	The output should show the percentage missing SICH for each year. */

proc sort data=a_comp; by fyear;run;

data q2 (keep = fyear perc_miss count sum_miss);
set a_comp;
by fyear;
retain sum_miss count;
if first.fyear then do;
	sum_miss = 0;
	count = 0;
end;
sum_miss = sum_miss + (sich eq .);
count = count + 1;
perc_miss = sum_miss / count;
if last.fyear then output;
run;

/*******************************************************  Assignment 1, problem 3 */

/*
	For each firm in Funda count the number of years of data before prcc_f is non-missing. 
	Then, give an overview of the frequency (how often 0 years missing, how often 1 year missing, etc).
*/
proc sort data=a_comp nodupkey; by gvkey fyear; run;

data q3; 
set a_comp;
by gvkey; 
retain missing_count flag;
if first.gvkey then do; 
	missing_count = 0;
	flag = 0;
end;
/* missing (and always been missing) */
if missing(prcc_f) eq 1 and flag eq 0 then missing_count = missing_count + 1;
/* set the flag to 1 when a year has a price */
if missing(prcc_f) eq 0 then flag = 1;
/* output if last year, but only if prcc_f was at least present once */
if last.gvkey and flag eq 1 then output;
run;

/* frequency */
proc freq data=q3;
   tables missing_count / out=q3_Count ;  
run;

/*******************************************************  Assignment 1, problem 4 */

/*
	check if 'CIK' (central index key) and 'conm' (Company name) are header variables
*/

/* this will output any records where cik or conm changes for any gvkey */
data q4 (keep = gvkey fyear cik conm cik_prev conm_prev );
set a_comp;
by gvkey;
retain cik_prev conm_prev;
if first.gvkey then do;
	cik_prev = cik;
	conm_prev = conm;
end;
if cik_prev ne cik or conm_prev ne conm then output;
run;


/*******************************************************  Assignment 1, problem 5 */

/*
	Convert wide to long

	Write a datastep that converts this dataset into a 'long' format (id, year, value) 
	(e.g., first record being 1, 2010, 1870). Also add a variable nonMiss that has the 
	number of non-missing values for each id (wich is 4 for ids 1 and 2, and 3 for ids 3 and 4).

*/

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

data q5 (keep = id year value nonMiss);
set somedata;
nonMiss = 4- cmiss (of year2010-year2013);
value = year2010; year = 2010; output;
value = year2011; year = 2011; output;
value = year2012; year = 2012; output;
value = year2013; year = 2013; output;
run;