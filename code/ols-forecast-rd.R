## OLS regressions of one-quarter-ahead RD
## OLS regressions of one-quarter-ahead ROA
rm(list=ls())
library(sas7bdat)
library(ggplot2)
library(stargazer)
source('../0_code/useful-fn.R')

## load data
load('data/uncertainty-metrics-ts.RData')
aggs.q <- read.sas7bdat("data/accaggq.sas7bdat")
names(aggs.q) <- tolower(names(aggs.q))
o <- which(aggs.q$datafqtr == '')
if(length(o)>0) aggs.q <- aggs.q[-o,]

X <- merge(terms.by.quarter, aggs.q, by.x = 'filingquarter', by.y = 'datafqtr')

##
## load aggregate control variables
aggcontrolsq <- read.sas7bdat('data/aggcontrolsq.sas7bdat')
aggcontrolsq <- subset(aggcontrolsq, select = -c(rd, roa))
X <- merge(X, aggcontrolsq, by.x = 'filingquarter', by.y = 'datafqtr')
n <- nrow(X)

## Load EPU data
load('data/epuq.RData')
X <- merge(X, epuq, by.x = 'filingquarter', by.y = 'yearqtr')

##
X$rdsales.lead1 <- c(X[2:n, 'rdsales'], NA)
X$rdsales.lag1 <- c(NA, X[1:(n-1), 'rdsales'])

## OLS Models
m1 <- lm(rdsales.lead1 ~ p_unc_terms + roa + rdsales.lag1 + I(log(atq)) + I(log(mve)) + bhr + turnover + leverage + tang + div + pe, data = X); summary(m1)
m2 <- lm(rdsales.lead1 ~ n_unc_terms + roa + rdsales.lag1 + I(log(atq)) + I(log(mve)) + bhr + turnover + leverage + tang + div + pe, data = X); summary(m2)
m3 <- lm(rdsales.lead1 ~ p_unc_terms + epu + roa + rdsales.lag1 + I(log(atq)) + I(log(mve)) + bhr + turnover + leverage + tang + div + pe, data = X); summary(m3)
m4 <- lm(rdsales.lead1 ~ n_unc_terms + epu + roa + rdsales.lag1 + I(log(atq)) + I(log(mve)) + bhr + turnover + leverage + tang + div + pe, data = X); summary(m4)

## Get Cross-Sectional Impact
xs.impact(X, 'p_unc_terms', m1)
xs.impact(X, 'n_unc_terms', m2)
xs.impact(X, 'p_unc_terms', m3)
xs.impact(X, 'n_unc_terms', m4)

## pretty print variable names
m1.in.names <- c("(Intercept)", "p_unc_terms", "roa", "rdsales.lag1", "I(log(atq))", "I(log(mve))", "bhr", "turnover", "leverage", "tang", "div", "pe")
m1.out.names <- c("Const.", "PCT_UNC", "ROA", "RD-s", "ASSETS", "MVE", "RETURN", "TURNOVER", "LEVERAGE", "TANG", "DIV", "PE")
m1 <- names.lm(m1, in.names = m1.in.names, out.names = m1.out.names)

m2.in.names <- c("(Intercept)", "n_unc_terms", "roa", "rdsales.lag1", "I(log(atq))", "I(log(mve))", "bhr", "turnover", "leverage", "tang", "div", "pe")
m2.out.names <- c("Const.", "NUM_UNC", "ROA", "RD-s", "ASSETS", "MVE", "RETURN", "TURNOVER", "LEVERAGE", "TANG", "DIV", "PE")
m2 <- names.lm(m2, in.names = m2.in.names, out.names = m2.out.names)

m3.in.names <- c("(Intercept)", "p_unc_terms", "epu", "roa", "rdsales.lag1", "I(log(atq))", "I(log(mve))", "bhr", "turnover", "leverage", "tang", "div", "pe")
m3.out.names <- c("Const.", "PCT_UNC","BBD_EPU", "ROA", "RD-s", "ASSETS", "MVE", "RETURN", "TURNOVER", "LEVERAGE", "TANG", "DIV", "PE")
m3 <- names.lm(m3, in.names = m3.in.names, out.names = m3.out.names)

m4.in.names <- c("(Intercept)", "n_unc_terms", "epu", "roa", "rdsales.lag1", "I(log(atq))", "I(log(mve))", "bhr", "turnover", "leverage", "tang", "div", "pe")
m4.out.names <- c("Const.", "NUM_UNC","BBD_EPU", "ROA", "RD-s", "ASSETS", "MVE", "RETURN", "TURNOVER", "LEVERAGE", "TANG", "DIV", "PE")
m4 <- names.lm(m4, in.names = m4.in.names, out.names = m4.out.names)

## print tables
stargazer(m1, m3, m2, m4,
          float=TRUE, 
          float.env="table", 
          table.placement="H", 
          digits=4, 
          single.row=FALSE,
          align=TRUE, 
          no.space=TRUE, 
          font.size="footnotesize",
          omit.stat=c("LL", "f", "ser"), 
          #notes = "Year and Industry fixed effects included.", 
          keep = unique(c(m1.out.names, m2.out.names, m3.out.names, m4.out.names)),
          notes.append=TRUE,
          model.names=TRUE,
          label="ols-forecast-rd",
          title="Forecasts of Aggregate RD",
          out="report/tables/ols-forecast-rd.tex")


## OOS RMSE
k <- 59
train.sample <- X[1:k, ]
test.sample <- X[(k+1):(n-1), ]
actual <- test.sample$rdsales.lead1
forecast.m1 <- lm(rdsales.lead1 ~ roa + rdsales + I(log(atq)) + I(log(mve)) + bhr + leverage + tang + div + pe, data = train.sample)
pred.m1 <- predict.lm(forecast.m1, test.sample)
rmse.m1 <- sqrt(mean((actual - pred.m1)**2))
mae.m1 <-  mean(abs(actual - pred.m1))


forecast.m2 <- lm(rdsales.lead1 ~ p_unc_terms + roa + rdsales + I(log(atq)) + I(log(mve)) + bhr + leverage + tang + div + pe, data = train.sample)
pred.m2 <- predict.lm(forecast.m2, test.sample)
rmse.m2 <- sqrt(mean((actual - pred.m2)**2))
mae.m2 <-  mean(abs(actual - pred.m2))

forecast.m3 <- lm(rdsales.lead1 ~ n_unc_terms + roa + rdsales + I(log(atq)) + I(log(mve)) + bhr + leverage + tang + div + pe, data = train.sample)
pred.m3 <- predict.lm(forecast.m3, test.sample)
rmse.m3 <- sqrt(mean((actual - pred.m3)**2))
mae.m3 <-  mean(abs(actual - pred.m3))

A <- data.frame(m = c('RMSE', 'MAE'), m1 = c(NA, NA), m2 = c(NA, NA), m3 = c(NA, NA))
A[1,1] <- 'RMSE'
A[2,1] <- 'MAE'
A[1,'m1'] <- rmse.m1
A[1,'m2'] <- rmse.m2
A[1,'m3'] <- rmse.m3
A[2,'m1'] <- mae.m1
A[2,'m2'] <- mae.m2
A[2,'m3'] <- mae.m3
