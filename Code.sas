
***********************************************************************************************;
* Project: 		Blood Metal and Reproductive Dysfunction									   ;
* Author:       Maria McClam																   ;
* Program: 		nhanes.sas															   	       ;
* Date: 		September 2021                                                                 ;
*																							   ;
*																							   ;
***********************************************************************************************;




**********************************************************************************************************************************;
**** 												*LINK DATASETS* 													      ****;
**********************************************************************************************************************************;

****Read in the class data set***;

/*class data set is called 'class'*/

libname class "C:\Users\zubizarr\Dropbox\USC\PhD\DISSERTATION\CHAPTER - NHANES\SAS"; proc copy in=class out=work;run;

data class;
set class;
if sddsrvyr in (8,9,10); *8 is 2013-2014, 9 is 2015-2016, 10 is 2017-2018;
run;


***************************************************************;
*   	Regular Read in 20013-2018 Blood Metal Files           ;
***************************************************************;

*** Read in 2013-2018 Blood Metal Files ***;

/* blood metal files are called PBCD, H is 2013-2014, I is 2015-2016, J is 2017-2018 */

libname PBCD_H xport 'C:\Users\zubizarr\Dropbox\USC\PhD\DISSERTATION\CHAPTER - NHANES\SAS\PBCD_H.xpt';proc copy in=PBCD_H out=work;run;
libname PBCD_I xport 'C:\Users\zubizarr\Dropbox\USC\PhD\DISSERTATION\CHAPTER - NHANES\SAS\PBCD_I.xpt';proc copy in=PBCD_I out=work;run;
libname PBCD_J xport 'C:\Users\zubizarr\Dropbox\USC\PhD\DISSERTATION\CHAPTER - NHANES\SAS\PBCD_J.xpt';proc copy in=PBCD_J out=work;run;


******************************************************************************************;
**** 							*2013-2014* 										  ****;
******************************************************************************************;

proc contents data=pbcd_h position;
run;

data pbcdh;
set pbcd_h;
keep seqn WTSH2YR LBXBPB LBDBPBLC LBXBCD LBDBCDLC LBXTHG LBDTHGLC;
run;


******************************************************************************************;
**** 							*2015-2016* 										  ****;
******************************************************************************************;

proc contents data=pbcd_i position;
run;

data pbcdi;
set pbcd_i;
keep seqn WTSH2YR LBXBPB LBDBPBLC LBXBCD LBDBCDLC LBXTHG LBDTHGLC;
run;


******************************************************************************************;
**** 							*2017-2018* 										  ****;
******************************************************************************************;

proc contents data=pbcd_j position;
run;

data pbcdj;
set pbcd_j;
keep seqn  LBXBPB LBDBPBLC LBXBCD LBDBCDLC LBXTHG LBDTHGLC;
run;


******************************************************************************************;
**** 					*Link years for blood metal Datasets* 						  ****;
******************************************************************************************;

* Combine pdcd (blood metal) dataset from 2013-2018 ;

data pbcd_all;
 set  Pbcdh Pbcdi Pbcdj;
 run;

proc contents data = pbcd_all;
run;





**********************************************************************************************************************************;
**** 													*MERGE DATASETS* 													  ****;
**********************************************************************************************************************************;

* sort by seqn ;

proc sort data=Pbcd_all; by seqn; run;

proc sort data=class; by seqn; run;


* create permement data set with linked data ;

libname project 'C:\Users\zubizarr\Dropbox\USC\PhD\DISSERTATION\CHAPTER - NHANES\SAS'; run;

data project.all;
merge pbcd_all (in=a) class (in=b);
by seqn;
if a=1;
run;

proc contents data = project.all;
run;





**********************************************************************************************************************************;
**** 				 						 *WEIGHTING & FINAL INFERTILITY DATASET*   									      ****;
**********************************************************************************************************************************;

***Weight & creating my final reproduction data set***;

*what CDC told me to do;
data project.reproduction;
set project.all;
if sddsrvyr in (8,9) then WTSH6YR = 1/3 * WTSH2YR; /* for 2013-2016 */
else if sddsrvyr = 10 then WTSH6YR = 1/3 * WTMEC2YR; /* for 2017-2018 */
keep SEQN WTSH6YR WTSH2YR WTMEC2YR SDMVPSU SDMVSTRA LBXBPB LBDBPBLC LBXBCD LBDBCDLC LBXTHG LBDTHGLC SDDSRVYR RIAGENDR RIDAGEYR RIDRETH1 DMDEDUC2  DMDEDUC3 INDFMPIR DMDMARTL BMXBMI BMIPCT HIQ011  SMQ020 SMQ040  RHQ160 RHQ010 RHQ031 RHD043  RHQ060 RHQ074 RHQ076 RHQ131 RHD143 RHD180 RHD190 RHQ305 RHQ332 RHQ420 RHQ540;
run;


proc contents data = project.reproduction;
run;






*************************************************************************************************************************************;
****         						  *RECODING AND CREATING NEW VARIABLES = Reproduction1*    		     						 ****;
*************************************************************************************************************************************;

data reproduction1;
set project.reproduction;

 *Recoding race: 1 = hispanic, 2 = non hispanic white, 3 = NH black, 4 = NH other;
if RIDRETH1=1 or RIDRETH1=2 then RIDRETH1R=1; 
else if RIDRETH1=3 then RIDRETH1R=2;
else if RIDRETH1=4 then RIDRETH1R=3;
else if RIDRETH1=5 then RIDRETH1R=4;
else if RIDRETH1=. then RIDRETH1R=.;

* recode education variable: 1 = less than high school, 2 = high school, 3 = more than high school ;
if DMDEDUC2 in (1, 2) then DMDEDUC2R = 1;
else if DMDEDUC2 in (3) then DMDEDUC2R = 2;
else if DMDEDUC2 in (4, 5) then DMDEDUC2R = 3;
else if DMDEDUC2 in (7, 9, .) then DMDEDUC2R = .;

* recode marital status: 1 = married/living with partner, 2 = divorce/widowed/seperated, 3 = never married;
if DMDMARTL in (1, 6) then DMDMARTLR = 1;
else if DMDMARTL in (2, 3, 4) then DMDMARTLR = 2;
else if DMDMARTL in (5) then DMDMARTLR = 3;
else if DMDMARTL in (77, 99, .) then DMDMARTLR = .;

* recode BMI: 1= underweight (<18.5), 2= normal weight (18.5-24.9), 3= overweight (25-29.9), 4 = obesity (>30);
if 10 < BMXBMI <18.5 then BMXBMIR=1;
else if 18.5=< BMXBMI <25 then BMXBMIR=2;
else if 25=< BMXBMI <30 then BMXBMIR=3;
else if BMXBMI >=30 then BMXBMIR=4;
else if BMXBMI=. then BMXBMIR=.;

* re-coding missing for smoking;
if SMQ020 in (7,9,.) then SMQ020R=.;
else SMQ020R=SMQ020;

* re-coding missing for Health Insurance;
if HIQ011 in (7,9,.) then HIQ011R=.;
else HIQ011R=HIQ011;

* re-coding missing for seen a dr because unable to become pregnant;
if RHQ076 in (7,9,.) then RHQ076R=.;
else RHQ076R=RHQ076;

* re-coding missing for age at last live birth;
if RHD190 in (777,999,.) then RHD190R=.;
else RHD190R=RHD190;

* re-coding missing for had both ovaries removed;
if RHQ305 in (7,9,.) then RHQ305R=.;
else RHQ305R=RHQ305;

* re-coding missing for how many times have been pregnant;
if RHQ160 in (77,99,.) then RHQ160R=.;
else RHQ160R=RHQ160;

* re-coding missing for Ever been pregnant?;
if RHQ131 in (7,9,.) then RHQ131R=.;
else RHQ131R=RHQ131;

**************************create new variables;

* re-coding missing for ever taken birth control;
if RHQ420 in (7,9,.) then RHQ420R=.;
else RHQ420R=RHQ420;

* re-coding missing for ever used female hormone;
if RHQ540 in (7,9,.) then RHQ540R=.;
else RHQ540R=RHQ540;

*create a variable for Hormone based contraception;
if RHQ420R=1 or RHQ540R=1 then contraception=1;
else if RHQ420R=2 and RHQ540R=2 then contraception=2;
else if RHQ420R=. and  RHQ540R=. then contraception=.;

