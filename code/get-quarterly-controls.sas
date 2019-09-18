options nocenter nodate source;

%let wrds = wrds.wharton.upenn.edu 4016;
options comamid = TCP remote = WRDS;
signon username=reggie09 pw=gbHjz5FV;

libname mydata 'C:\Users\Reginald\Dropbox\Research\biz-uncertainty\data';
libname home 'C:\Users\Reginald\Dropbox\Research\0_datasets'; 

libname rwork slibref=work server=wrds;

rsubmit;
libname compsec '/wrds/comp/sasdata/d_na/security' ;
libname crsp '/wrds/crsp/sasdata/a_stock';
libname compx '/wrds/comp/sasdata/naa' ;
libname crspx '/wrds/crsp/sasdata/a_ccm';
endrsubmit;

proc contents data=home.crspcompq;run;

data X1;
set home.crspcompq;
where 1994 <= fyearq <= 2017;
quarter = qtr(fyearq);
run;
/*849,778*/

data enddates;
set X1;
keep gvkey lpermno cusip datadate fyearq quarter tic;
run;

proc sort data=enddates nodupkey;
by gvkey lpermno cusip datadate fyearq quarter tic;
run;
/*849,751*/

rsubmit;
proc upload data=enddates;run;
endrsubmit;

rsubmit;
/*Compute quarterly average price*/
proc sql;
create table price as
select cusip, permno,
	year(date) as year, 
	qtr(date) as quarter, 
	mean(abs(prc)) as price
from crsp.dsf
/*where HEXCD in (1,2,3,4,-2,-1)*/
group by cusip, permno, year, quarter;
/*377,965*/

create table price2 as
select * 
from price
where not missing (price) 
and not missing(cusip)
and not missing(year);
/*1429418*/
quit;
endrsubmit;

rsubmit;
proc download data=price2 out=price; run;
endrsubmit;

proc sql;
create table price2 as
select a.gvkey, 
a.datadate, 
b.*
from X1 as a, 
price as b
where a.lpermno = b.permno
/*and substr(a.cusip,1,6) = substr(b.cusip,1,6)*/
and a.fyearq = b.year
and a.quarter = b.quarter;
quit;
/*651838/

/*Get returns over the year*/
rsubmit;
data temp;
set enddates;
enddt1 = datadate;
startdt = intnx('month',enddt1, -12,'end');
format startdt date9.;
format enddt1 date9.;
run;

proc sql;
create table temp2 as
select a.cusip, 
a.lpermno,
a.gvkey, 
a.fyearq, 
a.quarter,
a.startdt, 
a.enddt1, 
b.date, 
b.ret, 
b.prc,
b.permno
from temp as a
left join crsp.dsf as b
on a.lpermno = b.permno
where a.startdt <= b.date <= a.enddt1 
order by gvkey, date;

create table returns as
select gvkey, permno, fyearq, quarter, startdt, enddt1, exp(sum(log(1+ret)))-1  as bhr
from temp2
group by gvkey, permno, fyearq, quarter, startdt, enddt1;
/*217,143*/
quit;

data returns;
set returns;
rename enddt1=datadate;
run;
endrsubmit;

rsubmit;
proc download data=returns;run;
endrsubmit;

/*Market value of equity*/
rsubmit;
proc sql;
create table temp1 as 
select a.gvkey, 
	a.tic,
	a.datadate, 
	((ABS(b.prc)*b.shrout) / 1000) as mve1
from enddates as a
left join crsp.dsf as b
on a.datadate = b.date
and a.lpermno = b.permno
/*and substr(a.cusip,1,6) = substr(b.cusip,1,6)*/
order by datadate;

create table temp2 as 
select a.gvkey, 
	a.tic,
	a.datadate, 
	((ABS(b.prc)*b.shrout) / 1000) as mve2
from enddates as a
left join crsp.dsf as b
on a.datadate = b.date+2
and a.lpermno = b.permno
/*and substr(a.cusip,1,6) = substr(b.cusip,1,6)*/
order by datadate;

create table temp3 as 
select a.gvkey, 
	a.tic,
	a.datadate, 
	((ABS(b.prc)*b.shrout) / 1000) as mve3
