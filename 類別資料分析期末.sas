
PROC IMPORT OUT= WORK.Math 
            DATAFILE= "C:\Users\FINANCE\Desktop\student_new\student_math.txt" 
            DBMS=TAB REPLACE;
  		   GETNAMES=YES;
 		    DATAROW=2;

 /* NEW VAR aver*/
data work.math;
	set work.math;
	average_score = (g1+g2+g3)/3;
	if (g1+g2+g3)/3  >= 12 then y = 1;
	if (g1+g2+g3)/3 < 12  then y = 0; 


 /*data summary for discussion*/
/*
proc univariate  data =work.math noprint;
	histogram age absences aver;
	title'Histogram';

proc sgplot data=work.math;
	vbox age; 
	title 'Boxplot of age';

proc sgplot data=work.math;
	vbox absences; 
	title 'Boxplot of absences';

proc sgplot data=work.math;
	vbox G1; 
	title 'Boxplot of G1';

proc sgplot data=work.math;
	vbox G2; 
	title 'Boxplot of G2';

proc sgplot data=work.math;
	vbox G3; 
	title 'Boxplot of G3';
		


proc gchart data=work.math;
	vbar  school sex address famsize Pstatus Medu Fedu Mjob Fjob 
			reason guardian traveltime studytime failures schoolsup famsup
			paid activities nursery higher internet romantic famrel freetime goout Dalc Walc health ;
			title 'bar chart';

proc gchart data=work.math;
	pie school sex address famsize Pstatus Medu Fedu Mjob Fjob 
			reason guardian traveltime studytime failures schoolsup famsup
			paid activities nursery higher internet romantic famrel freetime goout Dalc Walc health/ 
		discrete
		type=sum
        legend =1
        slice=outside
        percent= inside
        value=outside
        other=4
        otherlabel="other"
        coutline=black;
		title 'pie chart';
RUN;

quit; 

*/
/*data summary for report*/

	/*
filename grafout 'C:\Users\FINANCE\Desktop\student_new';
ods listing style=listing;
goptions  device=png   gsfname=grafout gsfmode=replace  htitle=16pt htext = 12pt ; 
*/

proc univariate  data =work.math noprint;
	histogram  average_score;
	title'Histogram of Average Score';

proc sgplot data=work.math;
	vbox average_score; 
	title 'Boxplot of Average Score';

proc gchart data=work.math;
	vbar y  romantic Medu Fedu	paid activities/discrete ;
			title 'Bar Chart';

proc gchart data=work.math;
	pie y romantic Medu Fedu paid activities / 
		discrete
		type=freq
		legend 
        slice=outside
        percent= inside
        value=outside
        other=4
        otherlabel="other"
        coutline=black
		noheading;

		title 'Pie Chart';
RUN;
data work.math;
	set work.math;
	if fedu <= 1 then fedu_t = 0;
	if fedu = 2 then fedu_t = 1;
	if fedu = 3 then fedu_t = 2;
	if fedu = 4 then fedu_t = 3;
	if medu <= 1 then medu_t = 0;
	if medu = 2 then medu_t = 1;
	if medu = 3 then medu_t = 2;
	if medu = 4 then medu_t = 3;

proc freq data=work.math;
	tables  fedu_t*medu_t/ plots = mosaic;
	title 'fedu v.s. medu';
run;

proc corr data=work.math spearman;
	VAR medu_t fedu_t;
	title 'fedu v.s. medu correlation';
	run;