*Create Amenorrhea Variable: 1 = Amenorrhea;
*Amenorrhea is if answered “Other” or “Don’t know” to the question “What is the reason that you have not had a period in the past 12 months?”;

* re-coding missing for Reason not having regular periods;
if RHD043 in (77,.) then RHD043R=.;
else RHD043R=RHD043;

* re-coding missing for At least 1 period in past 12 months;
if RHQ031 in (7,9,.) then RHQ031R=.;
else RHQ031R=RHQ031;

*create amenorrhea;
if RHD043R in (99,9) then Amenorrhea=1;
else if RHQ031R =1 then Amenorrhea=2;
else if RHD043R in (77,.) then Amenorrhea=.;


*create Infertility variable with pregnant women as controls;

* re-coding missing for Tried for a year to become pregnant?;
if RHQ074 in (7,9.) then RHQ074R=.;
else RHQ074R=RHQ074;

* re-coding missing for Are you pregnant now?;
if RHD143 in (7,9.) then RHD143R=.;
else RHD143R=RHD143;

*create infertility;
if RHQ074R =1 then Infertility=1;
else if  RHD143 =1 then Infertility=2;
else if RHQ074R =. then Infertility=.;
else if RHD143R =. then Infertility=.;


*Creating mixed metal score named 'Mix';

Mix = (LBXBPB*0.541396631)+(LBXBCD*1)+(LBXTHG*10.88511329);        

run;


***************************************************Menopause;
*Create Menopause Variable: 1 = Premature Menopause, 2 = Early Menopause;
*women who have premature menopause as those who are under age 40 and answer "Menopause/Hysterectomy" for “Reason not having regular periods”;
*women who have early menopause as those who are age 40-45 and answer"Menopause/Hysterectomy" for “Reason not having regular periods”;
/*
if RHD043 in (77,.) then RHD043R=.;
else RHD043R=RHD043;

if RHQ031 in (7,9,.) then RHQ031R=.;
else RHQ031R=RHQ031;

if ridageyr <40 and RHD043R in (7) then Menopause=1;
else if 40=< ridageyr <=45 and RHD043R in (7) then Menopause=2;
else if RHQ031R =1 then Menopause=3;
else if RHD043R in (.) then Menopause=.;
*/
*************************************************************;






*************************************************************************************************************************************;
*                         			 						  FORMATS                                							     ;
*************************************************************************************************************************************;

PROC FORMAT;
  VALUE RIDRETH1f 1="Mexican American"
                  2="Other Hispanic"
				  3="Non-Hispanic White"
				  4="Non-Hispanic Black"
				  5="Other Race"
				  .="Missing";
 VALUE RIDRETH1Rf 1="hispanic"
 				  2="NH white"
				  3="NH black"
				  4="NH other"
				  .="missing";
 VALUE DMDEDUC2f 1= "Less Than 9th grade"
				 2= "9-11th Grade (Includes 12th grade with no diploma"
				 3= "High School Diploma (including GED)"
				 4= "Some college or AA degree"
				 5= "College graduate or above"
				 7= "Refused"
				 9= "Don't Know"
 				 .= "Missing";
 VALUE DMDEDUC2Rf 1 = "less than high school"
				  2= "high school"
				  3 = "more than high school"
	 			  .= "Missing";			
 VALUE DMDMARTLf 1= "Married"
				 2= "Widowed"
				 3= "Divorced"
				 4= "Separated"
				 5= "Never Married"
				 6= "Living with a partner"
				 77= "Refused"
				 99= "Don’t Know"
				 .= "Missing";
 VALUE DMDMARTLRf 1 = "marries/living with partner"
				  2 = "divorce/widowed/seperated"
				  3 = "never married"
				  .= "Missing";
 VALUE Infertilityf 1="Infertile"
 			    	2="Pregnant"
			        .="Missing";
 VALUE Amenorrheaf 1 = "Amenorrhea"
 				   2 = "Menstruating"
				   .="Missing";
 VALUE RIAGENDRf 1="Male"
 				 2="Female"
				 .="Missing";
 VALUE BMXBMIRf 1="underweight (<18.5)"
 			   2="normal weight (18.5-24.9)"
			   3="overweight (25-29.9)"
			   4="obesity (>30)"
			   .="Missing";
 VALUE RHD043Rf 1 = "Pregnancy"
				2="Breast feeding"
				3="Hysterectomy"
				7="Menopause/Change of Life"
				8="Medical conditions/treatments"
				9="Other"
				.="Missing";
 VALUE RHQ074Rf 1="infertile"
 			    2="fertile"
			    .="Missing";
 VALUE yesnof 1="Yes"
 			  2="No"
			  .="Missing";
 VALUE RHD143Rf 1="pregnant now"
 			   2="not pregnant now"
			   .="Missing";
 VALUE RHQ076Rf 1="seen a Dr"
 				2="not seen a Dr"
				.="Missing";
RUN;


******************************************************************************************;
****           *Double checking my recoding and creating new variables  		      ****;
******************************************************************************************;

******************** checking re-coding;

*race;
proc freq data=reproduction1;
tables RIDRETH1;
run;

proc freq data=reproduction1;
format RIDRETH1 RIDRETH1f.
	   RIDRETH1R RIDRETH1Rf.;
tables RIDRETH1*RIDRETH1R/missing;
run;

*education;
proc freq data=reproduction1;
format DMDEDUC2 DMDEDUC2f.
	   DMDEDUC2R DMDEDUC2Rf.;
tables DMDEDUC2*DMDEDUC2R/missing;
run;

*marrital status;
proc freq data=reproduction1;
format DMDMARTL DMDMARTLf.
	   DMDMARTLR DMDMARTLRf.;
tables DMDMARTL*DMDMARTLR/missing;
run;

*bmi;
proc freq data=reproduction1;
tables BMXBMI*BMXBMIR/missing;
format BMXBMIR BMXBMIR.;
run;

proc freq data=reproduction1;
tables BMXBMIR/missing;
format BMXBMIR BMXBMIRf.;
run;

*smoking; 
proc freq data=reproduction1;
format SMQ020R yesnof.;
tables SMQ020*SMQ020R/missing;
run;

*Health Insurance;
proc freq data=reproduction1;
tables HIQ011*HIQ011R/missing;
run;

*ever taken birth control;
proc freq data=reproduction1;
tables RHQ420*RHQ420R/missing;
run;

*ever used female hormone;
proc freq data=reproduction1;
tables RHQ540*RHQ540R/missing;
run;

*seen a dr because unable to become pregnant;
proc freq data=reproduction1;
tables RHQ076*RHQ076R/missing;
run;

*age at last live birth;
proc freq data=reproduction1;
tables RHD190*RHD190R/missing;
run;

*had both ovaries removed;
proc freq data=reproduction1;
tables RHQ305*RHQ305R/missing;
run;

*amenorrhea;      
proc freq data=reproduction1;
tables Amenorrhea/missing;
format Amenorrhea Amenorrheaf.;
run;

proc freq data=reproduction1;    
tables RHD043/missing;
run;

proc freq data=reproduction1;     
tables RHQ031/missing;
run;

*infertility vs prenant women;
proc freq data=reproduction1;
tables RHQ074R/missing;
run;

proc freq data=reproduction1;
tables RHD143/missing;
run;

proc freq data=reproduction1;
tables RHD143R/missing;
run;

proc freq data=reproduction1;
tables Infertility/missing;
format Infertility Infertilityf.;
run;

proc freq data=reproduction1;   /*RHD143R is are you pregnant now*/   /*there were 10 pregnant women who also said yes to trying for a year to become pregnant*/
tables RHD143R*Infertility/missing;
format Infertility Infertilityf.;
format RHD143R RHD143Rf.;
run;



proc freq data=reproduction1;   /*RHD143R is are you pregnant now*/
tables RHQ076R*Infertility/missing;
format Infertility Infertilityf.;
format RHQ076R RHQ076Rf.;
run;

proc freq data=reproduction1;   /*RHD143R is are you pregnant now    RHQ076R Seen a dr because unable to get pregnant*/
tables RHQ076R*RHD143R/missing;
format RHQ076R RHQ076Rf.;
format RHD143R RHD143Rf.;
run;

