data redwine;
	infile '/home/u64311722/red_wine.csv' dlm=';' expandtabs;
	input fixed_acidity	volatile_acidity citric_acid residual_sugar	chlorides 
	free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol quality;
	good_wine = quality>=7;
	below_avg_wine= quality<=5;
	drop quality;
run;



/*Exercise 1a*/
ods text="Exercise 1a";
proc logistic data=redwine desc;
  model good_wine =
        fixed_acidity volatile_acidity citric_acid residual_sugar chlorides
        free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol;
  ods select OddsRatios ParameterEstimates GlobalTests Type3 ModelInfo FitStatistics;
run;
ods text="All three global tests are highly significant, p-value < 0.05. At least one of the 
variables seem important & better than only intercept model because of lower AIC and SC values.

Significant predictors (p < 0.05):

Alcohol: beta=0.7533, p<0.0001, OR=2.12 (CI=1.64-2.75).

Sulphates: beta=3.7499, p<0.0001, OR=42.5 (CI=14.7-122.9).

Volatile acidity: beta=−2.5810, p=.0010, OR=0.076 (CI=0.016-0.352).

Residual sugar: beta=0.2395, p=.0012, OR=1.27 (1.10-1.47).

Total sulfur dioxide: beta=−0.0165, p=.0007, OR=0.984 (0.974-0.993).

Fixed acidity: beta=0.2750, p=.0282, OR=1.32 (1.03-1.68).

Chlorides: beta=−8.8163, p=.0088, OR ≈ 0 (0.108).

Density: beta=−257.8, p=.0195, OR ≈ 0.

Not significant after adjustment (p > 0.05):

Citric acid (p=0.4983), Free SO2 (p=0.3765), pH (p=0.8223).

Based on the individual p-values, the Type 3 table will align closely:

Retain: alcohol, sulphates, volatile_acidity, residual_sugar, total_sulfur_dioxide, 
fixed_acidity, chlorides, density (all have p<0.05 and meaningful effects).

remove: citric_acid, free_sulfur_dioxide, pH.";






/*Exercise 1b*/
ods text="Exercise 1b";

* stepwise selection;
proc logistic data=redwine desc plots(only)=(influence);
  model good_wine =
        fixed_acidity volatile_acidity citric_acid residual_sugar chlorides
        free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol
        / selection=stepwise;
  output out=diag1 p=phat resdev=rdev reschi=rpear h=lev c=cstat;
run;

* remove influential point;
data redwine_clean;
  set diag1;
  if cstat <= 1;
run;

* refit the model;
proc logistic data=redwine_clean desc plots(only)=(influence);
  model good_wine =
        fixed_acidity volatile_acidity citric_acid residual_sugar chlorides
        free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol
        / selection=stepwise lackfit;
  ods select ParameterEstimates LackFitChiSq;
  output out=diag2 p=phat resdev=rdev reschi=rpear h=lev c=cstat;
run;
ods text="Since the p value of the lack of fit test is > 0.05, we reject the null the null 
hypothesis and there is no need to refine the model further.";




/*Exercise 1c*/
ods text="Exercise 1c";
ods text="The global test indicates the model is highly significant (p < 0.0001), 
meaning at least one wine characteristic helps predict good_wine status. 
Significant predictors include fixed_acidity, volatile_acidity, residual_sugar, 
chlorides, total_sulfur_dioxide, density, sulphates, and alcohol (p < 0.05). 
Citric_acid, free_sulfur_dioxide, and pH are not significant and could be removed 
from the model.

Odds ratios show that higher alcohol and sulphates greatly increase the odds of a 
wine being rated good, while higher volatile acidity, chlorides, density, and total 
sulfur dioxide decrease the odds. Fixed acidity and residual sugar also show small 
positive effects on good_wine status.";







