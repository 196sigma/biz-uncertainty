options nocenter nodate source;

%let wrds = wrds.wharton.upenn.edu 4016;
options comamid = TCP remote = WRDS;
signon username=reggie09 pw=WtRuP5rT;

libname mydata 'C:\Users\Reginald\Dropbox\Research\Comparability\data';
libname home 'C:\Users\Reginald\Dropbox\Research\0_datasets'; 

libname rwork slibref=work server=wrds;

rsubmit;
libname compsec '/wrds/comp/sasdata/d_na/security' ;
libname crsp '/wrds/crsp/sasdata/a_stock';
libname compx '/wrds/comp/sasdata/naa' ;
libname crspx '/wrds/crsp/sasdata/a_ccm';
endrsubmit;

/*proc contents data=home.crspcomp;run;*/

data X1;
set home.crspcomp;
where 1980 <= fyear <= 2017;
run;
/*235,237*/

data enddates;
set X1;
keep gvkey lpermno cusip datadate fyear tic;
run;

proc sort data=enddates nodupkey;
by gvkey lpermno cusip datadate fyear tic;
run;
/*230,673*/

rsubmit;
proc upload data=enddates;run;
endrsubmit;

rsubmit;
/*Compute annual average price*/
proc sql;
create table price as
select cusip, permno,
	year(date) as year, 
	mean(abs(prc)) as price
from crsp.dsf
/*where HEXCD in (1,2,3,4,-2,-1)*/
group by cusip, permno, year;
/*377,965*/

create table price2 as
select * 
from price
where not missing (price) 
and not missing(cusip)
and not missing(year);
/*373,468*/
quit;

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
and a.fyear = b.year;
quit;
/*247,184*/

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
a.fyear, 
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
select gvkey, permno, fyear, startdt, enddt1, exp(sum(log(1+ret)))-1  as bhr
from temp2
group by gvkey, permno, fyear, startdt, enddt1;
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


/*Firm age (i.e. number of years in COMPUSTAT*/
rsubmit;
proc sql;
create table age as
select gvkey,
	min(datadate) as firstdate
from comp.funda
group by gvkey
order by firstdate;
quit;

data age; 
set age;
format firstdate date9.;
run;
/*37,352*/
proc download;run;
endrsubmit;

proc sql;
create table age2 as
select a.datadate,
	b.*, 
	(a.datadate - b.firstdate)/365.25 as age
from X1 as a, 
	age as b
where a.gvkey = b.gvkey
order by age desc;
quit;
/*330,634*/

/*Compute average annual effective bid-ask spread*/
rsubmit;
proc sql;
create table baspread as
select cusip, 
	permno,
	year(date) as year,
	spread/abs(prc) as baspread
from crsp.msf
/*where HEXCD in (1,2,3,4,-2,-1)*/
/*and spread >= 0*/
;
create table baspread2 as
select cusip, permno, year, 
	mean(baspread) as baspread
from baspread
group by cusip, permno, year;
quit;
/*379,585*/
endrsubmit;
 /**/
/*proc corr data=baspread2; */
/*var baspread baspread2 baspread3; */
/*run;*/

proc sql;
create table baspread3 as
select a.gvkey, 
	a.datadate, 
	max(b.baspread, 0) as baspread
from X1 as a, 
	baspread2 as b
where a.lpermno = b.permno
/*and substr(a.cusip,1,6) = substr(b.cusip,1,6)*/
and a.fyear = b.year
;
quit;
/*186,277*/

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
/*267,380*/

/*Compute annual average turnover*/
rsubmit;
proc sql;
create table turnover as
select cusip, 
	permno,
	year(date) as year, 
	mean(vol/shrout) as turnover
from crsp.dsf
group by cusip, permno, year;
/*377,965*/
quit;
endrsubmit;
rsubmit;
proc download data=turnover; run;
endrsubmit;

proc sql;
create table turnover2 as
select a.gvkey, 
a.datadate, 
b.*
from X1 as a, 
turnover as b
where a.lpermno = b.permno
/*and substr(a.cusip,1,6) = substr(b.cusip,1,6)*/
and a.fyear = b.year;
quit;
/*185,601*/


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
/*18817*/

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
run;
/*354,216*/

proc sql;
create table div as
select gvkey, datadate, tic, dvc, dvc/prcc_f as div
from X1
order by dvc desc;
/*235,237*/

create table leverage as
select gvkey, datadate, tic, dlc, dltt, at, sum(dlc, dltt)/at as leverage
from X1
order by gvkey, datadate;
/*235,237*/

