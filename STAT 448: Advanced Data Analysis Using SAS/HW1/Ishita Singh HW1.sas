data seeds;
	infile '/home/u64311722/seeds_dataset.txt' expandtabs;
	input area perimeter compactness length width 
		asymmetry groovelength variety $;
	if variety = '1' then variety = 'Kama';
	if variety = '2' then variety = 'Rosa';
 	if variety = '3' then variety = 'Canadian';
run;



/* Exercise 1 */
ods text="Exercise 1a";
title "Basic descriptives for LENGTH";
ods select Moments BasicMeasures;
proc univariate data=seeds;
  var length;
run;
ods text="Seed lengths center around 5.6 (mean = 5.629; median = 5.524), with spread (SD = 0.443; CV ≈ 7.9%). The distribution shows a 
slight right skew (skewness = +0.525; mean > median) and kurtosis = –0.786. The middle 50% of lengths lie between 5.26 and 5.98 (IQR = 0.718), 
and overall values range from about 4.90 to 6.68 (range = 1.776).";


ods text="Exercise 1b";
title "Basic descriptives for LENGTH by VARIETY";
ods select Moments BasicMeasures;
proc univariate data=seeds;
  class variety;
  var length;
run;
ods text="Canadian seeds are the shortest (mean ≈ 5.23, median ≈ 5.224), with the smallest spread (SD ≈ 0.138, IQR ≈ 0.189, 
range ≈ 0.64) and no skew (skew ≈ +0.05). Kama seeds are mid-length (mean ≈ 5.51, median ≈ 5.534) with some variability (SD ≈ 0.232, 
IQR ≈ 0.294, range ≈ 1.15) and a slight left skew (skew ≈ −0.35). Rosa seeds are the longest and most variable (mean ≈ 6.15, median ≈ 6.149; 
SD ≈ 0.268, IQR ≈ 0.336, range ≈ 1.31) with a mild left skew (skew ≈ −0.25). Canadian seeds have the smallest variantion and Rosa seeds have 
the widest spread.";




/* Exercise 2 */
ods text="Exercise 2a";
title "Normality checks for LENGTH";
ods select TestsForNormality Histogram ProbPlot;
proc univariate data=seeds normal;
  var length;
  histogram length / normal(mu=est sigma=est) kernel;
  probplot  length / normal(mu=est sigma=est);
run;
ods text="Visually, the histogram of length is roughly bell-shaped and shows a right tail, and the Q-Q plot has a curvature away from the 
straight line. 
Quantitatively, every formal normality test strongly rejects normality: Shapiro-Wilk W = 0.9438, p < 0.0001; Kolmogorov-Smirnov D = 0.1192, 
p < 0.01; Cramér-von Mises W² = 0.6560, p < 0.005; Anderson–Darling A² = 3.8916, p < 0.005. 
Therefore, the normality assumption is not reasonable for length.";


ods text="Exercise 2b";
title "Normality checks for LENGTH by VARIETY";
ods select TestsForNormality Histogram ProbPlot;
proc univariate data=seeds normal;
  class variety;
  var length;
  histogram length / normal(mu=est sigma=est) kernel;
  probplot  length / normal(mu=est sigma=est);
run;
ods text="None of the three groups show a statistically significant deviation from normality. For Canadian seeds, all tests are nonsignificant-
Shapiro-Wilk p=0.863, K-S p>0.15, CvM/AD p>0.25 and a straight Q-Q line. Kama seeds have nonsignificant tests- Shapiro-Wilk p=0.537, K-S p>0.15, 
CvM/AD p>0.25 and the histogram/Q-Q look bell-shaped. Rosa seeds also have nonsignificant tests—Shapiro-Wilk p=0.521, K-S p>0.15, CvM/AD p>0.25 
and a linear Q-Q plot. Each variety’s seed lengths are consistent with normality.";



/* Exercise 3 */
ods text="Exercise 3a";
title "One-sample location test for LENGTH";
proc univariate data=seeds mu0=5.5;
  var length;
  ods select TestsForLocation;
run;
ods text="Since the distribution is a bit symmetric, we will use Wilcoxon signed-rank. The p-value = 0.0021 which is << 0.05. Therefore, the 
tests are highly significant and the median value differs from the hypothesized value. Since the test statistic is positive, the median is 
slightly greater than 5.5.";



ods text="Exercise 3b";
title "Test to check if Rosa is shorter than Kama";
proc ttest data=seeds sides=U h0=0;
  where variety in ("Kama","Rosa");
  class variety;         
  var length;
  ods select Equality TTests ConfLimits;
run;
ods text="The lengths are roughly normal within each variety. The two-sample t-test shows Rosa seeds are longer on average: Rosa=6.15 and 
Kama=5.51. The test gives t= -15.11 with a one-sided p-value of 1.000. Therefore, we reject the claim and conclude Rosa seeds are longer than 
Kama seeds.";



/* Exercise 4 */
ods text="Exercise 4a";
title "Correlation analysis for the area, compactness, and length variables for all of the data";
proc corr data=seeds pearson spearman;
  var area compactness length;
run;
ods text="Area and length are perfectly correlated (Pearson r≈0.95, Spearman r≈0.93; p<.0001), longer seeds have larger area. Area and 
compactness show a moderate positive link (r≈0.61), and length and compactness have a weak positive link (r≈0.37). As seed length goes up, 
area goes up a lot, and compactness tends to increase a bit";


ods text="Exercise 4b";
title "Correlation analysis by variety";
proc sort data=seeds; 
  by variety; 
run;
proc corr data=seeds pearson spearman;
  by variety;                     
  var area compactness length;    
run;
ods text="Within each variety, area and length move together strongly (bigger seeds -> larger area), just like in the full data. Area vs. 
compactness is a weak–moderate positive (strongest in Canadian, weakest in Rosa). Length vs. compactness is not positive inside varieties-
it’s near zero for Kama/Rosa and negative for Canadian.";
