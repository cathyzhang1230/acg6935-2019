%let wrds = wrds.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;
/* maybe this would be faster 
%let wrds = wrds-cloud.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;
*/
signon username=_prompt_;

rsubmit;

libname hello '/wrds/comp/sasdata/nam';

data test;
set hello.funda;
if _N_ < 100;run;

endrsubmit;

rsubmit;
data myTable (keep = gvkey fyear datadate roa mtb size sale at ni prcc_f csho xrd curcd);
set comp.funda;
/* require fyear to be within 2010-2013 */
if 2010 <=fyear <= 2013;
/* require assets, etc to be non-missing */
if cmiss (of at sale ceq ni) eq 0;
/* replace missing xrd with 0 */
if missing(xrd) eq 1 then xrd = 0;
/* construct some variables */
roa = ni / at;
mtb = csho * prcc_f / ceq;
size = log(csho * prcc_f);
/* prevent double records */
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
run;
proc download data=myTable out=myCompTable;run;
endrsubmit;

data testusd;
set mycomptable;
if curcd ne "USD";run;


/* sort by firm and year */
proc sort data=myCompTable /*nodupkey dupout=mydouble*/; by gvkey fyear;run;
/* ..*/
proc sort data=myCompTable nodupkey dupout=mydouble; by gvkey fyear;run;

/* I have a dataset with potential duplicates, but also a variable
analyst_recomm; I want to keep the highest value of analyst_recomm */

/* first sort such that the 'good' record comes first */
proc sort data=myCompTable  ; by gvkey fyear descending analyst_recomm;run;

/* then again, with nodupkey */
proc sort data=myCompTable nodupkey dupout=mydouble; by gvkey fyear;run;


data myDirtyTable (keep = gvkey fyear sale sale_prev increase);
set myCompTable;
retain sale_prev;
if _N_ <= 30;
increase = (sale > sale_prev and missing(sale_prev) eq 0 );
sale_prev = sale;
run;

data myCleanTable (keep = gvkey fyear sale sale_prev increase helloLast);
set myCompTable;
by gvkey;
retain sale_prev;
if _N_ <= 30;
increase = (sale > sale_prev); /*<-------------- condition */
if first.gvkey then increase = .;
if last.gvkey then helloLast = 1;
sale_prev = sale; /* <---------- update previous sales */
run;

/* sum of sales for each gvkey */
data mySumTable2 (keep = gvkey fyear sale sale_prev sum_sales );
set myCompTable;
by gvkey;
retain sum_sales;
if _N_ <= 30;
if first.gvkey then sum_sales = 0;
sum_sales = sum_sales + sale;
if last.gvkey then output;
run;

data mytest;
do x = 0 to 2000;
	y = x;
	output;
end;

format x date9.;run;

data mytest;
mydate1 = '1jan2010';
mydate2 = '1jan2010'd;
mydate3 = '1jan2010'd;
format mydate3 date9.;
run;

data mydata;* (drop = i);
/* repeat times */
do sample = 1 to 10 ;
	/* generage event dates */
	do i = 1 to 5 ;			
		/* generate a random date between 1/1/2000 and 31/12/2010 
			- floor rounds a number down (dates are integers)
			- ranuni generates random number, 6675309 is a random seed (can be any other number)
			- difference in dates (1/1/2010 vs 1/1/2000) is #days in 10-year period
		*/
	   	eventdate = '01jan2000'd + floor(ranuni(8675309)*( '01jan2010'd - '01jan2000'd ) );
		output;
	end;
end; 
format eventdate date9.;
run;


data jeff;
	do i = 1 to 50000 ;	
		random = floor(ranuni(123)*( 100 ) );
		output;
	end;
	run;

proc sort data = jeff; by random;run;
