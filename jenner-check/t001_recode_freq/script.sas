/* Derived from Code.sas (McClam & Fan et al., NHANES heavy-metal analysis):
   the PROC FORMAT value catalog + the RECODING/CREATING NEW VARIABLES block
   + the recode-validation PROC FREQ crosstabs.
   The external NHANES XPT libraries (Dropbox paths) are replaced by a small
   inline block of NHANES-shaped demographic rows so the recode logic and the
   crosstab checks run against realistic values. All recode rules, format
   VALUEs, and TABLES statements are the author's, unchanged. */

data project_reproduction;
   input SEQN RIDRETH1 DMDEDUC2 DMDMARTL BMXBMI SMQ020 HIQ011 RIAGENDR RIDAGEYR;
   datalines;
83732 3 4 1 27.8 1 1 2 34
83733 3 5 3 30.5 2 1 2 41
83734 1 2 1 22.1 2 2 2 27
83735 4 3 5 35.2 1 1 2 38
83736 5 4 1 24.9 2 1 1 45
83737 2 1 6 19.4 1 2 2 22
83738 3 5 2 28.7 2 1 2 49
83739 1 3 5 21.0 1 1 2 24
83740 4 4 1 31.6 2 9 2 36
83741 3 2 4 26.3 1 1 2 44
83742 2 9 5 17.9 7 1 2 20
83743 3 5 1 23.5 2 1 2 33
83744 5 3 3 29.1 1 1 1 47
83745 1 1 5 18.2 2 2 2 21
83746 4 4 6 33.4 1 1 2 39
83747 3 3 1 25.6 2 1 2 42
83748 2 5 1 20.8 1 1 2 28
83749 3 4 2 27.0 2 7 2 46
83750 1 2 5 22.7 1 1 2 25
83751 4 . 1 . 2 1 2 40
;
run;

/*****************************************************************************************;
****         RECODING AND CREATING NEW VARIABLES = Reproduction1                     ****;
*****************************************************************************************/
data reproduction1;
set project_reproduction;

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
run;

*****************************************************************************************;
*                      FORMATS                                                          ;
*****************************************************************************************;
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
                 99= "Do not Know"
                 .= "Missing";
 VALUE DMDMARTLRf 1 = "marries/living with partner"
                  2 = "divorce/widowed/seperated"
                  3 = "never married"
                  .= "Missing";
 VALUE BMXBMIRf 1="underweight (<18.5)"
                2="normal weight (18.5-24.9)"
                3="overweight (25-29.9)"
                4="obesity (>30)"
                .="Missing";
 VALUE yesnof 1="Yes"
              2="No"
              .="Missing";
RUN;

******************************************************************************************;
****           Double checking my recording and creating new variables              ****;
******************************************************************************************;

*race;
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

*marital status;
proc freq data=reproduction1;
format DMDMARTL DMDMARTLf.
       DMDMARTLR DMDMARTLRf.;
tables DMDMARTL*DMDMARTLR/missing;
run;

*BMI;
proc freq data=reproduction1;
tables BMXBMI*BMXBMIR/missing;
format BMXBMIR BMXBMIRf.;
run;

*smoking;
proc freq data=reproduction1;
format SMQ020R yesnof.;
tables SMQ020*SMQ020R/missing;
run;

*Health Insurance;
proc freq data=reproduction1;
format HIQ011R yesnof.;
tables HIQ011*HIQ011R/missing;
run;