from enddates as a
left join crsp.dsf as b
on a.datadate = b.date-2
and a.lpermno = b.permno
/*and substr(a.cusip,1,6) = substr(b.cusip,1,6)*/
order by datadate;
/*179,546*/

create table temp4 as
select a.*, b.mve2,c.mve3
from temp1 as a, temp2 as b, temp3 as c
where a.gvkey = b.gvkey and a.gvkey = c.gvkey
and a.datadate = b.datadate and a.datadate = c.datadate
order by gvkey, datadate
;
quit;

data temp5;
set temp4;
mve = max(mve1, mve2, mve3);
drop mve1 mve2 mve3;
run;

proc sort data=temp5 out=mve nodup;
by gvkey tic datadate;
endrsubmit;

rsubmit;
proc download; run;
endrsubmit;
/*849,328*/

/*Compute quarterly average turnover*/
rsubmit;
proc sql;
create table turnover as
select cusip, 
	permno,
	year(date) as year, 
	qtr(date) as quarter,
	mean(vol/shrout) as turnover
from crsp.dsf
group by cusip, permno, year, quarter;
/*377,965*/
quit;
endrsubmit;

rsubmit;
proc download data=turnover; run;
endrsubmit;
/*1451834*/

proc sql;
create table turnover2 as
select a.gvkey, 
a.datadate, 
b.*
from X1 as a, 
turnover as b
where a.lpermno = b.permno
/*and substr(a.cusip,1,6) = substr(b.cusip,1,6)*/
and a.fyearq = b.year;
quit;
/*2640774/


/*Compustat-based variables*/
/*SP500 Index constituent*/
data keys;
set X1;
keep gvkey datadate;
run;
/*217,967*/

data index;
set home.index_constituents;
run;
/*79,643*/

data temp;
set index ;
if thru = . then thru = '31Dec2017'd;
run;

proc sql;
create table sp500 as
select a.*, b.spmi, b.from, b.thru
from keys as a
left join temp as b
on a.gvkey = b.gvkey
where b.from <= a.datadate <= b.thru
and b.spmi='10';
/*46926*/

create table sp500_2 as
select gvkey,
	datadate,
	1 as sp500
from sp500		
order by gvkey, datadate;
/*18817*/

create table sp500_3 as
select a.*, b.*
from keys as a
left join sp500_2 as b
on a.gvkey = b.gvkey
and a.datadate = b.datadate
order by gvkey, datadate;
quit;
/*239747*/

data sp500_4;
set sp500_3;
if sp500 = . then sp500 = 0;
year = year(datadate);
quarter = qtr(datadate);
run;
/*849830*/

/*TODO*/

proc sql;
create table div as
select gvkey, datadate, tic, dvy, dvy/prccq as div
from X1
order by dvy desc;
/*235,237*/

create table leverage as
select gvkey, datadate, tic, dlcq, dlttq, atq, sum(dlcq, dlttq)/atq as leverage
from X1
order by gvkey, datadate;
/*235,237*/

create table roa as
select gvkey, datadate, tic, ibcomq, atq, ibcomq/atq as roa
from X1
order by gvkey, datadate;
/*235,237*/

create table tang as
select gvkey, datadate, tic,
((0.715*rectq + 0.547*invtq + 0.535*ppentq) + cheq)/atq as tang
from X1;
/*235,237*/

create table tobinq as
select gvkey, 
	datadate, 
	tic,
	atq,
	prccq*cshoq as mve,
	sum(dlcq, dlttq) as debt,
	pstkrq
from X1;
/*235,237*/

create table tobinq2 as
select *, 	sum(mve, PSTKRq, debt)/atq as q
from tobinq;
/*235,237*/
quit;

proc sql;
create table compvars as
select a.*, b.*, c.*,d.*,e.*,f.*
from div as a,
	leverage as b,
	roa as c,
	tang as d,
	tobinq2 as e,
	sp500_4 as f
where a.gvkey = b.gvkey
and a.gvkey = c.gvkey
and a.gvkey = d.gvkey
and a.gvkey = e.gvkey
and a.gvkey = f.gvkey
and a.datadate = b.datadate
and a.datadate = c.datadate
and a.datadate = d.datadate
and a.datadate = e.datadate
and a.datadate = f.datadate
;
quit;
/*878350*/

proc sql; 
create table compvars2 as 
select distinct * 
from compvars;
quit;
/*851,201*/

