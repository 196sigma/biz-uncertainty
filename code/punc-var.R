## Reginald Edwards
##
##
rm(list=ls())

library(sas7bdat)
library(ggplot2)
library(vars)
source('../0_code/useful-fn.R')

## load data
load('data/uncertainty-metrics-ts.RData')
aggs.q <- read.sas7bdat("data/accaggq.sas7bdat")
names(aggs.q) <- tolower(names(aggs.q))
o <- which(aggs.q$datafqtr == '')
if(length(o)>0) aggs.q <- aggs.q[-o,]

X <- merge(terms.by.quarter, aggs.q, by.x = 'filingquarter', by.y = 'datafqtr')
n <- nrow(X)

var.variables <- c('p_unc_terms', 'roa', 'invest', 'rdsales')
punc.var1 <- VAR(y = X[, var.variables], p = 1, type = "const"); summary(punc.var1)
punc.var2 <- VAR(y = X[, var.variables], p = 2, type = "const"); summary(punc.var2)
punc.var3 <- VAR(y = X[, var.variables], p = 3, type = "const"); summary(punc.var3)
punc.var4 <- VAR(y = X[, var.variables], p = 4, type = "const"); summary(punc.var4)

causality(punc.var1, cause = 'p_unc_terms')
causality(punc.var2, cause = 'p_unc_terms')
causality(punc.var3, cause = 'p_unc_terms')
causality(punc.var4, cause = 'p_unc_terms')

## Diagnostic plots
#plot(punc.var1)

punc.irf1 <- irf(punc.var1, response = 'p_unc_terms', n.head = 24, boot = T)

## (p = 2) IRF
punc.irf2 <- irf(punc.var2, response = 'p_unc_terms', n.head = 6, boot = T)
punc.response2 <- punc.irf2$irf$p_unc_terms
roa.response2 <- punc.irf2$irf$roa
invest.response2 <- punc.irf2$irf$invest
rdsales.response2 <- punc.irf2$irf$rdsales
n <- length(punc.response2)

png('report/figures/punc-irf-2.png')
par(mfrow=c(2,2))
plot(1:n, punc.response2, type='l', ylab = 'PCT_UNC', xlab = '', col='blue', lwd=2)
plot(1:n, roa.response2, type='l', ylab ='ROA', xlab = '', col='blue', lwd=2)
plot(1:n, invest.response2, type='l', ylab = 'INVEST', xlab = '', col='blue', lwd=2)
plot(1:n, rdsales.response2, type='l', ylab = 'RD-S', xlab = '', col='blue', lwd=2)
dev.off()


