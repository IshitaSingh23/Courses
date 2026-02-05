data glassid;
	infile '/home/u64311722/glass-1.data' dlm=',' missover;
	input id RI Na Mg Al Si K Ca Ba Fe type;
	groupedtype = "buildingwindow";
	if type in(3,4) then groupedtype="vehiclewindow";
	if type = 5 then groupedtype="containers";
    if type = 6 then groupedtype="tableware";
	if type = 7 then groupedtype="headlamps";
	drop id type;
run;


/*EXERCISE 1*/

ods text="Exercise 1a";
proc cluster data=glassid method=average std ccc pseudo print=15 plots=all outtree=glassavg;
    var Na Mg Al Si K Ca Ba Fe;   
    copy RI groupedtype;         
    ods select ClusterHistory Dendrogram CccPsfAndPsTSqPlot;
run;

ods text="
Using average linkage on the standardized oxide levels, the CCC values remain negative (around 
-16 to -3), indicating that the glass data do not show extremely strong, well-separated 
clusters. However, the Pseudo F statistic reaches its largest value (~29.2) when there are about 
11 clusters, and the Pseudo T2 statistic shows a very large spike (~94.6) at 10 clusters, 
followed by a sharp drop. This pattern (high Pseudo F at 11 and a big Pseudo T2 jump when 
merging from 11 to 10 clusters) suggests that a solution with 11 clusters is the 
most reasonable number of clusters.";



ods text="Exercise 1b";
proc tree data=glassavg n=11 noprint out=glass11 noprint;
    copy RI groupedtype Na Mg Al Si K Ca Ba Fe;
run;


proc freq data=glass11;
    tables cluster*groupedtype / nocol norow nopercent;
run;
ods text="
The 11 cluster solution partially matches the true glass types. One very large cluster 
(Cluster 1) contains a mixture of almost all glass types, which shows that most types share 
very similar chemical compositions and are difficult to separate. In contrast, the headlamp 
glass forms a very clean and distinct group (Cluster 2), meaning this type has a unique chemical 
composition. The remaining clusters are small (1-4 observations) and represent minor chemical 
variations or outliers.
The clustering aligns well only for headlamps. The other glass types overlap too much chemically 
to form clean clusters.
";







/*EXERCISE 2*/
ods text="Exercise 2a";
proc freq data=glass11;
    tables cluster;
run;

data glass_big noprint;
    set glass11;
    if cluster >= 3 then delete;  
run;


proc anova data=glass_big;
    class cluster;
    model RI = cluster;
    means cluster / hovtest cldiff tukey;
    ods select OverallANOVA HOVFTest CLDiffs;
run;

ods text="
We fit an ANOVA model to see whether refractive index (RI) differs between the large clusters 
from Exercise 1 (clusters with 5 or more observations). Only Clusters 1 and 2 met this 
requirement. The ANOVA F-test is significant (F = 16.09, p < 0.0001), which means that including 
cluster explains more variation in RI than an error-only model. RI differs across the 
two major clusters. Levene’s test for equal variances is not significant (p = 0.1253), so the 
assumption of equal variances is reasonable and the ANOVA model is appropriate. Overall, the 
model shows that cluster membership has a statistically meaningful effect on RI.
";


ods text="Exercise 2b";
ods text="
Tukey’s test shows a significant difference in mean RI between Cluster 1 and Cluster 2. The 95% 
confidence interval for the difference does not include zero, confirming that these two 
clusters also differ in refractive index. This tells us that the cluster 
structure from Exercise 1 captures chemical differences that are also visible in RI, even 
though the clusters were formed using oxide levels and not RI directly.
However, while the difference is statistically significant, the magnitude (around 0.002 units of 
RI) is small. This means that although RI helps distinguish the clusters, the model would not 
be very strong for predicting RI from cluster membership alone.
";





/*EXERCISE 3*/

ods text="Exercise 3a";
proc stepdisc data=glassid sle=.05 sls=.05;
    class groupedtype;
    var Na Mg Al Si K Ca Ba Fe;
    ods select Summary;
run;
ods text="
The stepwise discriminant analysis adds variables one at a time based on how strongly they help 
separate the glass groups. From the output, the oxides entered in this order: Mg, Ca, K, Ba, Na, 
Al, and Si. Each of these variables had a highly significant p-value (<0.05) meaning each oxide 
contributed in meaningful separation between glass types.
The only variable removed was Mg at the final step because, after the other oxides were 
included, Mg no longer added new information.
Overall, the analysis suggests that Ca, K, Ba, Na, Al, and Si are the most useful oxides for 
distinguishing between glass types, and these are the predictors we would use in the final model.
";


ods text="Exercise 3b";
proc discrim data=glassid pool=test manova crossvalidate;
    class groupedtype;
    var Ca K Ba Na Al Si;   
    ods select ChiSq MultStat ClassifiedCrossVal ErrorCrossVal;
