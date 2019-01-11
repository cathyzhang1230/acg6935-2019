# Assignment 1

## 1. Life-time industry sales

Compute the aggregate life-time sales for each firm in Funda. Then, aggregate by 4-digit SICH (historical industry code) to compute life-time sales for each industry. Drop industries with less than 20 firms in it.



## 2. Missing SICH

For the observations in Funda, compute by year how often SICH is missing. 

The output should show the percentage missing SICH for each year. 

> You can use fyears starting at 2000.



## 3. Pre-IPO data points 

For each firm in Funda count the number of years of data before prcc_f is non-missing.
(For example, if a firm is added to Funda in 2004, and prcc_f only is available for the first time in 2006, then there are 2 years of data for that firm)

Then, give an overview of the frequency (how often 0 years missing, how often 1 year missing, etc).

## 4. Header variables

Some variables in Funda are 'header' (that means, all firms' rows get updated if the value changes).
Verify if the vvariables 'CIK' (central index key) and 'conm' (Company name) change over the fyears or not (if it doesn't change, it means it is a header variable).

## 5. Wide to long

Consider the following dataset:

```SAS
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

```

Write a datastep that converts this dataset into a 'long' format (id, year, value) (e.g., first record being `1, 2010, 1870`). Also add a variable `nonMiss` that has the number of non-missing values for each id (wich is 4 for ids 1 and 2, and 3 for ids 3 and 4).

> Note: the initial dataset is in a 'wide' format, for wide vs long format, see [https://www.theanalysisfactor.com/wide-and-long-data/](https://www.theanalysisfactor.com/wide-and-long-data/)