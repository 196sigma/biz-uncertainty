libname home 'C:\Users\Reginald\Dropbox\Research\0_datasets'; 
libname mydata 'C:\Users\Reginald\Dropbox\Research\biz-uncertainty\data'; 


/*Annual Cross-Sectional Variables*/
data crspcomp;
set home.crspcomp;
run;

proc sql;
create table x1 as
select gvkey, fyear, datadate, sic,
ppent,
act,
lct,
prcc_f,
csho,
prcc_f*csho as mkval,
ceq/(prcc_f*csho) as bm,
sale,
ib,
ceq,
sum(0,xrd) as xrd,
sum(0,xrd)/sale as rdsales,
sum(0,xrd)/ib as rdearn,
sum(0,xrd)/ceq as rdeq,
at,
che, 
mibt,
dlc,
dltt,
sum(ppent, act, -lct) as noa
from crspcomp;
quit;
/*309557*/

proc sort data=x1 nodupkey; 
by gvkey datadate; 
run;

proc expand data=x1 out=x2 method=none;
by gvkey;
convert at = at_lag1 / transformout=(lag 1);
convert noa = noa_lag1 / transformout=(lag 1);
convert sale = sale_lag1 / transformout=(lag 1);
convert xrd = xrd_lag1 / transformout=(lag 1);
convert ib = ib_lag1 / transformout=(lag 1);
convert che = che_lag1 / transformout=(lag 1);
convert ceq = ceq_lag1 / transformout=(lag 1);
convert mkval = mkval_lag1 / transformout=(lag 1);
convert bm = bm_lag1 / transformout=(lag 1);

convert rdsales = rdsales_lag1 / transformout=(lag 1);
convert rdearn = rdearn_lag1 / transformout=(lag 1);
convert rdeq = rdeq_lag1 / transformout=(lag 1);

convert rdsales = rdsales_lead1 / transformout=(lead 1);
convert rdearn = rdearn_lead1 / transformout=(lead 1);
convert rdeq = rdeq_lead1 / transformout=(lead 1);
run;

data x3;
set x2;
roa = ib/(0.5*(at + at_lag1));
chnoa = noa - noa_lag1;
invest = chnoa/(0.5*(at + at_lag1));
run;

proc sql; 
create table x4 as 
select * 
from x3
where ceq > 1
and at > 1
and sale > 1
and prcc_f > 2
;
quit;

proc sort data=x4;
by gvkey datadate;
run;

/*Get lags*/
proc expand data=x4 out=x5 method=none;
by gvkey;
convert roa = roa_lag1 / transformout=(lag 1);
convert invest = invest_lag1 / transformout=(lag 1);

convert roa = roa_lead1 / transformout=(lead 1);
convert invest = invest_lead1 / transformout=(lead 1);
run;
/*195,366*/

data mydata.accvars;
set x5;
run;

/*ad-hoc variables*/
data x;
set mydata.accagg;
run;

/******************************************************************************
Annual Aggregate Variables
******************************************************************************/

/*weighted values*/
proc sql;
create table x5 as
select *,
invest*mkval as winvest,
roa*mkval as wroa,
xrd*mkval as wrd,
sale*mkval as wsale,
ib*mkval as wearn
from x4
;

create table mkval as
select fyear, sum(mkval) as mkval 
from x4
group by fyear;
quit;

proc sql;
create table x6 as
select a.fyear, a.datadate, 
a.winvest, a.wroa, a.wrd, a.wsale, a.wearn, a.ceq, 
b.mkval
from x5 as a,
mkval as b
where a.fyear = b.fyear
;
quit;


proc sql;
create table x7 as
select fyear, 
sum(winvest/mkval) as invest,
sum(wroa/mkval) as roa,
sum(wrd/mkval) as rd,
sum(wrd/mkval)/sum(wsale/mkval) as rdsales,
sum(wrd/mkval)/sum(wearn/mkval) as rdearn,
sum(wrd/mkval)/mean(ceq) as rdeq
from x6
group by fyear;
quit;

proc means data=x7 mean std p25 median p75;
var invest roa rd rdsales rdearn rdeq; 
run;

data mydata.accagg;
set x7;
run;

/*ad-hoc variables*/
data x;
set mydata.accagg;
run;



/*******************************************************************************
Quarterly Cross-Sectional Variables
*******************************************************************************/
data crspcompq;
set home.crspcompq;
run;

proc sql;
create table x1 as
select gvkey, fyearq, datafqtr, sic,
ppentq,
lctq,
actq,
prccq,
cshoq,
prccq*cshoq as mkval,
saleq,
ibq,
ceqq,
sum(0,xrdq) as xrdq,
atq,
cheq, 
ltmibq,
dlcq,
dlttq,
sum(ppentq, actq, -lctq) as noa
from crspcompq;
quit;

proc sort data=x1; 
by gvkey datafqtr; 
run;

proc expand data=x1 out=x2 method=none;
by gvkey;
convert noa = noa_lag1 / transformout=(lag 1);
convert atq = atq_lag1 / transformout=(lag 1);
run;

data x3;
set x2;
roa = ibq/(0.5*(atq + atq_lag1));
chnoa = noa - noa_lag1;
invest = chnoa/(0.5*(atq + atq_lag1));
run;

proc sql; 
create table x4 as 
select * 
from x3
where ceqq > 10
and atq > 10
and saleq > 10
and prccq > 2
; 
quit;

/*add ff48 industries*/
%ind_ff48 (x4, x5, sic, ff, ff48);

data mydata.accvarsq;
set x5;
run;

/*******************************************************************************
Quarterly Aggregate Variables
*******************************************************************************/

proc sql;
create table x5 as
select *,
invest*mkval as winvest,
roa*mkval as wroa,
xrdq*mkval as wrd,
saleq*mkval as wsale,
atq*mkval as wassets,
ibq*mkval as wearn
from x4
;

create table mkval as
select fyearq, datafqtr, 
sum(mkval) as mkval 
from x4
group by fyearq, datafqtr;
quit;

proc sql;
create table x6 as
select a.fyearq, a.datafqtr, 
a.winvest, a.wroa, a.wrd, a.wsale, a.wearn, a.ceqq,
b.mkval
from x5 as a,
mkval as b
where a.datafqtr = b.datafqtr
;
quit;

proc sql;
create table x7 as
select fyearq, datafqtr, 
sum(winvest/mkval) as invest,
sum(wroa/mkval) as roa,
sum(wrd/mkval) as rd,
sum(wrd/mkval)/sum(wassets/mkval) as rdassets,
sum(wrd/mkval)/sum(wsale/mkval) as rdsales,
sum(wrd/mkval)/sum(wearn/mkval) as rdearn,
sum(wrd/mkval)/mean(ceqq) as rdeq
from x6
group by fyearq, datafqtr;
quit;

proc means data=x7 mean std p25 median p75;
var invest roa rd rdsales rdearn rdeq; 
run;


data mydata.accaggq;
set x7;
run;
