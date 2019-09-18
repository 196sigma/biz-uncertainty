## Cross-sectional validation (regression of uncertainty measure on controls)

rm(list=ls())
dev.off()
library(ggplot2)
library(stargazer)
source('../0_code/useful-fn.R')
load('data/mda.RData')

## OLS Validation
## Full-Sample
m1 <- lm(p_unc_terms ~ I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda)
names(m1$coefficients)

## Pre-crisis
o1 <- which(mda$fyear < 2007)
mda.precrisis <- mda[o1, ]
m2 <- lm(p_unc_terms ~ I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda.precrisis)

## Post-Crisis
o2 <- which(mda$fyear > 2007)
mda.postcrisis <- mda[o2, ]
m3 <- lm(p_unc_terms ~ I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda.postcrisis)

## Change variable names before exporting
lm.out.names <- c("Const.", "Assets", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")
m1 <- names.lm(m1, in.names = c("(Intercept)", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion"),
               out.names = lm.out.names)
m2 <- names.lm(m2, in.names = c("(Intercept)", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion"),
               out.names = lm.out.names)
m3 <- names.lm(m3, in.names = c("(Intercept)", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion"),
               out.names = lm.out.names)


stargazer(m1, m2, m3,
          float=TRUE, 
          float.env="table", 
          table.placement="H", 
          digits=4, 
          single.row=FALSE,
          align=TRUE, 
          no.space=TRUE, 
          font.size="footnotesize",
          omit.stat=c("LL", "f", "ser"), 
          notes = "Year and Industry fixed effects included.", 
          notes.append=TRUE,
          model.names=TRUE,
          keep = lm.out.names,
          label='punc-xs-ols',
          title="Business Uncertainty Cross-Sectional OLS Determinants",
          out="report/tables/punc-xs-ols.tex")

###################################################################################################
## OUTCOME VARIABLES
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



###################################################################################################
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
