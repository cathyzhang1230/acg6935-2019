/*
	SAS macros and CRSP

	topics

	Macros: Simple text replacement
	Macros: Conditional code
	Macros: from SQL into macro variable
	CRSP Daily stock file (DSF)
	CRSP Monthly stock file (MSF)
	CRSP Indices (DSIX, MSIX)
	Matching Compustat and CRSP (CCM)
*/

/* get a dataset to work with */
rsubmit;endrsubmit;
%let wrds = wrds.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;
signon username=_prompt_;

rsubmit;

libname myfiles "~"; /* ~ is home directory in Linux, e.g. /home/ufl/imp */
proc sql;
	create table myfiles.a_funda as
		select gvkey, fyear, datadate, sich, sale, ni
	  	from comp.funda 
  	where 		
		2010 <= fyear <= 2016	
	and indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
quit;

proc download data=myfiles.a_funda out=a_funda;run;
endrsubmit;


/* Macro variables: Simple text replacement
   ------------------------------- */

/* variable assignments */
%let tableDir = C:\temp\;
%let vars = equity return;
 
/* create descriptive statistics */
proc means data=result NOPRINT;
output out=table1 mean= median= std= min= max= p25= p75= N=/autoname;
var &vars;
run;
 
/* export to table_1.csv in &tableDir */
proc export data=table1 OUTFILE="&tableDir.table_1.csv" dbms=csv replace;
run;



/* our first macro - one that doesn't do much */

%macro myFirst(); /* define a new macro with the name 'myFirst' */

	/* create a dataset with some variable */
	data result2;
	set a_funda;
	year = year(datadate);
	run;
%mend; /* mend=macro end */

/* invoke (run) the macro and inspect generated text file with code generated */
%myFirst();


/* turn on macro debugging */
filename mprint 'C:\temp\tempSAScode.SAS';
options mprint mfile;

/* passing arguments into macro 
   ---------------------------- */

%macro mySecond(datevar); 
  data result2;
  set a_funda;
  year = year(&datevar);
  run;
%mend;
%mySecond(datadate);

* require variable names to be specified;
%macro mySecond(datevar=); 
  data result2;
  set a_funda;
  year = year(&datevar);
  run;
%mend;
%mySecond(datevar=datadate);

* multiple vars, with optional values (in this case name) ;
%macro myThird(dsin=, dsout=, datevar=, name=year); 
  data &dsout;
  set &dsin;
  &name = year(&datevar);
  run;
%mend;
%myThird(dsin=a_funda, dsout=result3, datevar=datadate);

* it is possible to have macro variables defined 'outside' the macro;
%let something = "hi";
%macro myThird(dsin=, dsout=, datevar=, name=year); 
  data &dsout;
  set &dsin;
  &name = year(&datevar);
  somevar = &something;
  run;
%mend;
%myThird(dsin=a_funda, dsout=result3, datevar=datadate);



* congratulations -- you just made a reusable component!;

/* system errors */

* valid code;

data result2;
set a_funda;
year = year(datadate);
run;

%put syserr (system error) is &syserr ;

* followed by a mistake  ;

proc go_gators!; quit;

%put syserr (system error) is &syserr ;

* SAS will continue processing next statements after an error, which is cause for
troublesome bugs if you don't look at the log after submitting statements

 -> use %runquit macro 
	%runquit will throw an 'abort' when &syserr is not 0 and SAS will stop 
	it will be obvious there was an error
;

/* include statement 
   -----------------
*/

/* note the folder structure: class 3 folder has  subdirectory 'general macros' */

%include "E:\git\acg6935-2019\class files\week 3\general macros\runquit.sas";

/* compare */
proc go_gators!; quit;
data result2; set a_funda; year = year(datadate); run;

/* with */
proc go_gators!; %runquit; /* %runquit instead of quit */
data result2; set a_funda; year = year(datadate); %runquit; /* %runquit instead of run */

/*  Include code from a url (huge security risk though!)

	We discuss Ted Clay's array functions next week
*/
 
filename m1 url 'http://www.wrds.us/macros/array_functions.sas';
%include m1;

/* Macros: Conditional code
   ------------------------ */

