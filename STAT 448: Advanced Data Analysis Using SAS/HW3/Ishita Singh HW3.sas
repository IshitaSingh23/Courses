/* data for Exercise 1 */
data cardata;
	set sashelp.cars;
	keep cylinders origin type mpg_city;
	where type not in('Hybrid','Truck','Wagon','SUV') and 
		cylinders in(4,6) and origin ne 'Europe';
run;



/*Exercise 1a*/
ods text="Exercise 1a";
proc means data=cardata n mean std;
  class cylinders origin type;
  var mpg_city;
run;
ods text="Mean of 4-cyl sedans > 6-cyl sedans.

Among 4-cyl, mean of sedans > sports (26.5 > 21.5).

For 4-cyl sedans, Asia > USA (26.5 > 24.7).

For 6-cyl sedans, Asia and USA are almost the same.

Cell sizes range from 49 (4-cyl Asia sedans) to 2 (6-cyl USA sports).";






/*Exercise 1b*/
ods text="Exercise 1b";
proc glm data=cardata;
  class cylinders origin type;
  model mpg_city = cylinders origin type / ss3;
run;
ods text="We will keep cylinder and type as they are statistically significant. 

We will remove origin variable as it has a high p-value (0.1147) and is statistically insignificant.

Overall the model is significant as p-value is less than 0.05.";


proc glm data=cardata;
  class cylinders type;
  model mpg_city = cylinders type / ss3;
run;
ods text="After removing type variable, the remaining variables are significant as their 
p-value is < 0.05.

Overall the model is significant with p-value < 0.05 & F-value = 115.26.

The percentage of variation explained by the model (R^2) = 56.5%.";





/*Exercise 1c*/
ods text="Exercise 1c";
proc glm data=cardata;
  class cylinders type;
  model mpg_city = cylinders|type / ss3;
  lsmeans cylinders|type/pdiff=all cl;
  ods select OverallANOVA ModelANOVA LSMeans LSMeanDiffCL;
run;
ods text="Final model used: mpg_city = Cylinders Type Cylinders*Type (Origin dropped).

All the terms are highly significant as their p value is << 0.05.

Overall model fit: F = 84.18, p < .0001. Therefore, model is highly significant.

Variation explained: R² = 0.0589 so the model explains around 59% of the variability in city MPG.

4-cylinder cars have much higher MPG (about 4.42) than 6-cylinder cars.

Sedans get about 2 MPG more than sports cars, especially for 4-cylinder engines.

The interaction means the effect of Type depends on Cylinders.

Sedan vs. sports difference is large for 4-cyl but disappears for 6-cyl.

Origin doesn’t affect MPG once the other factors are included.";







/* data for Exercise 2 */
/* based on data from Chapter 6 of A Handbook of Statistical Analyses Using SAS, Third Edition */
data drinking;
 input country $ 1-12 alcohol cirrhosis;
cards;
France        24.7  46.1
Italy         15.2  23.6
W.Germany     12.3  23.7
Austria       10.9   7.0
Belgium       10.8  12.3
USA            9.9  14.2
Canada         8.3   7.4
E&W            7.2   3.0
Sweden         6.6   7.2
Japan          5.8  10.6
Netherlands    5.7   3.7
Ireland        5.6   3.4
Norway         4.2   4.3
Finland        3.9   3.6
Israel         3.1   5.4
;
data logdrinking;
	set drinking;
	logcir = log(cirrhosis);
	drop cirrhosis;
run;



/*Exercise 2a*/
ods text="Exercise 2a";
proc reg data=logdrinking;
  model logcir = alcohol;
  ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel;
run;
ods text="Cook's distance is huge as seen in the diagnostic plot which shows the presence of 
influential points.";

* Cook distances to identify highly influential points;
proc reg data=logdrinking noprint;
	model logcir = alcohol;
	output out=diagnostics cookd= cd;
run;
proc print data=diagnostics;
run;


* points with Cook distance greater than 1;
proc print data=diagnostics;
	where cd > 1;
run;
ods text="France has a really high cook's distance. Therefore, it is a highly influential point.";


* fit using output data set and removing influential point;
proc reg data=diagnostics;
	model logcir = alcohol;
	where cd < 1;
run;
ods text="The diagnost plots look correct after removing the influential point.";






/*Exercise 2b*/
ods text="Exercise 2b";
ods text="Overall F = 21.7, p = 0.0006 so model is highly significant.

R² = 0.644 (Adj R² = 0.614) so the model explains 64% of the variability in log(cirrhosis deaths).

Residual vs fitted: no funnel shape; variance looks roughly constant.

QQ-plot / histogram: residuals are close to normal.

Leverage & Cook’s D: several moderate bars but none exceed cutoffs. No remaining unduly 
influential points.

Slope for alcohol = 0.1578, p = 0.0006 (strongly positive).

exp(0.1578) = 1.17.
Each additional liter of alcohol per person per year is associated with 17% higher cirrhosis death rates.