create table roa as
select gvkey, datadate, tic, ibcom, at, ibcom/at as roa
from X1
order by gvkey, datadate;
/*235,237*/

create table tang as
select gvkey, datadate, tic,
((0.715*rect + 0.547*invt + 0.535*ppent) + che)/at as tang
from X1;
/*235,237*/

create table tobinq as
select gvkey, 
	datadate, 
	tic,
	at,
	prcc_f*csho as mve,
	sum(dlc, dltt) as debt,
	PSTKRV
from X1;
/*235,237*/

create table tobinq2 as
select *, 	sum(mve, PSTKRV, debt)/at as q
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
/*6954849*/

proc sql; 
create table compvars2 as 
select distinct * 
from compvars;
quit;
/*219,584*/

proc sql;
create table temp as
select a.*, b.*
from X1 as a
left join compvars2 as b
on a.gvkey = b.gvkey
and a.datadate = b.datadate;
quit;
/*235,237*/

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
	a.csho,
	b.*, c.*, d.*, e.*, f.*, g.*
from X1 as a,
	returns as b,
	age2 as c,
	price2 as d,
	baspread3 as e,
	mve as f,
	turnover2 as g
where a.gvkey = b.gvkey 
	and a.gvkey = c.gvkey
	and a.gvkey = d.gvkey
	and a.gvkey = e.gvkey
	and a.gvkey = f.gvkey
	and a.gvkey = g.gvkey
	and a.datadate = b.datadate
	and a.datadate = c.datadate
	and a.datadate = d.datadate
	and a.datadate = e.datadate
	and a.datadate = f.datadate
	and a.datadate = g.datadate;
quit;
proc sort data=controls nodupkey; 
by gvkey datadate;
run;
/*178,106*/

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

data mydata.controls;
set controls2;
run;

/***************************Ad-hoc control variabls*******************************/

/*Analyst following*/
data analysts;
set home.ibescrspcomp;
keep numest 
stdev
meanest
medest
actual
cname
tic
cusip
date
datadate
fpedats
fyear
gvkey
prcc_f
adjex_f
adjex_c
siccd;
run;
/*127,058*/

proc sort data=analysts; 
by gvkey fyear date; 
run;

data analysts2;
set analysts;
by gvkey fyear;
if first.fyear = 1;
run;
/*119,546*/

data analysts3;
set analysts2;
accuracy = ((actual - medest)**2)/prcc_f;
year = year(date);
dispersion = stdev/prcc_f;
rename numest=nanalysts;
run;

data controls;
set mydata.controls;
run;
/*178,106*/

proc sql;
create table controls2 as
select a.*, b.* 
from controls as a
left join analysts3 as b
on a.gvkey = b.gvkey and a.year = b.year
order by gvkey, year;
quit;
/*178,106*/

data controls3;
set controls2;
if nanalysts = . then nanalysts = 0;
run;

data mydata.controls;
set controls3;
run;

/*************************Forward P/E****************************/
data analysts;
set home.ibescrspcomp;
keep numest 
stdev
meanest
medest
actual
cname
tic
cusip
date
datadate
fpedats
fyear
gvkey
prcc_f
adjex_f
adjex_c
siccd;
run;

proc sort data=analysts; 
by gvkey fyear date; 
run;

data analysts2;
set analysts;
by gvkey fyear;
if first.fyear = 1;
run;
data pe;
set analysts2;
pe_fwd = prcc_f/medest;
run;

data controls;
set mydata.controls;
run;
/*178,106*/

proc sql;
create table controls2 as
select a.*, a.prcc_f/(a.ibcom/a.csho) as pe, b.* 
from controls as a
left join pe as b
on a.gvkey = b.gvkey and a.year = b.fyear
order by gvkey, year;
quit;
/*178,106*/

data controls3;
set controls2;
if pe_fwd = . then pe_fwd = pe;
run;

/*proc means data=controls3 n nmiss min p1 mean median p99 max; */
/*var pe_fwd pe;  */
/*run;*/

/*proc corr data=controls3;*/
/*var pe_fwd pe;*/
/*run;*/

data mydata.controls;
set controls3;
run;

/*data temp; */
/*set controls3; */
/*where gvkey='012141'*/
/*where tic='MSFT'*/
/*where permno=10107*/
/*;*/
/*run;*/

data mydata.controls2;
set mydata.controls;
keep date gvkey fyear tic
nanalysts 
accuracy
dispersion
siccd
price
bhr
age
baspread
mve
turnover
sp500
leverage
div
tang
q
pe_fwd
;
run;

signoff;
