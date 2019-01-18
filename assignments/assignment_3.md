# Assignment 3

## 1. Stock return over window

Write SAS code to compute yearly abnormal stock return (monthly firm return - monthly index return) over 2006-2009 for firms in the financial industry. Use the vwretd (value weighted) index return in MSIX. Abnormal stock return is the compounded monthly stock return minus the compounded monthly index return.

## 2. Macro stock return

Turn the code for part 1 into a macro. The macro needs to be invoked with the following arguments: %getReturn(dsin=, dsout=, start=datadate, end=enddate) where dsin already holds the financial firms and their permnos (gvkey, fyear, permno, sich, datadate, enddate) (generate enddate as enddate = datadate + 360;).


## 3. Matching with CCM linktable

For a sample of firms from Compustat Funda, match on the CCM linktable using datadate (end of fiscal year) to get permno. Use permno to collect stock return for the 12 months of the fiscal year. 

Then, repeat the above, but instead of matching with the CCM linktable with datadate, use 12 end of months of the fiscal year to get to permno for each month. For example, if the fiscal year end is December 31, 2010, then the end of months will be January 31, 2010, February 28, 2010, etc through December 31, 2010.