/*Exercise 2*/
ods text="Exercise 2";
proc logistic data=redwine desc;
  model below_avg_wine =
        fixed_acidity volatile_acidity citric_acid residual_sugar chlorides
        free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol;
  ods select OddsRatios ParameterEstimates GlobalTests Type3 ModelInfo FitStatistics;
run;
ods text="For the below_avg_wine model, several parameters are significant predictors of low 
wine quality. Higher volatile acidity, chlorides, citric acid, and total sulfur dioxide all 
increase the odds of a wine being below average, while higher alcohol, sulphates, and free 
sulfur dioxide decrease the odds of poor quality. Comparing this to the good_wine model, higher 
alcohol content and sulphates are consistently associated with better wine quality, whereas 
higher volatile acidity, chlorides, and total sulfur dioxide are markers of lower-quality wines.";


* stepwise selection;
proc logistic data=redwine desc plots(only)=(influence);
  model below_avg_wine =
        fixed_acidity volatile_acidity citric_acid residual_sugar chlorides
        free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol
        / selection=stepwise;
  output out=diag1 p=phat resdev=rdev reschi=rpear h=lev c=cstat;
run;

* remove influential point;
data redwine_clean_new;
  set diag1;
  if cstat <= 1;
run;

* refit the model;
proc logistic data=redwine_clean_new desc plots(only)=(influence);
  model below_avg_wine =
        fixed_acidity volatile_acidity citric_acid residual_sugar chlorides
        free_sulfur_dioxide total_sulfur_dioxide density pH sulphates alcohol
        / selection=stepwise lackfit;
  ods select ParameterEstimates LackFitChiSq;
  output out=diag2 p=phat resdev=rdev reschi=rpear h=lev c=cstat;
run;
ods text="After removing influential points and letting stepwise pick the predictors, the final 
below-average quality model kept six variables: volatile acidity, chlorides, free 
sulfur dioxide, total sulfur dioxide, sulphates, and alcohol. All are statistically significant
(p < 0.003). Wines are more likely to be below average when volatile acidity, chlorides, or total sulfur dioxide are higher; they are less likely to be below 
average when alcohol, sulphates, or free sulfur dioxide are higher. The Hosmer-Lemeshow test 
(p = 0.169) shows no evidence of lack of fit.";
 
ods text="Good wines (rating > 7) are associated with more alcohol and more sulphates, and with 
less volatile acidity, chlorides, and total sulfur dioxide. In contrast, below-average wines 
(rating < 5) are much more likely when volatile acidity, chlorides, and total SO2 are higher, 
and less likely when alcohol, sulphates, and free SO2 are higher.";









/* Exercise 3 and 4 Data */
data abalone;
	infile '/home/u64311722/abalone.txt' dlm=',';
	input sex $ length diameter height whole_weight meat_weight gut_weight shell_weight rings;
	drop meat_weight gut_weight shell_weight;
run;


/*Exercise 3a*/
ods text="Exercise 3a";
proc genmod data=abalone;
  class sex;
  model rings = sex length diameter height whole_weight
        / dist=poisson link=log type1 type3;
  ods select ModelInfo ModelFit ParameterEstimates Type1 Type3;
run;
/* under-dispersion */
proc genmod data=abalone;
  class sex;
  model rings = sex length diameter height whole_weight
        / dist=poisson link=log type1 type3 scale=deviance;
  ods select ModelInfo ModelFit ParameterEstimates Type1 Type3;
run;
ods text="After fitting rings ~ sex + length + diameter + height + whole_weight with scale=
deviance, the significant predictors (p < 0.05) are sex=I (infant) (fewer rings than males), 
length (negative), diameter (positive), height (positive), and whole_weight (slightly negative). 
Sex=F (female) is not significant vs males (p≈0.21), meaning females and males have similar 
ring counts once size is controlled.";
ods text="From the Poisson model, it looks like the number of rings (which indicates an 
abalone’s age) depends mostly on its diameter, height, and length. In contrast,
heavier or longer abalones have slightly fewer rings when size is already accounted for, 
suggesting weight or length alone doesn’t always mean older age. 
Overall, shell thickness and height are the best indicators of an abalone’s age.
Females vs males show no meaningful difference in rings once body size is included.";



