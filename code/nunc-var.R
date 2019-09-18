## nunc-var.R
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

## NUM_UNC VAR analyses
var.variables <- c('n_unc_terms', 'roa', 'invest', 'rdsales')
nunc.var1 <- VAR(y = X[, var.variables], p = 1, type = "const"); summary(nunc.var1)
nunc.var2 <- VAR(y = X[, var.variables], p = 2, type = "const"); summary(nunc.var2)
nunc.var3 <- VAR(y = X[, var.variables], p = 3, type = "const"); summary(nunc.var3)
nunc.var4 <- VAR(y = X[, var.variables], p = 4, type = "const"); summary(nunc.var4)

## Casaulity tests
causality(nunc.var1, cause = 'n_unc_terms')
causality(nunc.var2, cause = 'n_unc_terms')
causality(nunc.var3, cause = 'n_unc_terms')
causality(nunc.var4, cause = 'n_unc_terms')

## Impulse-Response Functions
nunc.irf1 <- irf(nunc.var1, response = 'n_unc_terms', n.head = 6, boot = T)
#plot(nunc.irf1)

## export plots of IRFs
nunc.response1 <- nunc.irf1$irf$n_unc_terms
roa.response1 <- nunc.irf1$irf$roa
invest.response1 <- nunc.irf1$irf$invest
rdsales.response1 <- nunc.irf1$irf$rdsales
n <- length(nunc.response1)

png('report/figures/nunc-irf-1.png')
par(mfrow=c(2,2))
plot(1:n, nunc.response1, type='l', ylab = 'NUM_UNC', xlab = '', col='blue', lwd=2)
plot(1:n, roa.response1, type='l', ylab ='ROA', xlab = '', col='blue', lwd=2)
plot(1:n, invest.response1, type='l', ylab = 'INVEST', xlab = '', col='blue', lwd=2)
plot(1:n, rdsales.response1, type='l', ylab = 'RD-S', xlab = '', col='blue', lwd=2)
dev.off()


## (p = 2) IRF
nunc.irf2 <- irf(nunc.var2, response = 'n_unc_terms', n.head = 6, boot = T)
nunc.response2 <- nunc.irf2$irf$n_unc_terms
roa.response2 <- nunc.irf2$irf$roa
invest.response2 <- nunc.irf2$irf$invest
rdsales.response2 <- nunc.irf2$irf$rdsales
n <- length(nunc.response2)

png('report/figures/nunc-irf-2.png')
par(mfrow=c(2,2))
plot(1:n, nunc.response2, type='l', ylab = 'NUM_UNC', xlab = '', col='blue', lwd=2)
plot(1:n, roa.response2, type='l', ylab ='ROA', xlab = '', col='blue', lwd=2)
plot(1:n, invest.response2, type='l', ylab = 'INVEST', xlab = '', col='blue', lwd=2)
plot(1:n, rdsales.response2, type='l', ylab = 'RD-S', xlab = '', col='blue', lwd=2)
dev.off()

## (p = 4) IRF
nunc.irf4 <- irf(nunc.var4, response = 'n_unc_terms', n.head = 6, boot = T)
nunc.response4 <- nunc.irf4$irf$n_unc_terms
roa.response4 <- nunc.irf4$irf$roa
invest.response4 <- nunc.irf4$irf$invest
rdsales.response4 <- nunc.irf4$irf$rdsales
n <- length(nunc.response4)

png('report/figures/nunc-irf-4.png')
par(mfrow=c(2,2))
plot(1:n, nunc.response4, type='l', ylab = 'NUM_UNC', xlab = '', col='blue', lwd=2)
plot(1:n, roa.response4, type='l', ylab ='ROA', xlab = '', col='blue', lwd=2)
plot(1:n, invest.response4, type='l', ylab = 'INVEST', xlab = '', col='blue', lwd=2)
plot(1:n, rdsales.response4, type='l', ylab = 'RD-S', xlab = '', col='blue', lwd=2)
dev.off()

