/* NHANES-shaped survey-design analysis dataset standing in for the external
   XPT-derived project.amenorrhea (the raw NHANES files live at Dropbox paths
   not in the repo). Columns and design variables (SDMVPSU, SDMVSTRA, WTSH6YR)
   match what Code.sas builds; eligible=1 is the analytic domain. The mixed-
   metal score Mix uses the author's exact weights from Code.sas. */
data amenorrhea;
   input SEQN SDMVSTRA SDMVPSU WTSH6YR RIDAGEYR INDFMPIR
         LBXBPB LBXBCD LBXTHG Mix
         RIDRETH1R DMDEDUC2R DMDMARTLR BMXBMIR SMQ020 HIQ011R
         contraception amenorrhea RHQ074R RHQ131R;
   eligible = 1;
   datalines;
90001 1 1 33837.08 25 3.79 1.203 0.636 3.242 36.5768 4 3 2 1 2 2 1 2 1 2
90002 1 1 30053.19 33 4.08 1.791 0.91 1.527 18.5012 4 3 3 3 2 2 1 2 2 1
90003 1 1 22133.18 45 3.8 0.339 1.166 1.287 15.3587 1 2 1 3 2 1 1 2 2 2
90004 1 1 55299.33 34 2.26 1.047 0.756 3.328 37.5485 1 2 2 3 2 2 1 2 2 1
90005 1 1 42351.05 32 4.86 0.396 0.764 0.76 9.2511 4 3 1 1 1 2 2 2 2 2
90006 1 1 20081.28 28 3.26 0.704 0.902 0.589 7.6945 3 2 3 1 2 1 1 2 1 2
90007 1 1 58651.03 38 1.93 2.447 0.986 0.803 11.0515 3 2 1 3 1 2 2 1 1 2
90008 1 1 12096.83 26 2.24 0.807 1.305 1.301 15.9034 4 3 3 4 1 1 2 1 1 1
90009 1 1 21425.36 36 1.73 2.051 1.06 1.691 20.5771 4 1 2 1 1 1 1 1 2 1
90010 1 1 41038.28 40 1.22 2.274 1.071 2.859 33.4227 1 1 1 3 1 1 2 2 1 2
90011 1 2 19621.66 22 3.67 2.47 1.285 2.673 31.7182 3 1 2 1 1 1 1 2 1 2
90012 1 2 17055.22 26 3.4 1.243 0.337 3.833 42.7326 2 2 2 1 1 1 1 1 2 2
90013 1 2 50043.99 21 3.18 2.332 0.625 0.297 5.1204 2 2 3 1 1 2 2 1 2 1
90014 1 2 28353.72 23 2.35 1.998 1.181 0.454 7.2046 1 3 3 3 1 1 1 1 2 2
90015 1 2 26875.01 21 1.9 2.433 1.413 3.969 45.9332 2 2 1 2 2 2 1 1 2 2
90016 1 2 29101.11 33 4.05 0.908 0.784 0.321 4.7697 1 2 3 4 2 1 2 2 2 2
90017 1 2 56929.02 29 4.33 2.455 1.499 1.648 20.7668 3 3 1 2 1 2 2 1 1 2
90018 1 2 33080.31 38 0.57 1.446 1.128 2.841 32.8355 2 1 1 3 2 2 2 2 1 1
90019 1 2 50330.86 35 3.43 2.138 0.725 2.389 27.887 2 3 2 3 2 2 1 2 2 1
90020 1 2 28658.73 20 0.62 1.53 1.353 2.958 34.3795 4 1 3 4 1 1 2 2 1 2
90021 1 2 8094.59 30 2.59 2.456 0.466 0.662 9.0016 4 2 2 4 1 1 1 1 1 2
90022 2 1 36082.17 32 1.62 0.979 0.142 2.17 24.2927 4 2 1 1 2 2 1 1 2 1
90023 2 1 55572.71 44 3.57 2.271 0.633 2.21 25.9186 1 1 2 2 1 2 1 2 1 1
90024 2 1 14692.7 36 4.06 0.839 1.498 0.334 5.5879 2 1 2 1 2 2 2 1 1 1
90025 2 1 57651.71 46 1.51 0.583 1.323 0.978 12.2843 3 1 2 3 1 1 1 2 2 1
90026 2 1 12588.48 33 1.06 2.204 0.87 2.716 31.6272 2 3 3 4 1 1 2 2 1 2
90027 2 1 19695.66 30 0.91 2.379 0.885 1.3 16.3236 4 2 2 2 2 2 2 2 2 1
90028 2 1 37761.57 39 0.57 1.732 0.796 2.815 32.3753 1 3 1 3 1 2 1 2 2 2
90029 2 1 25754.59 29 3.0 2.221 1.107 1.392 17.4615 4 1 2 1 2 1 1 2 2 1
90030 2 1 41926.86 22 3.17 2.093 0.385 2.625 30.0916 3 2 2 4 2 2 1 2 1 2
90031 2 1 50411.19 22 2.43 0.567 1.061 3.479 39.2373 1 2 2 1 2 2 1 1 1 1
90032 2 1 35633.68 22 4.08 1.971 0.815 3.236 37.1063 2 3 3 2 2 2 1 1 1 1
90033 2 2 27459.8 26 3.08 0.431 0.623 2.868 32.0748 2 2 1 4 2 1 2 1 1 2
90034 2 2 45731.28 39 1.5 2.253 0.15 1.362 16.1953 1 2 3 3 2 2 2 1 1 2
90035 2 2 24224.73 22 0.57 2.27 0.832 2.337 27.4995 2 1 3 3 1 1 2 2 2 2
90036 2 2 17107.58 35 3.88 0.864 0.221 0.999 11.563 1 2 1 2 2 2 1 1 2 2
90037 2 2 43757.25 49 0.6 1.951 0.667 2.128 24.8868 3 1 1 1 1 2 2 2 1 2
90038 2 2 23166.0 29 0.76 0.656 0.722 0.652 8.1743 2 2 1 1 2 2 1 1 1 2
90039 2 2 52652.78 40 4.38 0.693 0.817 1.19 14.1455 2 2 1 3 2 1 2 2 1 2
90040 2 2 21381.22 24 1.93 0.958 0.719 1.144 13.6902 2 1 1 3 1 1 1 1 1 2
90041 2 2 21527.62 49 0.59 1.495 0.229 2.499 28.2403 3 3 1 4 1 1 1 2 1 2
90042 2 2 34173.97 43 3.26 1.609 1.114 0.768 10.3449 4 1 2 3 2 1 1 2 2 2
;
run;

/*****************************************************************************************;
****           Formats used by the Table 1 crosstab (subset from Code.sas)           ****;
*****************************************************************************************/
proc format;
 value RIDRETH1Rf 1="hispanic" 2="NH white" 3="NH black" 4="NH other" .="missing";
 value DMDEDUC2Rf 1="less than high school" 2="high school" 3="more than high school" .="Missing";
 value DMDMARTLRf 1="marries/living with partner" 2="divorce/widowed/seperated" 3="never married" .="Missing";
 value BMXBMIRf 1="underweight (<18.5)" 2="normal weight (18.5-24.9)" 3="overweight (25-29.9)" 4="obesity (>30)" .="Missing";
 value yesnof 1="Yes" 2="No" .="Missing";
 value amenorrheaf 1="Amenorrhea" 2="Menstruating" .="Missing";
run;

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