proc freq data=reproduction1;   /*RHD143R is are you pregnant now    RHQ076R Seen a dr because unable to get pregnant*/
tables RHQ076R*RHD143R/missing;		/*10 preg women who answered yes to infertile: 5 have seen a DR. for help and 5 have not*/
where RHD143R=1 and Infertility=1;
run;


*contraception;
proc freq data=reproduction1;   /*RHQ420 is ever used birth control*/
tables RHQ420R/missing;
format RHQ420R yesnof.;
run;

proc freq data=reproduction1;   /*RHQ540 is ever used female hormone*/
tables RHQ540R/missing;
format RHQ540R yesnof.;
run;

proc freq data=reproduction1;   /*checking to make sure missing was coded corectly*/
tables RHQ420R*RHQ420/missing;
format RHQ420R yesnof.;
run;

proc freq data=reproduction1;    /*checking to make sure missing was coded corectly*/
tables RHQ540R*RHQ540/missing;
format RHQ540R yesnof.;
run;

proc freq data=reproduction1;     /*checking to see what numbers should be in contraception*/
tables RHQ540R*RHQ420R/missing;
run;

proc freq data=reproduction1;     
tables contraception/missing;
format contraception yesnof.;
run;

proc freq data=reproduction1;     
tables contraception*RHQ540R/missing;
run;




************************************************************************************menopause;
/*there are only 8 people who have menopause before age 45*/
/*delete the stars at the front of code to run it, keep the semi colons at end*/

*proc freq data=reproduction1;   
*tables RHD043/missing;
*where ridageyr<45;
*run;
*proc freq data=reproduction1;    
*tables RHD043R*Menopause/missing;
*run;
*proc freq data=reproduction1;     
*tables RHQ031R*Menopause/missing;
*run;
************************************************************************************menopause;


* create permement data set with project.reproduction1 data ;

data project.reproduction1;
set reproduction1;
run;






****************************************************************************************************************************************;
**** 				      						   *INCLUSION AND EXCLUSIONS*   				             					    ****;
****************************************************************************************************************************************;

**********************************************************************;
****           	regular proc freqs for figure 1 ? 		     	  ****;
**********************************************************************;

proc freq data=reproduction1;     /*number of males vs females*/
tables RIAGENDR/missing;
run;
proc freq data=reproduction1;     /*number of males vs females <20 years old*/
tables RIAGENDR/missing;
where ridageyr<20;
run;
proc freq data=reproduction1;     /*number of males vs females >49 years old*/
tables RIAGENDR/missing;
where ridageyr>49;
run;
proc freq data=reproduction1;     /*sample size of females 20-49 years old*/
tables RIAGENDR/missing;
where ridageyr>=20 and ridageyr<=49;
run;
proc freq data=reproduction1;     /*missing # of Pb*/
tables LBXBPB/missing;
*where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing # of Cd*/
tables LBXBCD/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing # of Hg*/
tables LBXTHG/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for RIDRETH1R race*/
tables RIDRETH1R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for DMDEDUC2R education*/
tables DMDEDUC2R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for DMDMARTLR marital status*/
tables DMDMARTLR/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for BMXBMIR BMI*/
tables BMXBMIR/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for SMQ020R smoke*/
tables SMQ020R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for INDFMPIR family pir*/
tables INDFMPIR/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for HIQ011R Health Insurance*/
tables HIQ011R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for RHQ420R ever taken birth control*/
tables RHQ420R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for RHQ540R ever used female hormone*/
tables RHQ540R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for RHQ076R seen a dr because unable to become pregnant*/
tables RHQ076R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for RHQ305R had both ovaries removed*/
tables RHQ305R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for RHD190R age at last live birth*/
tables RHD190R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for RHD143R pregnancy*/
tables RHD143R/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for Amenorrhea*/
tables Amenorrhea/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;     /*missing for Infertility*/
tables Infertility/missing;
where ridageyr>=20 and ridageyr<=49 and RIAGENDR=2;
run;
proc freq data=reproduction1;		/*Reason not having regular periods */
tables RHD043R/missing;
run;



*********************************************************************;
*						creating domain statement			 		 ;
*********************************************************************;

*limit data to women age 20 - 49 by using the domain statement - NHANES requries domain statement ;
*exclude women who answer "yes" (1) to "Had both ovaries removed" (RHQ305);
*exclude missing data;
/*create the exclude/include statement that will be used in the domain statement*/

******************************************;
*                 Amenorrhea              ;
******************************************;

data amenorrhea;
set project.reproduction1;
exclude=0;

if RIAGENDR=1 then exclude=1;  /* Gender, there is no missing for sex */
else if ridageyr le 19 then exclude=2; /*Age, less than or equal to 19*/
else if ridageyr ge 50 then exclude=3; /*Age, grater than of equal to 50*/
else if RHD043R=3 then exclude=4; /*hysterectomy*/
else if LBXBPB=. or LBXBCD=. or LBXTHG=. then exclude=5;  /* Blood Metals */
else if amenorrhea=. then exclude=6;  /* missing amenorrhea */
else if RIDRETH1R=. then exclude=7;	/*race*/
else if DMDEDUC2R=. then exclude=8; /*education*/
else if INDFMPIR=. then exclude=9; /*Family PIR*/
else if DMDMARTLR=. then exclude=10; /*Marital*/
else if HIQ011R=. then exclude=11; /*Health Insurance*/
else if BMXBMIR=. then exclude=12; /*bmi*/
else if SMQ020R=. then exclude=13; /*smoke*/
else if RHQ420R=. or RHQ540R=. or contraception=. then exclude=14; /*birth control and hormones*/
else if RHQ131R=. then exclude=15; /*ever been pregnant*/

if exclude=0 then eligible=1;
else eligible=0;
run;

*to see my sample size;
proc freq data=amenorrhea; 
 tables eligible*exclude;
 run;

* create permement data set with amenorrhea data ;
data project.amenorrhea;
set amenorrhea;
run;


*****************************************;
*       Infertility vs Fertile           ;
*****************************************;

data infertilefertile;
set project.reproduction1;
exclude=0;

if RIAGENDR=1 then exclude=1;  /* Gender, there is no missing for sex */
else if ridageyr le 19 then exclude=2; /*Age, less than or equal to 19*/
else if ridageyr ge 50 then exclude=3; /*Age, grater than of equal to 50*/
else if RHD043R=3 then exclude=4; /*hysterectomy*/
else if LBXBPB=. or LBXBCD=. or LBXTHG=. then exclude=5;  /* Blood Metals */
else if RHQ074R=. then exclude=6;  /* missing infertility question */
else if RIDRETH1R=. then exclude=7;	/*race*/
else if DMDEDUC2R=. then exclude=8; /*education*/
else if INDFMPIR=. then exclude=9; /*Family PIR*/
else if DMDMARTLR=. then exclude=10; /*Marital*/
else if HIQ011R=. then exclude=11; /*Health Insurance*/
else if BMXBMIR=. then exclude=12; /*bmi*/
else if SMQ020R=. then exclude=13; /*smoke*/
else if RHQ420R=. or RHQ540R=. or contraception=. then exclude=14; /*birth control and hormones*/
else if RHQ076R=. then exclude=15; /*seen a dr because unable to be pregnant*/
else if RHQ131R=. then exclude=16; /*ever been pregnant*/

if exclude=0 then eligible=1;
else eligible=0;
run;

*to see my sample size;
proc freq data=infertilefertile; 
 tables eligible*exclude;
 run;

 * create permement data set with infertility data;
data project.infertilefertile;
set infertilefertile;
run;

*****************************************;
*        Infertility vs Preg             ;
*****************************************;

data infertilepregnant;
set project.reproduction1;
exclude=0;