/*
  macro that computes the Herfindahl index for each industry-year
  indVar can be SIC or NAICS
  dsin needs to have gvkey, fyear, SICH or NAICSH
  
  sample use: %computeIndSales(dsin=work.start, dsout=work.indsales, indVar=NAICS);
*/
%macro computeIndSales(dsin=, dsout=, indVar=SIC);
 
  /* code for SIC */
  %if &indVar eq SIC %then %do;
    proc sql;
      create table &dsout as 
      select fyear, SICH, sum(sale) as ind_sales, count(*) as num_firms from &dsout
      from &dsin group by fyear, SICH;
    quit;
   %end;
 
 /* code for NAICS (all cases where &indVar differs from SIC)*/
  %else %do; 
      proc sql;
      create table &dsout as 
      select fyear, NAICSH, sum(sale) as ind_sales, count(*) as num_firms from &dsout
      from &dsin group by fyear, NAICSH;
    quit;
  %end;
%mend;


/* matching Compustat and CRSP */

rsubmit; 

proc upload data=a_funda out=getThese; 
   
/* match with compustat-crsp merged to retrieve PERMNO  
  
CC merged has a linkdt and linkenddt for which the record is valid  
linkdt: First Effective Date of Link  
linkenddt: Last Effective Date of Link  
  
datadate must be between linkdt and linkenddt: a.linkdt <= b.datadate <= linkenddt 
usually linkdt and linkenddt is a date, but linkdt can be 'B' (beginning) and linkenddt  
can be 'E' (end). 
  
linkprim: Primary issue marker for the link. Based on 
Compustat Primary/Joiner flag (PRIMISS), indicating 
whether this link is to Compustat's marked primary 
security during this range. ("C" and "P" indicate primarly links) 
Not inlcuding "and a.linkprim IN ("C", "P") " will give some double observations (meaning, primary  
and secondary securities are included (for example, 
class A and class B shares). This can be overcome by including a single security.  
On the other hand, including the line will prevent such double securities, but (somehow) some firms  
will not end up in the sample.  
*/
  
PROC SQL; 
  create table ccMerged as 
  select a.*, b.lpermno as permno
  from getThese a left join crsp.ccmxpf_linktable b 
    on a.gvkey eq b.gvkey 
    and b.lpermno ne . 
    and b.linktype in ("LC" "LN" "LU" "LX" "LD" "LS") 
    and b.linkprim IN ("C", "P")  
    and ((a.datadate >= b.LINKDT) or b.LINKDT eq .B) and  
       ((a.datadate <= b.LINKENDDT) or b.LINKENDDT eq .E)   ; 
  quit; 
  
proc download data=ccMerged out=u_withpermno; run;
endrsubmit; 
  
/* what happened with gvkey 001045? the permno of 21020 disappears in 2012 */

rsubmit;
data v_dse_21020;
set crsp.dsenames;
where permno eq 21020;run;

data w_ccm_1045;
set crsp.Ccmxpf_linktable;
if gvkey eq "001045";run;

proc download data=v_dse_21020 out=crsp_21020;run;
proc download data=w_ccm_1045 out=crsp_1045;run;

endrsubmit;

/*
wikipedia: https://en.wikipedia.org/wiki/History_of_American_Airlines
'AMR and US Airways Group completed the merger on December 9, 2013, in the process creating the new holding company American 
Airlines Group, Inc., which began trading on NASDAQ later that day'
*/

/* let's compute stock return for 15 day window following end of year (datadate) */

/* create key (will come in handy later) */
data u_withpermno;
set u_withpermno;
key = gvkey || datadate;run;

proc sql;
	create table y_ret as 
	select a.*, b.ret, b.date /* b.date not strictly needed */
	from u_withpermno a, crsp.dsf b
	where a.permno = b.permno
	/* it is easy to make mistakes here, that's why I inspect if b.date looks good */
	and b.date -15 <= a.datadate < b.date 
	and b.ret ne . ;
quit;

proc sort data = y_ret; by key;run;

data z_cumret;
set y_ret;
by key;
retain cumret;
if first.key then cumret = 0;
cumret = cumret + ret;
*if last.key then output;
run;