proc sql;
create table temp as
select a.*, b.*
from X1 as a
left join compvars2 as b
on a.gvkey = b.gvkey
and a.datadate = b.datadate;
quit;
/*853534*/

data compvars3;
set temp;
if div = . then div = 0;
if leverage = . then leverage = 0;
if roa = . then roa = 0;
if q = . then q = 0;
if tang = . then tang = 0;
run;

/**/
/*proc means data=compvars2 nmiss mean std p1 p5 p25 p50 p75 p95 p99;*/
/*var div leverage roa tang q sp500; */
/*run;*/

/*Merge all datasets*/
proc sql;
create table controls as
select a.gvkey, 
	a.lpermno, 
	a.datadate, 
	a.tic, 
	a.cshoq,
	b.*, d.*, f.*, g.*
from X1 as a,
	returns as b,
	price2 as d,
	mve as f,
	turnover2 as g
where a.gvkey = b.gvkey 
	and a.gvkey = d.gvkey
	and a.gvkey = f.gvkey
	and a.gvkey = g.gvkey
	and a.datadate = b.datadate
	and a.datadate = d.datadate
	and a.datadate = f.datadate
	and a.datadate = g.datadate;
quit;
/*2573496*/
proc sort data=controls nodupkey; 
by gvkey datadate;
run;
/*646,578*/

proc sql;
create table controls2 as
select a.*,	compvars3.*
from controls as a,
	compvars3
where a.gvkey = compvars3.gvkey
	and a.datadate = compvars3.datadate;
quit;
proc sort data=controls2 nodupkey; 
by gvkey datadate;
run;

data mydata.controlsq;
set controls2;
run;

/*Limit to analysis variables*/
data mydata.controlsq2;
set mydata.controlsq;
keep fyearq gvkey tic sic datadate quarter datafqtr datacqtr fqtr fyr
mve
q
sp500
atq
ibcomq
ceqq
roa
bhr
price
tang
leverage
turnover
div
xrdq
saleq
ibq
;
run;
/*646,578*/

/*
weight and aggregate
*/

data X;
set mydata.controlsq2;
where atq > 0 and ceqq > 0 and saleq > 0 and price > 1;
run;
/*487,300*/
proc sort data=X;
by gvkey datadate;
run;
proc expand data=x out=x2 method=none;
by gvkey;
convert ceqq = ceqq_lag1 / transformout=(lag 1);
convert atq = atq_lag1 / transformout=(lag 1);
run;

proc sql;
create table X3 as
select *,
price/ibcomq as pe,
max(0, xrdq/(0.5*(atq + atq_lag1))) as rd
from X2;
quit;

proc sql;
create table X4 as 
select *,
pe*mve as pe_wt,
turnover*mve as turnover_wt,
leverage*mve as leverage_wt,
tang*mve as tang_wt,
div*mve as div_wt,
bhr*mve as bhr_wt,
rd*mve as rd_wt,
roa*mve as roa_wt,
atq*mve as atq_wt,
ibq*mve as ibq_wt
from X3;
quit;

proc sql;
create table mve as
select datafqtr, 
sum(mve) as mve
from X3
where not missing(datafqtr)
group by datafqtr;
quit;

proc sql;
create table x5 as
select a.datafqtr, 
a.pe,
a.pe_wt,
a.turnover_wt,
a.leverage_wt,
a.tang_wt,
a.div_wt,
a.bhr_wt,
a.rd_wt,
a.roa_wt,
a.atq_wt,
a.ibq_wt,
a.ceqq,
b.mve
from x4 as a,
mve as b
where a.datafqtr = b.datafqtr
;
quit;
/*487,143*/

proc sql;
create table x6 as
select datafqtr, 
mean(mve) as mve,
sum(turnover_wt/mve) as turnover,
sum(leverage_wt/mve) as leverage,
sum(tang_wt/mve) as tang,
sum(div_wt/mve) as div,
sum(bhr_wt/mve) as bhr,
sum(rd_wt/mve) as rd,
sum(roa_wt/mve) as roa,
sum(atq_wt/mve) as atq,
mean(pe) as pe
from x5
group by datafqtr;
quit;

data mydata.aggcontrolsq;
set x6;
run;




signoff;