run;
ods text="
The test of homogeneity of covariance matrix is highly significant (Chi-Square = 1014.93, 
p < 0.0001), which means the different glass types do not share similar covariance structures. 
So, the correct model to use is Quadratic Discriminant Analysis (QDA) instead of 
LDA. QDA allows each glass group to have its own variability pattern.
The MANOVA results support this choice and show that the selected oxides do a good job 
distinguishing between the glass types. All multivariate tests are highly significant 
(p < 0.0001). This means the chemical oxide composition differs strongly across the glass 
groups, and there is clear separation.
The MANOVA confirms strong separation between glass types, and the covariance test 
tells us that QDA is the appropriate method to model these differences.
";


ods text="Exercise 3c";
proc discrim data=glassid pool=test crossvalidate;
    class groupedtype;
    var Ca K Ba Na Al Si;
    ods select ClassifiedCrossVal ErrorCrossVal;
run;
ods text="
The cross-validation results show that some glass types are much easier for the model to 
identify than others. Headlamps and tableware perform the best, with headlamps correctly 
classified about 93% of the time and tableware classified perfectly, suggesting that these 
groups have very distinct chemical oxide profiles. Containers and vehiclewindow have moderate 
accuracy, 54% and 71% respectively, their chemical compositions overlap a bit with other types 
and make them harder to separate. Buildingwindow has the poorest classification performance, 
with only about 28% correctly identified; most buildingwindow samples are misclassified as 
vehiclewindow, indicating that these two types have very similar oxide compositions. 
Overall, the model’s cross-validation error rate of about 31% shows that the selected 
oxides do a good job in distinguishing some glass types.
";





/*EXERCISE 4*/

ods text="Exercise 4a";
data glassid2;
    set glassid;

    length newgroupedtype $12;

    if groupedtype in ("buildingwindow","vehiclewindow") then newgroupedtype = "window";
    else if groupedtype in ("containers","tableware") then newgroupedtype = "glassware";
    else if groupedtype = "headlamps" then newgroupedtype = "headlamps";
run;

proc freq data=glassid2;
    tables groupedtype*newgroupedtype / nopercent norow nocol;
run;
ods text="
The building windows and vehicle windows have very similar chemical 
compositions, and containers and tableware also look very similar. When we combine the glass 
types, the frequency table confirms that the regrouping makes sense. 
All buildingwindow and vehiclewindow samples fall neatly into the new window
category, and all containers and tableware samples fall into the new glassware category. 
Headlamps remain their own separate group because they are chemically quite different from the 
others.

Based on our earlier results (Exercise 3), this claim is reasonable. Building 
and vehicle windows behaved similarly in the classification model, which suggests their oxide 
levels are close. Containers and tableware also showed similar patterns and were frequently 
misclassified between each other, meaning they share chemical characteristics too.
So, both the claims agree that these groups are similar enough to combine into broader 
categories.
";




ods text="Exercise 4b";

proc stepdisc data=glassid2 sle=.05 sls=.05;
    class newgroupedtype;
    var Na Mg Al Si K Ca Ba Fe;
    ods select Summary;
run;

proc discrim data=glassid2 pool=test crossvalidate manova;
    class newgroupedtype;
    var Mg Si K Ca Ba;
    ods select ChiSq MultStat ClassifiedCrossVal ErrorCrossVal;
run;

proc discrim data=glassid pool=test crossvalidate;
    class newgroupedtype;
    var Mg Si K Ca Ba;
    ods select ClassifiedCrossVal ErrorCrossVal;
run;

ods text="
When we repeat the discriminant analysis using the new three-group variable (glassware, 
headlamps, window), the stepwise procedure selects Mg, Ca, Ba, K, and Si as the most important 
oxides for separating the three categories. The test of equality of covariance matrices is 
highly significant (X² = 566.07, p < 0.0001), which means the groups do not share a common 
covariance structure so Quadratic Discriminant Analysis (QDA) is the appropriate model instead 
of LDA. The MANOVA results also strongly support chemical differences among the three new 
groups: Wilks’ Lambda = 0.176, F = 57.25, p < 0.0001, with all multivariate tests agreeing.

The cross-validation accuracy improves compared to Exercise 3. The new “window” 
group is classified extremely well, with 91.41% correctly identified. Headlamps are also  
highly accurate at 79.31% correct. Glassware is still the most difficult group, but even here 
the model correctly classifies 68.18% of samples. Overall, the total cross-validated error rate 
drops to 20.4%, which is a improvement over the original five-group model (31% error). 
This shows that merging the categories into broader categories produces cleaner group structure.
";





ods text="Exercise 4c";
ods text="
When we compare the new three-group model to the original five-group model, the classification 
performance improves. The improved accuracy comes from merging buildingwindow and vehiclewindow 
into one “window” group: accuracy for window glass rises from about 66% & 70% separately to 
91% correctly classified in the combined model. Headlamps also improve slightly, increasing 
from about 79% to 93% correct. Glassware is the only group that becomes harder to classify, 
dropping from roughly 76% combined accuracy (containers & tableware) in Exercise 3 to about 
68% in the three-group model. Overall, the total error rate improves from ~31% in Exercise 3 
to ~20% in the new model, which means the reduced grouping leads to cleaner chemical separation 
and better predictive accuracy.
";













