## Trend, seasonality, and business cycle analysis, stats, and plots
rm(list=ls())
dev.off()
#library(forecast)
#library(plotrix)
#library(MSBVAR)
#library(stats)
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

nunc <- as.ts(X[3:n, 'n_unc_terms'], start = c(2000, 1), frequency = 4)
punc <- as.ts(X[3:n, 'p_unc_terms'], start = c(2000, 1), frequency = 4)
roa <- as.ts(X[3:n, 'roa'])
invest <- as.ts(X[3:n, 'invest'])
rdsales <- as.ts(X[3:n, 'rdsales'])
rdearn <- as.ts(X[3:n, 'rdearn'])
rdeq <- as.ts(X[3:n, 'rdeq'])

## TODO: Time series of P-UNC, B-UNC Terms, RD, and ROA on one graph
start.quarter <- '2000Q1'
stop.quarter <- '2015Q4'
nquarters <- (2015-2000+1)*4

## Sample Autocorrelations and Partial Autocorrelations
# N-UNC
png('report/figures/nunc-acf.png')
par(mfrow=c(2,1))
nunc.acf <- acf(nunc, type='correlation', plot=FALSE)
plot(nunc.acf, col='blue', xlab = 'Displacement', 
     ylab = 'NUM_UNC Autocorrelation', 
     main = '')

nunc.pacf <- pacf(nunc, plot = FALSE)
plot(nunc.pacf, col='blue', xlab = 'Displacement', 
     ylab = 'NUM_UNC Partial Autocorrelation', 
     main = '')
dev.off()

# P-UNC
png('report/figures/punc-acf.png')
par(mfrow=c(2,1))
punc.acf <- acf(punc, type='correlation', plot=FALSE)
plot(punc.acf, col='blue', xlab = 'Displacement', 
     ylab = 'PCT-UNC Autocorrelation', 
     main = '')

punc.pacf <- pacf(punc, plot = FALSE)
plot(punc.pacf, col='blue', xlab = 'Displacement', 
     ylab = 'PCT-UNC Partial Autocorrelation', 
     main = '')
dev.off()

## ROA
png('report/figures/roa-acf.png')
par(mfrow=c(2,1))
roa.acf <- acf(punc, type='correlation', plot=FALSE)
plot(roa.acf, col='blue', xlab = 'Displacement', 
     ylab = 'ROA Autocorrelation', 
     main = '')

roa.pacf <- pacf(punc, plot = FALSE)
plot(roa.pacf, col='blue', xlab = 'Displacement', 
     ylab = 'ROA Partial Autocorrelation', 
     main = '')
dev.off()

## RD-Earn
png('report/figures/rdearn-acf.png')
par(mfrow=c(2,1))
rdearn.acf <- acf(rdearn, type='correlation', plot=FALSE)
plot(rdearn.acf, col='blue', xlab = 'Displacement', 
     ylab = 'RD-NI Autocorrelation', 
     main = '')

rdearn.pacf <- pacf(rdearn, plot = FALSE)
plot(rdearn.pacf, col='blue', xlab = 'Displacement', 
     ylab = 'PCT-UNC Partial Autocorrelation', 
     main = '')
dev.off()

## RD-Sales
png('report/figures/rdsales-acf.png')
par(mfrow=c(2,1))
rdsales.acf <- acf(rdsales, type='correlation', plot=FALSE)
plot(rdsales.acf, col='blue', xlab = 'Displacement', 
     ylab = 'RD-S Autocorrelation', 
     main = '')

rdsales.pacf <- pacf(rdsales, plot = FALSE)
plot(rdsales.pacf, col='blue', xlab = 'Displacement', 
     ylab = 'RD-S Partial Autocorrelation', 
     main = '')
dev.off()

## RD-Book
png('report/figures/rdeq-acf.png')
par(mfrow=c(2,1))
rdeq.acf <- acf(rdeq, type='correlation', plot=FALSE)
plot(rdeq.acf, col='blue', xlab = 'Displacement', 
     ylab = 'RD-Book Autocorrelation', 
     main = '')

rdeq.pacf <- pacf(rdeq, plot = FALSE)
plot(rdeq.pacf, col='blue', xlab = 'Displacement', 
     ylab = 'RD-Book Partial Autocorrelation', 
     main = '')
dev.off()

## Investment
png('report/figures/invest-acf.png')
par(mfrow=c(2,1))
invest.acf <- acf(invest, type='correlation', plot=FALSE)
plot(invest.acf, col='blue', xlab = 'Displacement', 
     ylab = 'INVEST Autocorrelation', 
     main = '')

invest.pacf <- pacf(invest, plot = FALSE)
plot(invest.pacf, col='blue', xlab = 'Displacement', 
     ylab = 'INVEST Partial Autocorrelation', 
     main = '')
dev.off()

## Sample Cross Correlations 
## PCT-UNC and ROA
png('report/figures/ccf.png')
par(mfrow=c(3,1))
punc.roa.ccf <- ccf(punc, roa, type = "correlation", plot = FALSE)
plot(punc.roa.ccf, col="blue", xlab="Displacement", 
     ylab = '',
     main="Uncertainty and Earnings Sample Cross Correlations")

## PCT-UNC and Investment
punc.invest.ccf <- ccf(punc, invest, type = "correlation", plot = FALSE)
plot(punc.invest.ccf, col="blue", xlab="Displacement", 
     ylab = '',
     main="Uncertainty and Investment Sample Cross Correlations")

## PCT-UNC and RD
punc.rdsales.ccf <- ccf(punc, rdsales, type = "correlation", plot = FALSE)
plot(punc.rdsales.ccf, col="blue", xlab="Displacement", 
     ylab = '',
     main="Uncertainty and R&D Sample Cross Correlations")
dev.off()