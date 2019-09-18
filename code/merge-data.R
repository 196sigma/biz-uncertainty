## Reginald Edwards
## DESCRIPTION: This datasets merges the metrics of uncertainty terms, for each firm-year, with 
## compustat variables

rm(list=ls())

library(sas7bdat)

source('../0_code/useful-fn.R')

source('../0_code/ff48.R')

load('data/uncertainty-metrics-xs.RData')
names(mda) <- tolower(names(mda))
mda$gvkey <- sprintf("%06d", mda$gvkey)

## merge with annual compustat data
accvars <- read.sas7bdat('data/accvars.sas7bdat');
names(accvars) <- tolower(names(accvars))

X <- merge(mda, accvars, by=c('gvkey', 'fyear', 'datadate', 'at','prcc_f','csho'), all.x = TRUE, all.y = FALSE)
mda <- X
rm(list=c('X'))

## get rid of dups
X <- mda[!duplicated(mda[, c('gvkey', 'datadate')]), ]
mda <- X
rm(list=c('X'))

## merge with more cross-sectional variables
controls <- read.sas7bdat('data/controls2.sas7bdat')
names(controls) <- tolower(names(controls))

X <- merge(mda, controls, by = c('gvkey', 'fyear'), all.x = TRUE, all.y = FALSE)
mda <- X
rm(list=c('X'))

## Add industries
mda$sic2 <- substr(mda$sich,1,2)
table(mda$sic2)
## Fama-French 48
#mda[, c("ff48", "ff48desc")] <- sapply(X = list(mda$sich), FUN = get.ff48)
mda[,c('ff48', 'ff48desc')] <- c(NA, NA)
for(i in 1:nrow(mda)){
  if(mda[i,'sich']){
    mda[i,c('ff48', 'ff48desc')] <- get.ff48(mda[i,'sich'])  
  }
}

## Winsorize data
X <- mda
wins.vars <- c('at', 'ib', 'roa', 'mkval', 'invest', 'rdsales', 'rdearn', 'rdeq', 'che')
for(v in wins.vars) X <- wins.df(mda, v, firmid = 'gvkey', yearid = 'fyear')
mda <- X
rm(list=c('X'))

## Negative earnings dummy
mda$negearn <- ifelse(mda$roa <0, 1, 0)

## Winsorize controls
wins.vars <- c("age",
               "at",
               "baspread",
               "bhr",
               "div",
               "leverage",
               "mve",
               "nanalysts",
               'dispersion',
               "pe_fwd",
               "price",
               "q",
               "roa",
               "sp500",
               "tang",
               "turnover",
               "negearn")
X <- mda
for(v in wins.vars) X <- wins.df(mda, v, firmid = 'gvkey', yearid = 'fyear')
mda <- X
rm(list=c('X'))

## merge EPU
#load('data/epu.RData')
#X <- merge(mda, epu, by.x = )
## save data

save(x = mda, file = 'data/mda.RData')