/*Exercise 3b*/
ods text="Exercise 3b";
/* Start with all predictors */
proc genmod data=abalone;
  class sex;
  model rings = sex length diameter height whole_weight
        / dist=poisson link=log type3;
  ods select ModelInfo ModelFit ParameterEstimates Type3;
run;
ods text="Variable sex has a p value > 0.05 so it statistically insignificant.";

/* Remove least significant predictor (if p>0.05), refit */
proc genmod data=abalone;
  class sex;
  model rings = length diameter height whole_weight
        / dist=poisson link=log type3;
  ods select ModelInfo ModelFit ParameterEstimates Type3;
run;

/* Check for over/under-dispersion and influence */
proc genmod data=abalone;
  class sex;
  model rings = length diameter height whole_weight
        / dist=poisson link=log type3 scale=deviance;
  output out=abalone_infl cooksd=cookd;
run;

ods text="Removing any influential points and refitting the model based on chosen predictores:";
/* Remove influential points (Cook’s D > 1) */
data abalone_clean;
  set abalone_infl;
  if cookd <= 1;
run;

/* Final model after point removal */
proc genmod data=abalone_clean;
  class sex;
  model rings = length diameter height whole_weight
        / dist=poisson link=log type3 scale=deviance;
  ods select ModelInfo ModelFit ParameterEstimates Type3;
run;



/*Exercise 3c*/
ods text="Exercise 3c";
proc genmod data=abalone plots=(stdreschi stdresdev);
  class sex;
  model rings = length diameter height whole_weight
        / dist=poisson link=log scale=deviance;
  ods select ModelInfo DiagnosticPlot;
run;
ods text="The standardized Pearson and deviance residuals are centered around zero with no 
strong pattern or curvature, which suggests that the log-linear Poisson model fits the data 
well. A few extreme residuals are visible, but they represent isolated observations and do not 
indicate a major violation of assumptions.";




/*Exercise 4*/
ods text="Exercise 4";

/* Start with all predictors */
proc genmod data=abalone;
  class sex;
  model rings = sex length diameter height whole_weight
        / dist=gamma link=log type3;
  ods select ModelInfo ModelFit ParameterEstimates Type3;
run;
ods text="Variable sex has a p value > 0.05 so it statistically insignificant.";

/* Remove least significant predictor (if p>0.05), refit */
proc genmod data=abalone;
  class sex;
  model rings = length diameter height whole_weight
        / dist=gamma link=log type3;
  ods select ModelInfo ModelFit ParameterEstimates Type3;
run;

/* Check for under-dispersion and influence */
proc genmod data=abalone;
  class sex;
  model rings = length diameter height whole_weight
        / dist=gamma link=log type3 scale=deviance;
  output out=abalone_infl cooksd=cookd;
run;

ods text="Removing any influential points and refitting the model based on chosen predictors:";
/* Remove influential points (Cook’s D > 1) */
data abalone_clean;
  set abalone_infl;
  if cookd <= 1;
run;

/* Final model after point removal */
proc genmod data=abalone_clean;
  class sex;
  model rings = length diameter height whole_weight
        / dist=gamma link=log type3 scale=deviance;
  ods select ModelInfo ModelFit ParameterEstimates Type3;
run;

proc genmod data=abalone plots=(stdreschi stdresdev);
  class sex;
  model rings = length diameter height whole_weight
        / dist=gamma link=log scale=deviance;
  ods select ModelInfo DiagnosticPlot;
run;


ods text="The Gamma model shows better fit than the Poisson: lower AIC (18,530 vs 19,587), and 
scaled deviance ≈ 1; residual plots show fewer extreme outliers and more homogeneous spread 
than the Poisson model. Overall, the Gamma log-linear model is the more reasonable choice here, 
with meaningful, significant predictors and better diagnostics.";








