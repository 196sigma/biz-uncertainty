rm(list=ls())
source('../0_code/useful-fn.R')
epu <- read.csv('../0_datasets/US_Policy_Uncertainty_Data.csv')
names(epu) <- tolower(names(epu))
summary(epu)

## Aggregate to the quarter
X <- epu
epu$qtr <- month.to.quarter(epu$month)
X <- aggregate(epu$news_based_policy_uncert_index, by = list(epu$year, epu$qtr), FUN = mean)
names(X) <- c('year', 'qtr', 'epu')
X$yearqtr <- paste(X$year, X$qtr, sep = 'Q')
#plot(X$epu, type='l')
epuq <- X
rm(list= c('X'))
save(x = epuq, file = 'data/epuq.RData')

## Annually
X <- epu
X <- aggregate(epu$news_based_policy_uncert_index, by = list(epu$year), FUN = mean)
names(X) <- c('year', 'epu')
epu <- X
rm(list= c('X'))
save(x = epu, file = 'data/epu.RData')
