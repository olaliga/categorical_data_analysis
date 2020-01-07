
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
	if fedu <= 1 then fedu_t = 0;
	if fedu = 2 then fedu_t = 1;
	if fedu = 3 then fedu_t = 2;
	if fedu = 4 then fedu_t = 3;
	if medu <= 1 then medu_t = 0;
	if medu = 2 then medu_t = 1;
	if medu = 3 then medu_t = 2;
	if medu = 4 then medu_t = 3;

 /*------------------------------------------------------------*
  *    Name: collin.sas                                        *
  *   Title: Collinearity diagnostics for nonlinear regression *
  * Version: 1.0                                               *
  *------------------------------------------------------------*/
 
%macro collin(cov=, parminfo=);

%* Macro to calculate collinearity diagnostics from ;
%*  variance-covariance matrix in nonlinear regression;

%* REF: Davis CE, Hyde JE, Bangdiwala SI, Nelson JJ.;
%*       An example of dependencies among variables in a;
%*       conditional logistic regression.  In: Moolgavkar SH,;
%*       Prentice RL, eds.  Modern statistical methods in;
%*       chronic disease epidemiology.  New York:;
%*       John Wiley & sons, inc., 1986:140-7.;

%* In your nonlinear regression program (PROC LOGISTIC or  ;
%*  PROC PHREG), specify the COVOUT and the OUTEST=SASdsn ;
%*  options in the PROC statement.  Then, specify the SAS data set;
%*  (SASdsn) in the macro variable, COV, when you invoke this macro.;

%* In PROC GENMOD, specify COVB on the MODEL statement, and
%* MAKE 'COV' out=cov, MAKE 'PARMINFO' out=parms;

%if %length(&parminfo) %then %do;
%*-- Make GENMOD COV conform to LOGISTIC/PHREG;
data &cov;
	_type_='COV';
   merge &cov(in=incov rename=(parm=_name_))
	      &parminfo;
	if incov;
%end;

%if (&cov ne ) %then %do;

%let __stop=0;

proc iml;
  use &cov;
  read all var {_name_} into _varname where(_type_='COV');
  _nrvname=nrow(_varname);
  if (_nrvname>1) then do;
*     _varnam2=_varname[2:_nrvname, ];
     nmissing=j(_nrvname,1,.);
     labels={"Eigenval","CondIndx","        "};
     _varnam2=labels//_varname;
     free _varname labels;

     read all var _varname into varcov[colname=_nvname];

     covbinv=inv(varcov);
     scale=inv(sqrt(diag(covbinv)));
     r=scale*covbinv*scale;
     call eigen(musqr,v,r);
     free r covbinv scale;

     srootmus=sqrt(musqr);
     ci=1/(srootmus/max(srootmus));
     phi=(v##2)*diag(musqr##(-1));
     sumphi=phi[,+];
     pi=phi#(sumphi##(-1));
     free phi sumphi srootmus v;
     final=(musqr||ci||nmissing||pi`)`;
     free pi musqr ci nmissing;

     _ncfinal=ncol(final);
     _nrfinal=nrow(final);
     final2=j(_nrfinal,_ncfinal,0);
     _ncfp1=_ncfinal+1;
     __vdp="VDP";
     do i=1 to _ncfinal;
        final2[,_ncfp1-i]=final[,i];
        x=char(i,3);
        y=compress(concat(__vdp,x));
        if i=1 then _vdpname=y;
           else _vdpname=_vdpname||y;
     end;
     free final _nrfinal _ncfinal i x y;
     create final2 from final2[rowname=_varnam2 colname=_vdpname];
     append from final2[rowname=_varnam2];
     free _varnam2 _vdpname final2;
  end;
  if (_nrvname=1) then do;
     x="1";
     call symput("__stop",left(x));
     print " ";
     print "**********************************************************";
     print "You need to specify the  COVOUT  option";
     print " in either PROC LOGISTIC or PROC PHREG.";
     print " This program will not calculate collinearity diagnostics.";
     print "**********************************************************";
     print " ";
  end;
  quit;
run;

%if (&__stop eq 0) %then %do;
   proc print data=final2 label noobs;
     id _varnam2;
     title3 "Collinearity diagnostics for nonlinear models using";
     title4 "the information matrix:  Eigenvalues, condition indexes,";
     title5 "and variance decomposition proportions (VDP's)";
     label _varnam2="Variable";
   run;
%end;

%end;
%else %do;
   %put;
   %put "*******************************************************";
   %put "When you invoke this macro, you have to specify the name";
   %put " of a SAS data set that contains the variance-covariance";
   %put " matrix from either PROC LOGISTIC or PROC PHREG.";
   %put;
   %put "You can create this matrix by including the following options";
   %put " on the PROC statement:  COVOUT  and  OUTEST=SASdsn,";
   %put " where SASdsn is the name of the SAS data set containing";
   %put " the variance-covariance matrix.";
   %put "*******************************************************";
   %put;
%end;
title3;

%mend collin;

/*disease = y,  exposure = romance,  control = medu_t  fedu_t paid activities*/

proc logistic data = work.math covout outset = sasdsn;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic medu_t fedu_t paid activities paid*activities;
	title 'golden standartd model';

proc logistic data = work.math;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic paid activities paid*activities;
	title ' model 8';

proc logistic data = work.math;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic  paid activities ;
	title ' model 9';

proc logistic data = work.math;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic medu_t fedu_t ;
	title ' model 10';

	proc logistic data = work.math;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic medu_t  paid activities ;
	title ' model 11';

   proc logistic data = work.math;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic  fedu_t paid activities ;
	title ' model 12';

   proc logistic data = work.math;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic  medu_t  ;
	title ' model 13';


	
   proc logistic data = work.math;
	class romantic  (ref = 'no') / PARAM=ref;
	class medu_t  (ref = '0') / PARAM=ref;
	class fedu_t  (ref = '0') / PARAM=ref;
	class paid (ref = 'no') / PARAM=ref;
	class activities (ref = 'no') / PARAM=ref;  

	model y(event='0')= romantic  fedu_t  ;
	title ' model 14';

	run;
