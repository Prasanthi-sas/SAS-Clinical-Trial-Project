
SAS crunch project:-
;

PROC IMPORT DATAFILE="C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\CDM\DEATH.xlsx" 
            DBMS=XLSX 
            OUT=death
            REPLACE;
            GETNAMES=YES;
            RUN;

PROC IMPORT DATAFILE="C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\CDM\DM.xlsx" 
            DBMS=XLSX 
            OUT=DM
            REPLACE;
            GETNAMES=YES;
            RUN;

PROC IMPORT DATAFILE="C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\CDM\DS.xlsx"
            DBMS=XLSX 
            OUT=DS
            REPLACE;
            GETNAMES=YES;
            RUN;

PROC IMPORT DATAFILE="C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\CDM\EX.xlsx"
            DBMS=XLSX 
            OUT=EX
            REPLACE;
            GETNAMES=YES;
            RUN;
PROC IMPORT DATAFILE="C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\CDM\IE.xlsx"
            DBMS=XLSX
			OUT=IE
			REPLACE;
			GETNAMES=YES;
			RUN;
PROC IMPORT DATAFILE="C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\CDM\SPCPKB1.xlsx"
            DBMS=XLSX
			OUT=SPCPKB1
			REPLACE;
			GETNAMES=YES;
			RUN;




SETUP CODE:;

options mprint mlogic;

/*Step 1: Change this to where the unzipped folder located in ur PC*/
%let Root = /folders/myfolders/Clinical Project - Part 1;



/*Step 2: Creating libraries*/
 libname CDM  "&root./data/data_sas/CDM";
 libname SDTM "&root./data/data_sas/SDTM";
 libname ADAM "&root./data/data_sas/ADAM";



/*Step 3: Creating sas data sets*/

 /*CDM datasets*/

%macro CDM (Domain= ) ;

PROC IMPORT DATAFILE= "&root./data/data_excel/CDM/&domain..xlsx"
            DBMS=XLSX OUT= CDM.&domain  ;
     GETNAMES=YES;
RUN;

%mend CDM ;

%CDM (Domain = DEATH ) ;
%CDM (Domain = DM ) ;
%CDM (Domain = DS ) ;
%CDM (Domain = EX ) ;
%CDM (Domain = IE ) ;
%CDM (Domain = SPCPKB1 ) ;


/*SDTM datasets*/

%macro SDTM (Domain= ) ;

PROC IMPORT DATAFILE= "&root./data/data_excel/SDTM/&domain..xlsx"
            DBMS=XLSX OUT= SDTM.&domain  ;
     GETNAMES=YES;
RUN;

%mend SDTM ;

%SDTM (Domain = TA ) ;.;

libname cdm "C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\CDM";
libname sdtm "C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\SDTM";
libname adam "C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\ADAM";


proc copy in=work out=Cdm;
select death dm ds ex ie spcpkb1;
run;



PROC IMPORT DATAFILE="C:\Users\ashok pc\OneDrive\Desktop\SDTMIG Guidelines\clinical_project_-_part_1\Clinical Project - Part 1\Data\Data_excel\SDTM\TA.xlsx"
            DBMS=XLSX
			OUT=TA
			REPLACE;
			GETNAMES=YES;
			RUN;


proc copy in=work out=sdtm;
select Ta;
run;








Data DM1 ;
Set CDM.DM ;

STUDYID = "XYZ" ;
DOMAIN  = "DM" ;
USUBJID = Strip(STUDYID) || "/" || Strip(Put(SUBJECT,best.)) ;

SUBJID = SUBJECT  ;
Run ;

Data SPCPKB1 ;
Set CDM.SPCPKB1 ;
Where IPFD1DAT ne " " and PSCHDAY = 1 and PART = "A";
RFSTDTC = IPFD1DAT || "T" || IPFD1TIM ;
run ;

Data EX ;
Set CDM.EX ;
if EXENDAT ne " " or EXSTDAT ne " " ;
proc sort ; By SUBJECT EXSTDAT EXENDAT ;  
run ;

Data EX1 ;
Set EX ;
By SUBJECT EXSTDAT EXENDAT ;
If last.SUBJECT ;
Run ; 

Data DM2 ;
Merge DM1 (in=a) SPCPKB1 EX1 CDM.DS CDM.DEATH (where=(DTHDESIG = "1" )) CDM.IE (where=(IEYN = "0")) ;
By SUBJECT ;
If = a ;
Run ; 

Data DM3 (rename=(ETHNIC1 =ETHNIC));
Length ETHNIC1 $60 ;
Set DM2 ;
If EXENDAT ne "" then RFENDTC = EXENDAT ;
Else If EXENDAT = "" then RFENDTC = EXSTDAT ; 
else RFENDTC = IPFD1DAT || "T" || IPFD1TIM ;