if RIAGENDR=1 then exclude=1;  /* Gender, there is no missing for sex */
else if ridageyr le 19 then exclude=2; /*Age, less than or equal to 19*/
else if ridageyr ge 50 then exclude=3; /*Age, grater than of equal to 50*/
else if RHD043R=3 then exclude=4; /*hysterectomy*/
else if LBXBPB=. or LBXBCD=. or LBXTHG=. then exclude=5;  /* Blood Metals */
else if RHQ074R=. then exclude=6;  /* missing infertility question */
else if RIDRETH1R=. then exclude=7;	/*race*/
else if DMDEDUC2R=. then exclude=8; /*education*/
else if INDFMPIR=. then exclude=9; /*Family PIR*/
else if DMDMARTLR=. then exclude=10; /*Marital*/
else if HIQ011R=. then exclude=11; /*Health Insurance*/
else if BMXBMIR=. then exclude=12; /*bmi*/
else if SMQ020R=. then exclude=13; /*smoke*/
else if RHQ420R=. or RHQ540R=. or contraception=. then exclude=14; /*birth control and hormones*/
else if RHQ076R=. then exclude=15; /*seen a dr because unable to be pregnant*/
else if RHQ131R=. then exclude=16; /*ever been pregnant*/
else if infertility=. then exclude=17;  /* missing infertility defined as pregnant vs. infertile*/
/*else if infertility=1 and RHD143R=1 then exclude=18; */

if exclude=0 then eligible=1;
else eligible=0;
run;

*to see my sample size;
proc freq data=infertilepregnant; 
 tables eligible*exclude;
 run;

* create permement data set with infertility data;
data project.infertilepregnant;
set infertilepregnant;
run;




***************************************************************************************************************************************;
**** 					      	 						 *extra info*   				          								   ****;
***************************************************************************************************************************************;

title 'How Amenorrhea Differs by Infertility using freq'; 
proc freq data=infertilefertile;							/*How does the amenorrhea group differ by infertility*/
tables amenorrhea*RHQ074R/missing;
where eligible=1 and amenorrhea=.;
format amenorrhea amenorrheaf.;
format RHQ074R RHQ074Rf.;
run;

