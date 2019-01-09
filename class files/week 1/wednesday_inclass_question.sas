rsubmit;endrsubmit;
%let wrds = wrds.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;
signon username=_prompt_;

rsubmit;
data myComp (keep = gvkey fyear datadate cik ni at sale ceq prcc_f csho sich roa mtb size);
set comp.funda;
/* require fyear to be within 2001-2015 */
if 2001 <=fyear <= 2015;
/* require assets, etc to be non-missing */
if cmiss (of at sale ceq ni) eq 0;
/* construct some variables */
roa = ni / at;
mtb = csho * prcc_f / ceq;
size = log(csho * prcc_f);
/* prevent double records */
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
run;
proc download data=myComp out=myComp;run;
endrsubmit;


data mycomp;
set mycomp;
/* require roa to be nonmissing */
if missing(roa) eq 0;run;

/* compute cumulative roa and number of firms in the industry-year */
proc sort data=mycomp; by sich fyear;run;
data roa_1 (keep = gvkey sich fyear roa numfirms sumroa);
set mycomp;
by sich fyear;
retain numfirms sumroa;
if first.fyear then do;
    numfirms = 0;
	sumroa = 0;
end;
numfirms = numfirms + 1;
sumroa = sumroa + roa;
run;

/* sort such that last firmyear within industry comes first */
proc sort data=roa_1; by sich fyear descending numfirms;run;

/* get sumroa for every firm in industry year */
data roa_2;
set roa_1;
by sich fyear;
retain newsumroa newnumfirms;
if first.fyear then do;
   newsumroa = sumroa;
   newnumfirms = numfirms;
end;
run;

/* undo firm-year effect on average industry-year roa */
data roa_3;
set roa_2;
roa_relative = (newsumroa - roa) / (newnumfirms - 1);
run;

/* how does it look like if there would be no retain? */
data roa_test;
set roa_1;
by sich fyear;
/*retain newsumroa newnumfirms;*/
if first.fyear then do;
   newsumroa = sumroa;
   newnumfirms = numfirms;
end;
run;


