/*
	binning => terciles, quartiles, quintiles, etc
*/

/* using proc rank, groups = 10 will create 11 groups! (one group with missing and groups 0-9) */

proc rank data = myComp out=myComp2 groups = 10;
var roa size ; 		
ranks roa_d size_d ; 
run;

/* are the bins of equal size? */
proc freq data=myComp2;
tables roa_d;
run;

/* 	What if we want to include the vars with missing roa in the first decile and we want the first 9 deciles to have the same #obs?
	=> Create our own binning procedure */

/* get number of observations -- yes, this looks like a hack */
data _NULL_;
	if 0 then set myComp2 nobs=n;
	call symputx('numObs',n);
	stop;
run;

%let nrBins = 10; 
/* the binsize (#obs in each bin) is the #obs divided by #bins (needs rounding down)  */
%let binSize = %sysfunc(floor( %eval(&numObs/&nrBins) ));
%put Binsize: &binSize;

/* Just in case we use the rank procedure twice on variables that are correlated we add and sort on a random variable */
data myComp3;
set myComp2;
myRandom = ranuni(123); /* 123 is the seed for the random number generator */
run;

/* sort on the binning variable (and the random variable) */
proc sort data = myComp3; by roa myRandom;run;

/* If we want to create a ranked variable by year, we would repeat the whole procedure by each year -- remind me when we have covered Clay macro's %array and %do_over*/

/* Create decile for binning variable */
data myComp3;
set myComp3;
bin = floor( ( _N_ - 1 ) / &binSize);
run;

/* are the bins of equal size? */
proc freq data=myComp3;
tables bin;
run;
