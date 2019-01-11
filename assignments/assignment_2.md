# Assignment 2


## 1. Funda - segment file consistency

Select the firms in the segment files that have a single business segment. Compare the SIC industry code with the SICH industry code of the firm. Which percentage of firms that have a single segment have the same firm-level 4-digit industry code and segment industry code?


## 2. Relative industry ROA

Create a dataset from Funda with gvkey, fyear, etc, and return on assets. 
Then, *using proc sql*, construct a measure that is the average return on assets of the other firms in the industry-year, excluding the firm itself.

## 3. Entropy measure

Using the firm's segment files, construct the entropy measure of how dispersed the segment's sales are.

The entropy measure is the sum of P x P x ln ( 1 / P), where P is the proportion of the segment sales as a percentage of the firm's sales.

For example, if a firm has 2 segments A and B, with sales of 10 and 20 million, then the entropy measure is 1/3 x 1/3 x ln (3) + 2/3 x 2/3 x ln (1.5) = 0.3 (rounded)
(P for segment A is 10/30, P for segment B is 20/30).

A firm active in a single segment has an entropy of 0 (1 x 1 x ln (1) = 0).


Use the following code to clean up the segment file (i.e. only keep the relevant industrial segments)

```SAS
data b_segm (keep = GVKEY datadate STYPE SID IAS CAPXS NAICS NAICSH NAICSS1 NAICSS2 NIS OPS SALES SICS1 SICS2 SNMS SOPTP1 INTSEG);
set segments.Wrds_segmerged;
/* prevent duplicates: use the data when first published (not later years)*/
if srcdate eq datadate;
/* select business/operating (or, industrial) segments */
if stype IN ("BUSSEG", "OPSEG");
/* keep segments that have SIC industry code */
if SICS1 ne "";
/* keep segments with positive sales */
if sales > 0;
run;
```