RFXSTDTC = RFSTDTC ;  
RFXENDTC = RFENDTC ; 
RFPENDTC = DSSTDAT ;
DTHDTC   = DTH_DAT ;
SITEID   = CENTRE  ;
BRTHDTC  = BRTHDAT ;
AGE = AGE ;
AGEU     = "YEARS" ; 

If DTHDTC ne " " then DTHFL = "Y" ;
If SEX='C20197' then SEX = "M" ;
Else if SEX ='C16576' then SEX = "F" ;
Else SEX = "U" ;

If RACE = 'C41260' then RACE = 'ASIAN';
If RACE = 'C41261' then RACE = 'WHITE';

If ETHNIC = 'C41222' then ETHNIC1 = 'NOT HISPANIC OR LATINO' ;

iF RFSTDTC NE " " then ARMCD = "A01-A02-A03" ;
Else if IEYN = "0" and RFSTDTC = " "  then ARMCD = "SCRNFAIL"  ;
Else ARMCD = "NOTASSGN" ;

Drop ETHNIC ;

Proc sort ; By ARMCD ;
Run ;

Data TA ;
Set SDTM.TA (keep= ARMCD ARM) ;
Proc sort nodupkey ; By ARMCD ;
Run ; 

Data DM4 ;
Merge DM3 (in=a) TA ;
By ARMCD ;
If a ;

If ARMCD = "SCRNFAIL" then ARM = "Screen Failure" ; 
If ARMCD = "NOTASSGN" then ARM = "Not Assigned" ;
Run ;

Data DM5 ;
Set DM4 ;
ACTARMCD = ARMCD ;  
ACTARM   = ARM ;

CO = put(CENTRE,6.) ;

If substr(Strip(CO),1,2) = "23" or substr(Strip(CO),1,2) = "23"  then COUNTRY = "FRA" ; 
If substr(Strip(CO),1,2) = "70" or substr(Strip(CO),1,2) = "70"  then COUNTRY = "ESP" ; 
If substr(Strip(CO),1,2) = "60" then COUNTRY = "KOR" ; 

DMDTC = VIS_DAT ;
CENTRE = CENTRE ; 
PART = PART ; 
RACEOTH = Upcase(RACEOTH) ; 
VISITDTC    = VIS_DAT  ;

run ;

Data DM6 ;
Length STUDYID $21 DOMAIN $8 USUBJID $30 SUBJID 8 RFSTDTC $19 RFENDTC $19 RFXSTDTC $19 RFXENDTC $19
   RFPENDTC $19 DTHDTC $19 DTHFL $1 SITEID 5 BRTHDTC $19 AGE 8 AGEU $10 SEX $1 RACE $60 ETHNIC $60
   ARMCD $20 ARM $200 ACTARMCD $20 ACTARM $200 COUNTRY $3 DMDTC $19 CENTRE 8 PART $1 RACEOTH $200
   VISITDTC$19 ;

Set DM5 (rename=(SEX=SEX1 SITEID = SITEID1));

Label  STUDYID ="Study Identifier"
DOMAIN ="Domain Abbreviation"
USUBJID ="Unique Subject Identifier"
SUBJID ="Subject Identifier for the Study"
RFSTDTC ="Subject Reference Start Date/Time"
RFENDTC ="Subject Reference End Date/Time"
RFXSTDTC ="Date/Time of First Study Treatment"
RFXENDTC ="Date/Time of Last Study Treatment"
RFPENDTC ="Date/Time of End of Participation"
DTHDTC ="Date/Time of Death"
DTHFL ="Subject Death Flag"
SITEID ="Study Site Identifier"
BRTHDTC ="Date/Time of Birth"
AGE ="Age"
AGEU ="Age Units"
SEX ="Sex"
RACE ="Race"
ETHNIC ="Ethnicity"
ARMCD ="Planned Arm Code"
ARM ="Description of Planned Arm"
ACTARMCD ="Actual Arm Code"
ACTARM ="Description of Actual Arm"
COUNTRY ="Country"
DMDTC ="Date/Time of Collection"
CENTRE ="Centre Number"
PART ="Study Part Code"
RACEOTH ="Other Race Specification"
VISITDTC="Date of Visit" ;

SEX = SEX1 ;
SITEID = SITEID1 ;

Keep STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFPENDTC DTHDTC DTHFL
SITEID BRTHDTC AGE AGEU SEX RACE ETHNIC ARMCD ARM ACTARMCD ACTARM COUNTRY DMDTC
CENTRE PART RACEOTH VISITDTC ;
Run ;


Data SDTM.DM ;
Set DM6 ;
Proc sort ; By USUBJID ;
Run ;