The raw model (chosen in class) has slightly higher R2(69% vs 64%), but shows worse diagnostics (non-constant 
variance, more influence).

The log model gives a cleaner fit that better meets regression assumptions & has positive 
predictions.";







/* data for Exercise 3 */
data running;
  *infile 'C:\Stat 448\olympic.dat';
  infile '/home/u64311722/olympic.dat' expandtabs;
  input name $ 1-13 run100 Ljump shot Hjump run400 hurdle discus polevlt javelin run1500 dscore;
  drop name dscore;
run;





/*Exercise 3a*/
ods text="Exercise 3a";
* linear regression model for run1500 as a function of run100;
proc reg data=running;
  model run1500 = run100;
  ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel;
run;

* Cook distances to identify highly influential points;
proc reg data=running noprint;
	model run1500 = run100;
	output out=diagnostics cookd= cd;
run;
proc print data=diagnostics;
run;

ods text="The residuals are approximately normal & there seem to be no influential points.

The model is highly significant (p < 0.0001) with an F-value = 716.44, showing a very strong 
linear relationship between 100m and 1500m dash times.

The R^2 = 0.9484 means that about 95% of the variation in the 1500m time can be explained by 
the 100m time.

The positive slope (69.38) suggests that athletes who take longer to complete the 100m dash 
also tend to take longer for the 1500m run.";







/*Exercise 3b*/
ods text="Exercise 3b";
* linear regression model for run1500 as a function of run400;
proc reg data=running;
  model run1500 = run400;
  ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel;
run;

* Cook distances to identify highly influential points;
proc reg data=running noprint;
	model run1500 = run400;
	output out=diagnostics cookd= cd;
run;
proc print data=diagnostics;
run;

ods text="The residuals are approximately normal & there seem to be no influential points.

Model 1 (run100 ~ run1500)
R² = 0.9484 so 94.8% of variation explained.
F = 716.44, p < 0.0001 (strong relationship)
Slope = 69.38 so athletes with higher 100m times also have higher 1500m times

Model 2 (run400 ~ run1500)
R² = 0.9953 so 99.5% of variation explained.
F = 8332.20, p < 0.0001 (even stronger relationship)
Slope = 7.55 so athletes with higher 400m times tend to have higher 1500m times.

The run400 model explains more variation (99.5% vs. 94.8%) and has a better overall fit.

Diagnostics also show fewer residual issues for the 400m model.

Therefore, run400 is the better predictor of 1500m performance";







/*Exercise 4a*/
ods text="Exercise 4a";
proc reg data=running;
   model run1500 = run100 Ljump shot Hjump run400 hurdle discus polevlt javelin / vif;
run;

* Cook distances to identify highly influential points;
proc reg data=running noprint;
	model run1500 = run100 Ljump shot Hjump run400 hurdle discus polevlt javelin;
	output out=diagnostics cookd= cd;
run;
proc print data=diagnostics;
run;


* points with Cook distance greater than threshold=4/n;
proc print data=diagnostics;
	where cd > 4/41;
run;
ods text="Obs 9,39 and 41 have high cook's distance. Therefore, they are influential points.";


* fit using output data set and removing influential point;
proc reg data=diagnostics;
	model run1500 = run100 Ljump shot Hjump run400 hurdle discus polevlt javelin;
	where cd < 4/41;
run;

ods text="R2 = 0.9981 so the model explains = 99.8% of the variability in 1500-m time.

the only clearly significant predictor is run400 (p < 0.0001). All other events have p-values > 0.05.

QQ/Residual plots: approximately normal.

keep run400 (strong, stable, highly significant predictor).

drop run100, Ljump, shot, Hjump, hurdle, discus, polevlt, javelin (all non-significant).";






/*Exercise 4b*/
ods text="Exercise 4b";
proc reg data=running;
  model run1500 = run100 Ljump shot Hjump run400 hurdle discus polevlt javelin/ selection=forward sle=0.05;
run;
ods text="run100 and run400 are the only significant predictors with p value<0.05.";


* final model;
proc reg data=running;
	model run1500 = run100 run400;
run;
ods text="R^2: 0.9965, Adj R^2=0.9963, the model explains = 99.6% of the variability in 1500-m time.

ANOVA (overall): F = 5457.7, p < .0001 so model is highly significant.

All the terms have p value < 0.05 so they are significant.

The histogram plot looks roughly normal but there can be some influential points.";


* Cook distances to identify highly influential points;
proc reg data=running noprint;
	model run1500 = run100 run400;
	output out=diag cookd= cd;
run;
proc print data=diag;
run;


* points with Cook distance greater than threshold=4/n;
proc print data=diag;
	where cd > 4/41;
run;
ods text="Obs 9,39 and 28 have high cook's distance. Therefore, they are influential points.";


* fit using output data set and removing influential point;
proc reg data=diag;
	model run1500 = run100 run400;
	where cd < 4/41;
run;

ods text="The diagnostics look better & there are no influential points.

Variation explained: R^2 = 0.9975.

run1500 = −34.24 − 11.07(run100) + 8.685(run400)."