title 'How Amenorrhea Differs by Infertility using surveyfreq'; 
proc surveyfreq data = amenorrhea (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables amenorrhea*RHQ074R/ nowt row chisq;
format amenorrhea amenorrheaf.;
format RHQ074R RHQ074Rf.;
run;

title 'How Infertility Differs by Amenorrhea using surveyfreq'; 
proc surveyfreq data = amenorrhea (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables RHQ074R*amenorrhea/ nowt row chisq;
format amenorrhea amenorrheaf.;
format RHQ074R RHQ074Rf.;
run;






***********************************************************************************************************************************;
**** 					         						  *TABLE 1*   						           						   ****;
***********************************************************************************************************************************;
*******use proc tabulate or macro;
*Categorical: weighted % (unweighted n)   
Continuous: mean (standard deviation
If asymmetrical, median and percentage range (i.e., 25thand 75thpercentile)
Offer p-values (STROBE suggested to avoid p-values in Table 1). Don’t over-interpret p-values;
*when using domain statement, read from elegible=1 in the results tab on the left window ;

*************************************************************************************;
*               					TABLE 1a  AMENORRHEA            				 ;
*************************************************************************************;

***********total sample;
title 'Weighted Table 1 Amenorrhea Total Sample'; 
proc surveyfreq data = amenorrhea (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables amenorrhea / nowt row chisq;
format amenorrhea amenorrheaf.;
run;


************************************
* Amenorrhea Categorical variables *
************************************;

************total by amenorrhea;
title 'Weighted Table 1 Amenorrhea Total by Demographics'; 
proc surveyfreq data = amenorrhea (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables amenorrhea*(RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020 contraception RHQ131R)/ nowt row chisq;
format RIDRETH1R RIDRETH1Rf.;
format DMDEDUC2R DMDEDUC2Rf.;
format DMDMARTLR DMDMARTLRf.;
format BMXBMIR BMXBMIRf.;
format HIQ011R yesnof.;
format SMQ020 yesnof.;
format contraception yesnof.;
format RHQ131R yesnof.;
format amenorrhea amenorrheaf.;
run;


***********************************
* Amenorrhea Continuous variables *
**********************************;

************total sample amenorrhea;
title 'Amenorrhea: Weighted Table 1 total sample for continuous variables'; 
PROC SURVEYMEANS DATA=amenorrhea min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR RIDAGEYR INDFMPIR;
run;

*total by amenorrhea;
proc sort data=amenorrhea;
by amenorrhea;
run;

ods graphics on;
title 'Amenorrhea: Weighted Table 1 continuous variables by outcome'; 
PROC SURVEYMEANS DATA=amenorrhea nobs min mean max range median Q1 Q3;;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR RIDAGEYR INDFMPIR;
By amenorrhea;
run;
ods graphics off;

*p-values for continuous variables;
ods graphics on;
title 'Amenorrhea: P-Value for Age'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model RIDAGEYR = amenorrhea; 		/*to get p-value looking at if it varries by age group so you put age group as the outcome*/
run;
ods graphics off;

ods graphics on;
title 'Amenorrhea: P-Value for Family PIR'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model INDFMPIR = amenorrhea; 		
run;
ods graphics off;


****************************************************************************************;
*          							  TABLE 1b  INFERTILITY          				    ;
****************************************************************************************;

**************total sample for infertilefertile;
title 'Weighted Table 1 infertilefertile total sample'; 
proc surveyfreq data = infertilefertile (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables RHQ074R/ nowt row chisq;
format RHQ074R RHQ074Rf.;
run;

**************total sample for infertilepregnant;
title 'Weighted Table 1 infertilepregnant total sample'; 
proc surveyfreq data = infertilepregnant (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables infertility/ nowt row chisq;
format infertility infertilityf.;
run;


*************************************
* Infertility Categorical variables *
************************************;

**************sample by infertile fertile;
title 'Weighted Table 1 infertilefertile'; 
proc surveyfreq data = infertilefertile (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables RHQ074R*(RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020 contraception RHQ076R RHQ131R RHQ031R)/ nowt row chisq;
format RIDRETH1R RIDRETH1Rf.;
format DMDEDUC2R DMDEDUC2Rf.;
format DMDMARTLR DMDMARTLRf.;
format BMXBMIR BMXBMIRf.;
format HIQ011R yesnof.;
format SMQ020 yesnof.;
format contraception yesnof.;
format RHQ131R yesnof.;
format RHQ076R yesnof.;
format RHQ031R yesnof.;
format RHQ074R RHQ074Rf.;
run;

****************sample by infertile pregnant;
title 'Weighted Table 1 infertilepregnant'; 
proc surveyfreq data = infertilepregnant (where=(eligible=1));
cluster sdmvpsu;
strata sdmvstra;
WEIGHT WTSH6YR;
tables infertility*(RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020 contraception RHQ076R RHQ131R RHQ031R)/ nowt row chisq;
format RIDRETH1R RIDRETH1Rf.;
format DMDEDUC2R DMDEDUC2Rf.;
format DMDMARTLR DMDMARTLRf.;
format BMXBMIR BMXBMIRf.;
format HIQ011R yesnof.;
format SMQ020 yesnof.;
format contraception yesnof.;
format RHQ131R yesnof.;
format RHQ076R yesnof.;
format RHQ031R yesnof.;
format infertility infertilityf.;
run;


************************************
* Infertility Continuous variables *
***********************************;

*******************total sample infertile/fertile;
title 'Weighted Table 1 infertilefertile total sample for continuous variables'; 
PROC SURVEYMEANS DATA=infertilefertile min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR RIDAGEYR INDFMPIR;
run;

*by outcome RHQ074R;
proc sort data=infertilefertile;
by RHQ074R;
run;

title 'Weighted Table 1 infertilefertile continuous variables by outcome'; 
PROC SURVEYMEANS DATA=infertilefertile min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR RIDAGEYR INDFMPIR;
By RHQ074R;
run;


*p-values for continuous variables;
ods graphics on;
title 'Infertile Fertile: P-Value for Age'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model RIDAGEYR = RHQ074R; 		/*to get p-value looking at if it varries by age group so you put age group as the outcome*/
run;
ods graphics off;

ods graphics on;
title 'Infertile Fertile: P-Value for Family PIR'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model INDFMPIR = RHQ074R; 		
run;
ods graphics off;


****************infertile/pregnant total sample;
title 'Weighted Table 1 infertilepregnant total sample for continuous variables'; 
PROC SURVEYMEANS DATA=infertilepregnant min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR RIDAGEYR INDFMPIR;
run;

*by outcome infertility;
proc sort data=infertilepregnant;
by infertility;
run;

title 'Weighted Table 1 infertilepregnant continuous variables by outcome'; 
PROC SURVEYMEANS DATA=infertilepregnant min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR RIDAGEYR INDFMPIR;
By infertility;
run;


*p-values for continuous variables;
ods graphics on;
title 'Infertile Pregnant: P-Value for Age'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model RIDAGEYR = infertility; 		/*to get p-value looking at if it varries by age group so you put age group as the outcome*/
run;
ods graphics off;

ods graphics on;
title 'Infertile Pregnant: P-Value for Family PIR'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model INDFMPIR = infertility; 		
run;
ods graphics off;




***********************************************************************************************************************************;
*													DISTRIBUTION FOR BLOOD METAL LEVELS						 				 	   ;
***********************************************************************************************************************************;

* Distribution of all metals (not normally distributed) *;

proc univariate data = amenorrhea plot normal;  /*Proc Univariate options: PLOT option generates histogram, box, and normal probability plots*/
											 	/*NORMAL option generates statistics to test normality*/
  where eligible=1;   				 			/*WHERE statement: specify population of interest */
  var LBXBPB LBXBCD LBXTHG Mix;      			/* VAR statement: specify variable(s) for descriptive statistics */
  WEIGHT WTSH6YR; 								/*FREQ statement: specify appropriate sample weight (i.e. the exam weight, for this example)*/
  title "Distribution of total metals - amenorrhea";           
run;
*right skewed;

proc univariate data = infertilefertile plot normal;	/*Proc Univariate options: PLOT option generates histogram, box, and normal probability plots*/
											 			/*NORMAL option generates statistics to test normality*/
  where eligible=1;   				 					/*WHERE statement: specify population of interest */
  var LBXBPB LBXBCD LBXTHG Mix;      					/* VAR statement: specify variable(s) for descriptive statistics */
  WEIGHT WTSH6YR; 										/*FREQ statement: specify appropriate sample weight (i.e. the exam weight, for this example)*/
  title "Distribution of total metals - infertilefertile";           
run;
*right skewed;

proc univariate data = infertilepregnant plot normal;   /*Proc Univariate options: PLOT option generates histogram, box, and normal probability plots*/
											 			/*NORMAL option generates statistics to test normality*/
  where eligible=1;   				 					/*WHERE statement: specify population of interest */
  var LBXBPB LBXBCD LBXTHG Mix;      					/* VAR statement: specify variable(s) for descriptive statistics */
  WEIGHT WTSH6YR; 										/*FREQ statement: specify appropriate sample weight (i.e. the exam weight, for this example)*/
  title "Distribution of total metals - infertilepregnant";           
run;
*right skewed;

* A note on the use of the FREQ statement vs. the WEIGHT statement and the estimated standard deviation 
  The FREQ statement with appropriate sample weight yields an estimate of the standard deviation 
     whose denominator is an estimate of the POPULATION SIZE, i.e., the sum of the the sample weights
  The WEIGHT statement with the sample weight would instead yield an estimate of the standard deviation 
     whose denominator is the SAMPLE SIZE.;





**********************************************************************************************************************************;
*												Re-Code Blood Metals Into Quartiles												  ;
**********************************************************************************************************************************;

* recode blood metal variables to be low, med, high exposure (tertiles or quartiles);
/*Start with quintile then try quartile then tertile. Tertial usually used for small sample size*/
/*you have to create quintiles to get quartiles*/

*************************************;
*				Amenorrhea			 ;
*************************************;

*create quartiles;
Title 'Quantile cutoffs';
proc surveymeans data = amenorrhea Quantile= (0.25 0.5 0.75);
DOMAIN eligible;
var LBXBPB LBXBCD LBXTHG Mix;
run;


data amenorrhea;
set amenorrhea;
if 0 < LBXBPB =<0.388587 then LBXBPBQuartile=1;
else if 0.388587< LBXBPB =<0.549423 then LBXBPBQuartile=2;
else if 0.549423< LBXBPB =<0.830500 then LBXBPBQuartile=3;
else if LBXBPB >0.830500 then LBXBPBQuartile=4;
else if LBXBPB =. then LBXBPBQuartile=.;
run;

data amenorrhea;
set amenorrhea;
if 0 < LBXBCD =<0.175380 then LBXBCDQuartile=1;
else if 0.175380< LBXBCD =<0.283718 then LBXBCDQuartile=2;
else if 0.283718< LBXBCD =<0.505208 then LBXBCDQuartile=3;
else if LBXBCD >0.505208 then LBXBCDQuartile=4;
else if LBXBCD =. then LBXBCDQuartile=.;
run;

data amenorrhea;
set amenorrhea;
if 0 < LBXTHG =<0.344861 then LBXTHGQuartile=1;
else if 0.344861< LBXTHG =<0.675833 then LBXTHGQuartile=2;
else if 0.675833< LBXTHG =<1.386500 then LBXTHGQuartile=3;
else if LBXTHG >1.386500 then LBXTHGQuartile=4;
else if LBXTHG =. then LBXTHGQuartile=.;
run;

data amenorrhea;
set amenorrhea;
if 0 < Mix =<4.641892 then MixQuartile=1;
else if 4.641892< Mix =<8.195052 then MixQuartile=2;
else if 8.195052< Mix =<15.822432 then MixQuartile=3;
else if Mix >15.822432 then MixQuartile=4;
else if Mix =. then MixQuartile=.;
run;


*************************************;
*		Infertile Fertile			 ;
*************************************;

*create quartiles;
Title 'Quantile cutoffs';
proc surveymeans data = infertilefertile Quantile= (0.25 0.5 0.75);
DOMAIN eligible;
var LBXBPB LBXBCD LBXTHG Mix;
run;


data infertilefertile;
set infertilefertile;
if 0 < LBXBPB =<0.395875 then LBXBPBQuartile=1;
else if 0.395875< LBXBPB =<0.556290 then LBXBPBQuartile=2;
else if 0.556290< LBXBPB =<0.857813 then LBXBPBQuartile=3;
else if LBXBPB >0.857813 then LBXBPBQuartile=4;
else if LBXBPB =. then LBXBPBQuartile=.;
run;

data infertilefertile;
set infertilefertile;
if 0 < LBXBCD =<0.176543 then LBXBCDQuartile=1;
else if 0.176543< LBXBCD =<0.285244 then LBXBCDQuartile=2;
else if 0.285244< LBXBCD =<0.506875 then LBXBCDQuartile=3;
else if LBXBCD >0.506875 then LBXBCDQuartile=4;
else if LBXBCD =. then LBXBCDQuartile=.;
run;

data infertilefertile;
set infertilefertile;
if 0 < LBXTHG =<0.344605 then LBXTHGQuartile=1;
else if 0.344605< LBXTHG =<0.670714 then LBXTHGQuartile=2;
else if 0.670714< LBXTHG =<1.379063 then LBXTHGQuartile=3;
else if LBXTHG >1.379063 then LBXTHGQuartile=4;
else if LBXTHG =. then LBXTHGQuartile=.;
run;

data infertilefertile;
set infertilefertile;
if 0 < Mix =<4.641892 then MixQuartile=1;
else if 4.641892< Mix =<8.175368 then MixQuartile=2;
else if 8.175368< Mix =<15.783589 then MixQuartile=3;
else if Mix >15.783589 then MixQuartile=4;
else if Mix =. then MixQuartile=.;
run;


*************************************;
*			Infertile Preg			 ;
*************************************;

*create quartiles;
Title 'Quantile cutoffs';
proc surveymeans data = infertilepregnant Quantile= (0.25 0.5 0.75);
DOMAIN eligible;
var LBXBPB LBXBCD LBXTHG Mix;
run;


data infertilepregnant;
set infertilepregnant;
if 0 < LBXBPB =<0.363125 then LBXBPBQuartile=1;
else if 0.363125< LBXBPB =<0.549000 then LBXBPBQuartile=2;
else if 0.549000< LBXBPB =<0.777500 then LBXBPBQuartile=3;
else if LBXBPB >0.777500 then LBXBPBQuartile=4;
else if LBXBPB =. then LBXBPBQuartile=.;
run;

data infertilepregnant;
set infertilepregnant;
if 0 < LBXBCD =<0.168500 then LBXBCDQuartile=1;
else if 0.168500< LBXBCD =<0.275000 then LBXBCDQuartile=2;
else if 0.275000< LBXBCD =<0.508750 then LBXBCDQuartile=3;
else if LBXBCD >0.508750 then LBXBCDQuartile=4;
else if LBXBCD =. then LBXBCDQuartile=.;
run;

data infertilepregnant;
set infertilepregnant;
if 0 < LBXTHG =<0.358125 then LBXTHGQuartile=1;
else if 0.358125< LBXTHG =<0.627500 then LBXTHGQuartile=2;
else if 0.627500< LBXTHG =<1.197500 then LBXTHGQuartile=3;
else if LBXTHG >1.197500 then LBXTHGQuartile=4;
else if LBXTHG =. then LBXTHGQuartile=.;
run;

data infertilepregnant;
set infertilepregnant;
if 0 < Mix =<4.605909 then MixQuartile=1;
else if 4.605909< Mix =<7.979085 then MixQuartile=2;
else if 7.979085< Mix =<14.080942 then MixQuartile=3;
else if Mix >14.080942 then MixQuartile=4;
else if Mix =. then MixQuartile=.;
run;





**********************************************************************************************************************************;
	*												Log Transform Blood Metals Into Quartiles									  ;
**********************************************************************************************************************************;

data amenorrhea;
set amenorrhea;
logLBXBPB = log(LBXBPB);
logLBXBCD = log(LBXBCD);
logLBXTHG = log(LBXTHG);
logMix = log(Mix);
run;


*checking distribution with log transformed data;
proc univariate data = amenorrhea plot normal;  /*Proc Univariate options: PLOT option generates histogram, box, and normal probability plots*/
											 	/*NORMAL option generates statistics to test normality*/
  where eligible=1;   				 			/*WHERE statement: specify population of interest */
  var logLBXBPB logLBXBCD logLBXTHG logMix;      			/* VAR statement: specify variable(s) for descriptive statistics */
  WEIGHT WTSH6YR; 								/*FREQ statement: specify appropriate sample weight (i.e. the exam weight, for this example)*/
  title "Distribution of log transformed metals - amenorrhea";           
run;



data infertilefertile;
set infertilefertile;
logLBXBPB = log(LBXBPB);
logLBXBCD = log(LBXBCD);
logLBXTHG = log(LBXTHG);
logMix = log(Mix);
run;

data infertilepregnant;
set infertilepregnant;
logLBXBPB = log(LBXBPB);
logLBXBCD = log(LBXBCD);
logLBXTHG = log(LBXTHG);
logMix = log(Mix);
run;





********************************************************************************************************************************;
*																TABLE 2										  					;
********************************************************************************************************************************;

********************************************
* Amenorrhea Continuous variables (METALS) *
*******************************************;

*total sample;
title 'Amenorrhea: Weighted Table 1 Survey Means Total Sample'; 
PROC SURVEYMEANS DATA=amenorrhea min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR LBXBPB LBXBCD LBXTHG Mix;
run;

*total by amenorrhea;
proc sort data=amenorrhea;
by amenorrhea;
run;

ods graphics on;
title 'Amenorrhea: Weighted Table 1 Survey Means By Amenorrhea Status'; 
PROC SURVEYMEANS DATA=amenorrhea nobs min mean max range median Q1 Q3;;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR LBXBPB LBXBCD LBXTHG Mix;
By amenorrhea;
run;
ods graphics off;

*p-values for continuous variables;

ods graphics on;
title 'Amenorrhea: P-Value for Lead'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXBPB = amenorrhea; 	
run;
ods graphics off;

ods graphics on;
title 'Amenorrhea: P-Value for Cadmium'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXBCD = amenorrhea; 
run;
ods graphics off;

ods graphics on;
title 'Amenorrhea: P-Value for Mercury'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXTHG = amenorrhea; 
run;
ods graphics off;

ods graphics on;
title 'Amenorrhea: P-Value for Mix'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model Mix = amenorrhea; 
run;
ods graphics off;



**************************************************
* Infertile Fertile Continuous variables (METALS) *
**************************************************;

*total sample infertile/fertile;
title 'Weighted Table 1 infertilefertile'; 
PROC SURVEYMEANS DATA=infertilefertile min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR LBXBPB LBXBCD LBXTHG Mix;
run;

*by outcome RHQ074R;
proc sort data=infertilefertile;
by RHQ074R;
run;

title 'Weighted Table 1 infertilefertile'; 
PROC SURVEYMEANS DATA=infertilefertile min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR LBXBPB LBXBCD LBXTHG Mix;
By RHQ074R;
run;


*p-values for continuous variables;

ods graphics on;
title 'Infertile Fertile: P-Value for Lead'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXBPB = RHQ074R; 	
run;
ods graphics off;

ods graphics on;
title 'Infertile Fertile: P-Value for Cadmium'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXBCD = RHQ074R; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Fertile: P-Value for Mercury'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXTHG = RHQ074R; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Fertile: P-Value for Mix'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model Mix = RHQ074R; 
run;
ods graphics off;


***************************************************
* Infertile Pregnant Continuous variables (METALS)*
**************************************************;

*infertile/pregnant total sample;
title 'Weighted Table 1 infertilepregnant'; 
PROC SURVEYMEANS DATA=infertilepregnant min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR LBXBPB LBXBCD LBXTHG Mix;
run;

*by outcome infertility;
proc sort data=infertilepregnant;
by infertility;
run;

title 'Weighted Table 1 infertilepregnant'; 
PROC SURVEYMEANS DATA=infertilepregnant min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR LBXBPB LBXBCD LBXTHG Mix;
By infertility;
run;


*p-values for continuous variables;

ods graphics on;
title 'Infertile Pregnant: P-Value for Lead'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXBPB = infertility; 	
run;
ods graphics off;

ods graphics on;
title 'Infertile Pregnant: P-Value for Cadmium'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXBCD = infertility; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Pregnant: P-Value for Mercury'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model LBXTHG = infertility; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Pregnant: P-Value for Mix'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model Mix = infertility; 
run;
ods graphics off;


********************************************************************************************;
*										TABLE 2 LOG TRANSFORMED								;
********************************************************************************************;

************************************************************
* Amenorrhea Continuous variables (LOG TRANSFORMED METALS) *
***********************************************************;

*total sample;
title 'Amenorrhea: Weighted Table 1 Survey Means Total Sample'; 
PROC SURVEYMEANS DATA=amenorrhea min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR logLBXBPB logLBXBCD logLBXTHG logMix;
run;

*total by amenorrhea;
proc sort data=amenorrhea;
by amenorrhea;
run;

ods graphics on;
title 'Amenorrhea: Weighted Table 1 Survey Means By Amenorrhea Status'; 
PROC SURVEYMEANS DATA=amenorrhea nobs min mean max range median Q1 Q3;;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR logLBXBPB logLBXBCD logLBXTHG logMix;
By amenorrhea;
run;
ods graphics off;

*p-values for continuous variables;

ods graphics on;
title 'Amenorrhea: P-Value for Lead'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXBPB = amenorrhea; 	
run;
ods graphics off;

ods graphics on;
title 'Amenorrhea: P-Value for Cadmium'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXBCD = amenorrhea; 
run;
ods graphics off;

ods graphics on;
title 'Amenorrhea: P-Value for Mercury'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXTHG = amenorrhea; 
run;
ods graphics off;

ods graphics on;
title 'Amenorrhea: P-Value for Mix'; 
proc surveyreg data = amenorrhea;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logMix = amenorrhea; 
run;
ods graphics off;



**************************************************
* Infertile Fertile Continuous variables (METALS) *
**************************************************;

*total sample infertile/fertile;
title 'Weighted Table 1 infertilefertile'; 
PROC SURVEYMEANS DATA=infertilefertile min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR logLBXBPB logLBXBCD logLBXTHG logMix;
run;

*by outcome RHQ074R;
proc sort data=infertilefertile;
by RHQ074R;
run;

title 'Weighted Table 1 infertilefertile'; 
PROC SURVEYMEANS DATA=infertilefertile min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR logLBXBPB logLBXBCD logLBXTHG logMix;
By RHQ074R;
run;


*p-values for continuous variables;

ods graphics on;
title 'Infertile Fertile: P-Value for Lead'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXBPB = RHQ074R; 	
run;
ods graphics off;

ods graphics on;
title 'Infertile Fertile: P-Value for Cadmium'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXBCD = RHQ074R; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Fertile: P-Value for Mercury'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXTHG = RHQ074R; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Fertile: P-Value for Mix'; 
proc surveyreg data = infertilefertile;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logMix = RHQ074R; 
run;
ods graphics off;


***************************************************
* Infertile Pregnant Continuous variables (METALS)*
**************************************************;

*infertile/pregnant total sample;
title 'Weighted Table 1 infertilepregnant'; 
PROC SURVEYMEANS DATA=infertilepregnant min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR logLBXBPB logLBXBCD logLBXTHG logMix;
run;

*by outcome infertility;
proc sort data=infertilepregnant;
by infertility;
run;

title 'Weighted Table 1 infertilepregnant'; 
PROC SURVEYMEANS DATA=infertilepregnant min mean max range median Q1 Q3;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
DOMAIN eligible;
VAR logLBXBPB logLBXBCD logLBXTHG logMix;
By infertility;
run;



*p-values for continuous variables;

ods graphics on;
title 'Infertile Pregnant: P-Value for Lead'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXBPB = infertility; 	
run;
ods graphics off;

ods graphics on;
title 'Infertile Pregnant: P-Value for Cadmium'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXBCD = infertility; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Pregnant: P-Value for Mercury'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logLBXTHG = infertility; 
run;
ods graphics off;

ods graphics on;
title 'Infertile Pregnant: P-Value for Mix'; 
proc surveyreg data = infertilepregnant;
WEIGHT WTSH6YR;
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
DOMAIN eligible;
model logMix = infertility; 
run;
ods graphics off;






***********************************************************************************************************************************;
*** 												LOGISTIC REGRESSION MODELS 													***;
***********************************************************************************************************************************;


**************************************************************************************;
**** 		                 *TABLE 3 : CRUDE  MODELS             	      		  ****;
**************************************************************************************;


***********************amenorrhea;

*crude model amenorrhea and Pb logLBXBPB;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model /*outcome*/ amenorrhea (ref='2') = /*exposure*/ logLBXBPB / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;
					/*L=GLOGIT specifies the generalized logit function, fits the generalized logit model where each nonreference category is contrasted with the reference category
					expb displays the estimated odds ratios for the parameters corresponding to the continuous explanatory variables
					clodds requests confidence intervals for the odds ratios
					rsquare requests a generalized  measure for the fitted model*/

*crude model amenorrhea and Pb LBXBPBQuartile;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1'); 	/*list all demographic variables in the CLASS statement to indicate that they are categorical independent variables in the MODEL statement*/
model amenorrhea (ref='2') = LBXBPBQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model amenorrhea and Cd logLBXBCD;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model amenorrhea (ref='2') = logLBXBCD / L=GLOGIT expb clodds rsquare; 
run;

*crude model amenorrhea and Cd LBXBCDQuartile;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1');
model amenorrhea (ref='2') = LBXBCDQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model amenorrhea and Hg logLBXTHG;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model amenorrhea (ref='2') = logLBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*crude model amenorrhea and Hg LBXTHGQuartile;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1');
model amenorrhea (ref='2') = LBXTHGQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model amenorrhea and Mix logMix;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model amenorrhea (ref='2') = logMix / L=GLOGIT expb clodds rsquare; 
run;

*crude model amenorrhea and Mix MixQuartile;
proc surveylogistic data =amenorrhea;
title 'crude model amenorrhea and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1');
model amenorrhea (ref='2') = MixQuartile / L=GLOGIT expb clodds rsquare; 
run;



********************infertilie fertile;

*crude model InfertileFertile and Pb logLBXBPB;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model RHQ074R (ref='2') = logLBXBPB / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertileFertile and Pb LBXBPBQuartile;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1'); 	
model RHQ074R (ref='2') = LBXBPBQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model InfertileFertile and Cd logLBXBCD;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model RHQ074R (ref='2') = logLBXBCD / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertileFertile and Cd LBXBCDQuartile;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1'); 	
model RHQ074R (ref='2') = LBXBCDQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model InfertileFertile and Hg logLBXTHG;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model RHQ074R (ref='2') = logLBXTHG / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertileFertile and Hg LBXTHGQuartile;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1'); 	
model RHQ074R (ref='2') = LBXTHGQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model InfertileFertile and Mix logMix;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model RHQ074R (ref='2') = logMix / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertileFertile and Mix MixQuartile;
proc surveylogistic data =infertilefertile;
title 'crude model InfertileFertile and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1'); 	
model RHQ074R (ref='2') = MixQuartile / L=GLOGIT expb clodds rsquare; 
run;



*******************Infertile Pregnant;

*crude model InfertilePregnant and Pb logLBXBPB;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model infertility (ref='2') = logLBXBPB / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertilePregnant and Pb LBXBPBQuartile;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1'); 	
model infertility (ref='2') = LBXBPBQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model InfertilePregnant and Cd logLBXBCD;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model infertility (ref='2') = logLBXBCD / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertilePregnant and Cd LBXBCDQuartile;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1'); 	
model infertility (ref='2') = LBXBCDQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model InfertilePregnant and Hg logLBXTHG;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model infertility (ref='2') = logLBXTHG / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertilePregnant and Hg LBXTHGQuartile;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1'); 	
model infertility (ref='2') = LBXTHGQuartile / L=GLOGIT expb clodds rsquare; 
run;

*crude model InfertilePregnant and Mix logMix;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
model infertility (ref='2') = logMix / L=GLOGIT expb clodds rsquare; /*outcome = exposure co-variates*/
run;

*crude model InfertilePregnant and Mix MixQuartile;
proc surveylogistic data =infertilepregnant;
title 'crude model InfertilePregnant and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1'); 	
model infertility (ref='2') = MixQuartile / L=GLOGIT expb clodds rsquare; 
run;





**********************************************************************************************************;
**** 		            			     *TABLE 4 : ADJUSTED  MODELS             	    		  	  ****;
**********************************************************************************************************;

*adjust for all demographic variables and for other metals (not mix);

***************************Amenorrhea**************************;

***********Amenorrhea & PB;

*adjusted model amenorrhea and Pb logLBXBPB  -  with designated reference groups;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R (param=ref ref='2') DMDEDUC2R (param=ref ref='1') DMDMARTLR (param=ref ref='3') BMXBMIR (param=ref ref='2') HIQ011R (param=ref ref='1') SMQ020R (param=ref ref='2') contraception (param=ref ref='1') RHQ131R (param=ref ref='2'); /* if you want to select reference group:  (param=ref ref='2') */
model amenorrhea (ref='2') = logLBXBPB RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Pb logLBXBPB  -  just checking to see if designating a reference group makes a difference... it doesn't;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /* if you want to select reference group:  (param=ref ref='2') */
model amenorrhea (ref='2') = logLBXBPB RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Pb LBXBPBQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = LBXBPBQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare;
run;


***********Amenorrhea & CD;

*adjusted model amenorrhea and Cd logLBXBCD;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /*catagorical variables go in class statement*/
model amenorrhea (ref='2') = logLBXBCD RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Cd LBXBCDQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = LBXBCDQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXTHG / L=GLOGIT expb clodds rsquare;
run;


***********Amenorrhea & HG;

*adjusted model amenorrhea and Hg logLBXTHG;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /*catagorical variables go in class statement*/
model amenorrhea (ref='2') = logLBXTHG RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Hg LBXTHGQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = LBXTHGQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD / L=GLOGIT expb clodds rsquare;
run;


***********Amenorrhea & Mix;

*adjusted model amenorrhea and Mix logMix;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /*catagorical variables go in class statement*/
model amenorrhea (ref='2') = logMix RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Mix MixQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = MixQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare;
run;



***************************InfertileFertile**************************;

***********InfertileFertile & PB;

*adjusted model InfertileFertile and Pb logLBXBPB;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logLBXBPB RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Pb LBXBPBQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = LBXBPBQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;


***********InfertileFertile & CD;

*adjusted model InfertileFertile and Cd logLBXBCD;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logLBXBCD RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Cd LBXBCDQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = LBXBCDQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXTHG / L=GLOGIT expb clodds rsquare; 
run;


***********InfertileFertile & HG;

*adjusted model InfertileFertile and Hg logLBXTHG;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logLBXTHG RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Hg LBXTHGQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = LBXTHGQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD / L=GLOGIT expb clodds rsquare; 
run;


***********InfertileFertile & Mix;

*adjusted model InfertileFertile and Mix logMix;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logMix RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Mix MixQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = MixQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;



***************************InfertilePregnant**************************;

***********InfertilePregnant & PB;

*adjusted model InfertilePregnant and Pb logLBXBPB;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logLBXBPB RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Pb LBXBPBQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = LBXBPBQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;


***********InfertilePregnant & CD;

*adjusted model InfertilePregnant and Cd logLBXBCD;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logLBXBCD RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Cd LBXBCDQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = LBXBCDQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXTHG / L=GLOGIT expb clodds rsquare; 
run;


***********InfertilePregnant & HG;

*adjusted model InfertilePregnant and Hg logLBXTHG;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logLBXTHG RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Hg LBXTHGQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = LBXTHGQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD / L=GLOGIT expb clodds rsquare; 
run;


***********InfertilePregnant & Mix;

*adjusted model InfertilePregnant and Mix logMix;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logMix RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Mix MixQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = MixQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR /*metals*/ LBXBPB LBXBCD LBXTHG / L=GLOGIT expb clodds rsquare; 
run;




***********************************************************INFO ABOUT MODELS*******************************************************************;


***************************;
*     AMENORRHEA           ;
***************************;

/* amenorrhea
Outcome: amenorrhea
Exposure: LBXBPB LBXBCD LBXTHG Mix
Co-variates - catagorical: RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R
Co-variates - continuous: RIDAGEYR  INDFMPIR
format RIDRETH1R RIDRETH1Rf.;
format DMDEDUC2R DMDEDUC2Rf.;
format DMDMARTLR DMDMARTLRf.;
format BMXBMIR BMXBMIRf.;
format HIQ011R yesnof.;
format SMQ020 yesnof.;
format RHQ420R yesnof.;
format RHQ540R yesnof.;
format RHQ131R yesnof.;
format amenorrhea amenorrheaf.;
*/

*******************************;
*        Infertilefertile      ;
*******************************;

/*infertilefertile
Outcome: RHQ074R
Exposure: LBXBPB LBXBCD LBXTHG Mix
Co-variates - catagorical: RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R
Co-variates - continuous: RIDAGEYR  INDFMPIR
format RIDRETH1R RIDRETH1Rf.;
format DMDEDUC2R DMDEDUC2Rf.;
format DMDMARTLR DMDMARTLRf.;
format BMXBMIR BMXBMIRf.;
format HIQ011R yesnof.;
format SMQ020 yesnof.;
format RHQ420R yesnof.;
format RHQ540R yesnof.;
format RHQ131R yesnof.;
format RHQ076R yesnof.;
format RHQ031R yesnof.;
format RHQ074R RHQ074Rf.;
*/

**********************************;
*        Infertilepregnant  	  ;
**********************************;

/* infertilepregnant
Outcome: infertility
Exposure: LBXBPB LBXBCD LBXTHG Mix
Co-variates - catagorical: RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R
Co-variates - continuous: RIDAGEYR  INDFMPIR
format RIDRETH1R RIDRETH1Rf.;
format DMDEDUC2R DMDEDUC2Rf.;
format DMDMARTLR DMDMARTLRf.;
format BMXBMIR BMXBMIRf.;
format HIQ011R yesnof.;
format SMQ020 yesnof.;
format RHQ420R yesnof.;
format RHQ540R yesnof.;
format RHQ131R yesnof.;
format RHQ076R yesnof.;
format RHQ031R yesnof.;
format infertility infertilityf.;
*/





******************************************************************************************************************;
**** 		                TABLE 5: MODEL WITHOUT ADJUSTING FOR OTHER METALS             	    		  	  ****;
******************************************************************************************************************;

***************************Amenorrhea**************************;

***********Amenorrhea & PB;

*adjusted model amenorrhea and Pb logLBXBPB  -  just checking to see if designating a reference group makes a difference... it doesn't;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /* if you want to select reference group:  (param=ref ref='2') */
model amenorrhea (ref='2') = logLBXBPB RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Pb LBXBPBQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = LBXBPBQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare;
run;


***********Amenorrhea & CD;

*adjusted model amenorrhea and Cd logLBXBCD;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /*catagorical variables go in class statement*/
model amenorrhea (ref='2') = logLBXBCD RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Cd LBXBCDQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = LBXBCDQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare;
run;


***********Amenorrhea & HG;

*adjusted model amenorrhea and Hg logLBXTHG;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /*catagorical variables go in class statement*/
model amenorrhea (ref='2') = logLBXTHG RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Hg LBXTHGQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = LBXTHGQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare;
run;


***********Amenorrhea & Mix;

*adjusted model amenorrhea and Mix logMix;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R; /*catagorical variables go in class statement*/
model amenorrhea (ref='2') = logMix RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model amenorrhea and Mix MixQuartile;
proc surveylogistic data = amenorrhea;
title 'adjusted model amenorrhea and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R;
model amenorrhea (ref='2') = MixQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare;
run;



***************************InfertileFertile**************************;

***********InfertileFertile & PB;

*adjusted model InfertileFertile and Pb logLBXBPB;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logLBXBPB RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Pb LBXBPBQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = LBXBPBQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;


***********InfertileFertile & CD;

*adjusted model InfertileFertile and Cd logLBXBCD;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logLBXBCD RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Cd LBXBCDQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = LBXBCDQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;


***********InfertileFertile & HG;

*adjusted model InfertileFertile and Hg logLBXTHG;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logLBXTHG RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Hg LBXTHGQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = LBXTHGQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;


***********InfertileFertile & Mix;

*adjusted model InfertileFertile and Mix logMix;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = logMix RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertileFertile and Mix MixQuartile;
proc surveylogistic data = infertilefertile;
title 'adjusted model InfertileFertile and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model RHQ074R (ref='2') = MixQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;



***************************InfertilePregnant**************************;

***********InfertilePregnant & PB;

*adjusted model InfertilePregnant and Pb logLBXBPB;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Pb logLBXBPB';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logLBXBPB RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Pb LBXBPBQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Pb LBXBPBQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBPBQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = LBXBPBQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;


***********InfertilePregnant & CD;

*adjusted model InfertilePregnant and Cd logLBXBCD;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Cd logLBXBCD';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logLBXBCD RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Cd LBXBCDQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Cd LBXBCDQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXBCDQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = LBXBCDQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;


***********InfertilePregnant & HG;

*adjusted model InfertilePregnant and Hg logLBXTHG;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Hg logLBXTHG';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logLBXTHG RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Hg LBXTHGQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Hg LBXTHGQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class LBXTHGQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = LBXTHGQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;


***********InfertilePregnant & Mix;

*adjusted model InfertilePregnant and Mix logMix;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Mix logMix';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = logMix RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;

*adjusted model InfertilePregnant and Mix MixQuartile;
proc surveylogistic data = infertilepregnant;
title 'adjusted model InfertilePregnant and Mix MixQuartile';
CLUSTER SDMVPSU;
STRATA SDMVSTRA;
WEIGHT WTSH6YR;
domain eligible;
class MixQuartile (param=ref ref='1') RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R;
model infertility (ref='2') = MixQuartile RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR HIQ011R SMQ020R contraception RHQ131R RHQ076R RHQ031R RIDAGEYR INDFMPIR / L=GLOGIT expb clodds rsquare; 
run;







***********************************************************ADDITIONAL ANALYSIS*******************************************************************;

*difference in infertility status among women who may have seen a doctor and gotten assistance to become pregnant vs. 
those who did not. ;

title 'How Infertility Differs by Seen a DR using freq'; 
proc freq data=infertilefertile;
tables RHQ074R*RHQ076R /missing;
where eligible=1;
format RHQ076R RHQ076Rf.;
format RHQ074R RHQ074Rf.;
run;

title 'How Infertility Differs by Seen a DR using freq'; 
proc freq data=infertilepregnant;
tables infertility*RHQ076R /missing;
where eligible=1;
format RHQ076R RHQ076Rf.;
format infertility infertilityf.;
run;
