## Cross-sectional validation of uncertainty measure

rm(list=ls())
library(ggplot2)
source('../0_code/useful-fn.R')
load('data/mda.RData')

## uncertainty by quintiles of accounting variables across the entire sample period
## size
at.deciles <- quantile(mda$at, probs = seq(from=0, to=1, by=0.1), na.rm=TRUE)
at.decile.cuts <- cut(mda$at, breaks = at.deciles, include.lowest = TRUE, labels = FALSE)
X <- data.frame(mda[, c('gvkey', 'filingdate', 'at', 'n_unc_terms')], at.decile.cuts)
uncertainty.by.at <- aggregate(X$n_unc_terms, by=list(X$at.decile.cuts), FUN = mean, na.action = na.omit)
names(uncertainty.by.at) <- c('at.decile', 'n_unc_terms')

## bm
bm.deciles <- quantile(mda$bm, probs = seq(from=0, to=1, by=0.1), na.rm=TRUE)
bm.decile.cuts <- cut(mda$bm, breaks = bm.deciles, include.lowest = TRUE, labels = FALSE)
X <- data.frame(mda[, c('gvkey', 'filingdate', 'bm', 'n_unc_terms')], bm.decile.cuts)
uncertainty.by.bm <- aggregate(X$n_unc_terms, by=list(X$bm.decile.cuts), FUN = mean, na.action = na.omit)
names(uncertainty.by.bm) <- c('bm.decile', 'n_unc_terms')


## roa
roa.deciles <- quantile(mda$roa, probs = seq(from=0, to=1, by=0.1), na.rm=TRUE)
roa.decile.cuts <- cut(mda$roa, breaks = roa.deciles, include.lowest = TRUE, labels = FALSE)
X <- data.frame(mda[, c('gvkey', 'filingdate', 'roa', 'n_unc_terms')], roa.decile.cuts)
uncertainty.by.roa <- aggregate(X$n_unc_terms, by=list(X$roa.decile.cuts), FUN = mean, na.action = na.omit)
names(uncertainty.by.roa) <- c('roa.decile', 'n_unc_terms')

## investment
invest.deciles <- quantile(mda$invest, probs = seq(from=0, to=1, by=0.1), na.rm=TRUE)
invest.decile.cuts <- cut(mda$invest, breaks = invest.deciles, include.lowest = TRUE, labels = FALSE)
X <- data.frame(mda[, c('gvkey', 'filingdate', 'invest', 'n_unc_terms')], invest.decile.cuts)
uncertainty.by.invest <- aggregate(X$n_unc_terms, by=list(X$invest.decile.cuts), FUN = mean, na.action = na.omit)
names(uncertainty.by.invest) <- c('invest.decile', 'n_unc_terms')


## rd
mda2 <- mda[which(mda$xrd > 0), ]

mda2$rdsales <- mda2$xrd/mda2$sale
rdsales.deciles <- quantile(mda2$rdsales, probs = seq(from=0, to=1, by=0.1), na.rm=TRUE)
rdsales.decile.cuts <- cut(mda2$rdsales, breaks = rdsales.deciles, include.lowest = TRUE, labels = FALSE)
X <- data.frame(mda2[, c('gvkey', 'filingdate', 'rdsales', 'n_unc_terms')], rdsales.decile.cuts)
uncertainty.by.rdsales <- aggregate(X$n_unc_terms, by=list(X$rdsales.decile.cuts), FUN = mean, na.action = na.omit)
names(uncertainty.by.rdsales) <- c('rdsales.decile', 'n_unc_terms')

mda3 <- mda[which(mda$xrd == 0), ]
mda3$rdsales <- mda3$xrd/mda3$sale
a <- c(-1, mean(mda3$n_unc_terms, na.rm = TRUE))
uncertainty.by.rdsales <- rbind(a, uncertainty.by.rdsales)

## OLS
summary(lm(n_unc_terms ~ I(log(at)) + bm + roa + I(log(mkval)) + invest + I(xrd/sale) + I(fyear) + I(ff48), data=mda))

## changes
mda$chroa <- mda$roa - mda$roa_lag1
mda$chinvest <- mda$invest - mda$invest_lag1
mda$chrdsales <- mda$rdsales - mda$rdsales_lag1
mda$chrdearn <- mda$rdearn - mda$rdearn_lag1
mda$chrdeq <- mda$rdeq - mda$rdeq_lag1
mda$chbm <- mda$bm - mda$bm_lag1
mda$chat <- mda$at - mda$at_lag1
## TODO: change in number of words
mda <- mda[order(mda$gvkey, mda$fyear), ]
chn_unc_terms <- lag.variable(mda, n_unc_terms, gvkey)

summary(lm(p_unc_terms ~ chat + chbm + chroa + chinvest + chrdsales, data=mda))
