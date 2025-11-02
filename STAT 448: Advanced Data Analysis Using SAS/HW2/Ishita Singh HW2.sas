/* Data for Exercise 1*/
data skincare;
 input outcome $9. serumyn $1. count;
cards;
normal   N 20
normal   Y 12
improved N 32
improved Y 60
; run;



/*Exercise 1a*/
ods text="EXERCISE 1a";
proc freq data=skincare order=data;
  weight count;
  tables serumyn*outcome / expected norow nocol nopercent;
run;

ods text="Since the expected values on the diagonal is more than the observed values & the expected
values are less than the observed values in off diagonal cells, there is an association 
between the variables.";



/*Exercise 1b*/
ods text="EXERCISE 1b";
ods select ChiSq CMH;
proc freq data=skincare order=data;
  tables serumyn*outcome / chisq;
  weight count;
run;
ods select all;
ods text="The p value for the chi-sq test < 0.05 so we reject the null hypothesis. Therefore, 
there is significant association between both the variables. The p - value for MH test is also 
< 0.05 so we again reject the null hypothesis. Therefore, there is a linear trend between 
the variables.";



/*Exercise 1c*/
ods text="EXERCISE 1c";
proc freq data=skincare order=data;
  tables serumyn*outcome / riskdiff;
  weight count;
  ods select RiskDiffCol2; 
run;
ods text="Since the difference (Row 1 – Row 2) is negative and its 95% CI does not include 0, 
serum users (Row 2 = Y) have a significantly higher probability of improved skin.";





/*Data for Exercises 2, 3, and 4*/
data cars; 
	infile '/home/u64311722/auto-mpg.txt' expandtabs;
	input mpg cylinders displacement horsepower weight acceleration model_year origin car_name & $100.;
	format mpg_cat $20.;
	if horsepower=. then delete; 
	mpg_cat='inefficient';
	if 20<mpg<=26 then mpg_cat='average';
	if mpg>26 then mpg_cat='efficient';
	originname='Europe';
	if origin=1 then originname='US';
	if origin=3 then originname='Japan';
	drop cylinders displacement weight acceleration model_year origin car_name;
run;




/*Exercise 2a*/
ods text="EXERCISE 2a";
proc freq data=cars order=data;
  tables originname*mpg_cat / chisq expected norow nocol;
run;
ods text="Origin and MPG category are strongly associated (Pearson X²=120.55, p < 0.0001; 
Likelihood-ratio X² p < 0.0001).";




/*Exercise 2b*/
ods text="EXERCISE 2b";
data cars_new;
  set cars;
  if originname in ('Europe','Japan') and mpg_cat in ('efficient','inefficient');
run;
proc freq data=cars_new order=data;
  tables originname*mpg_cat / expected chisq fisher norow nocol nopercent;
run;
ods select all;
ods text="There is a strong association in the 3*3 table. When we restrict to Japan vs Europe 
and drop US, the relationship weakens and is not significant.";





/*Exercise 2c*/
ods text="EXERCISE 2c";
proc freq data=cars_new order=formatted;
  tables originname*mpg_cat / riskdiff;
run;
ods text="Because the CI includes 0, the difference is not statistically significant. So we 
cannot conclude that European cars have a higher probability of high fuel efficiency. The point 
estimate suggests Japan is higher.";




/*Exercise 3a*/
ods text="EXERCISE 3a";
proc anova data=cars;     
  class originname;                       
  model mpg = originname;                 
  means originname / hovtest cldiff;        
run;
ods text="One-way ANOVA of mpg by originname is highly significant (F = 96.60, p < 0.0001). 
So mean mpg differs by origin.
Levene’s test p = 0.7846. Group variances look equal, so the standard ANOVA is appropriate.
R² = 0.332 so about 33% of the variation in mpg is explained by origin.
All pairs differ, Japan has the highest mpg, US the lowest, Europe in between.";





/*Exercise 3b*/
ods text="EXERCISE 3b";
proc anova data=cars;     
  class originname;                       
  model mpg = originname;                 
  means originname / tukey;        
run;
ods text="All CIs exclude 0, so all three origins differ significantly. Cars from Japan have the
highest fuel efficiency, Europe is intermediate, and the US has the lowest mpg. The gaps are 
largest between Japan and the US (~10 mpg) and moderate between Europe and Japan (~3 mpg).";





/*Exercise 4a*/
ods text="EXERCISE 4a";
proc anova data=cars;     
  class mpg_cat;                       
  model horsepower = mpg_cat;                 
  means mpg_cat / hovtest tukey cldiff welch;        
run;
ods text="One-way ANOVA of horsepower by mpg_cat is highly significant (F = 223.81, p < 0.0001). 
So mean horsepower differs by mpg_cat.
Levene’s test p = <.0001. Group variances look unequal, so the standard ANOVA is inappropriate.
Welch test p = <.0001.
R² = 0.535039 so about 53% of the variation in horsepower is explained by mpg_cat.
All pairs differ, Japan has the highest horsepower, US the lowest, Europe in between.
Inefficient cars have the highest horsepower, efficient the lowest, with average in between.";





/*Exercise 4b*/
ods text="EXERCISE 4b";
proc anova data=cars;     
  class mpg_cat;                       
  model horsepower = mpg_cat;                
  means mpg_cat / tukey;        
run;
ods text="All CIs exclude 0, so all three origins differ significantly. Horsepower decreases as 
fuel efficiency improves: Inefficient > Average > Efficient.";


































