## 9 Nov 2017
## Reginald Edwards
## Cross-Sectional Regressions and Forecasts

rm(list=ls())
source('../0_code/useful-fn.R')
library(sas7bdat)
library(stargazer)

## Load data
load('data/mda.RData')
  
## Contemp
m1 <- lm(roa ~ roa_lag1 + p_unc_terms + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m1)
m2 <- lm(roa ~ roa_lag1 + n_unc_terms + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m2)
m3 <- lm(rdsales ~ rdsales_lag1 + p_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m3)
m4 <- lm(rdsales ~ rdsales_lag1 + n_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m4)
m5 <- lm(invest ~ invest_lag1 + p_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m5)
m6 <- lm(invest ~ invest_lag1 + n_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m6)

## ROA
xs.impact(mda, 'p_unc_terms', m1)
xs.impact(mda, 'n_unc_terms', m2)
## RD-S
xs.impact(mda, 'p_unc_terms', m3)
xs.impact(mda, 'n_unc_terms', m4)
## INVEST
xs.impact(mda, 'p_unc_terms', m5)
xs.impact(mda, 'n_unc_terms', m6)

## One-year-ahead
m7 <- lm(roa_lead1 ~ roa + p_unc_terms + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m7)
m8 <- lm(roa_lead1 ~ roa + n_unc_terms + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m8)
m9 <- lm(rdsales_lead1 ~ rdsales + p_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m9)
m10 <- lm(rdsales_lead1 ~ rdsales + n_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m10)
m11 <- lm(invest_lead1 ~ invest + p_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m11)
m12 <- lm(invest_lead1 ~ invest + n_unc_terms + roa + I(log(at)) + q + mve + sp500 + pe_fwd + age + leverage + div + tang + price + bhr + nanalysts + dispersion + I(fyear) + I(ff48), data=mda); summary(m12)

xs.impact(mda, 'p_unc_terms', m7)
xs.impact(mda, 'n_unc_terms', m8)
xs.impact(mda, 'p_unc_terms', m9)
xs.impact(mda, 'n_unc_terms', m10)
xs.impact(mda, 'p_unc_terms', m11)
xs.impact(mda, 'n_unc_terms', m12)

## pretty print variable names
m1.in.names <- c("(Intercept)", "roa_lag1", "p_unc_terms", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m1.out.names <- c("Const.", "ROA(t-1)", "PCT_UNC", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m2.in.names <- c("(Intercept)", "roa_lag1", "n_unc_terms", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m2.out.names <- c("Const.", "ROA(t-1)", "NUM_UNC", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m3.in.names <- c("(Intercept)", "rdsales_lag1", "p_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m3.out.names <- c("Const.", "RD-S(t-1)", "PCT_UNC","ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m4.in.names <- c("(Intercept)", "rdsales_lag1", "n_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m4.out.names <- c("Const.", "RD-S(t-1)", "NUM_UNC", "ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m5.in.names <- c("(Intercept)", "invest_lag1", "p_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m5.out.names <- c("Const.", "INVEST(t-1)", "PCT_UNC", "ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m6.in.names <- c("(Intercept)", "invest_lag1", "n_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m6.out.names <- c("Const.", "INVEST(t-1)", "NUM_UNC", "ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m7.in.names <- c("(Intercept)", "roa_lag1", "p_unc_terms", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m7.out.names <- c("Const.", "ROA(t-1)", "PCT_UNC", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m8.in.names <- c("(Intercept)", "roa_lag1", "n_unc_terms", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m8.out.names <- c("Const.", "ROA(t-1)", "NUM_UNC", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m9.in.names <- c("(Intercept)", "rdsales_lag1", "p_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m9.out.names <- c("Const.", "RD-S(t-1)", "PCT_UNC", "ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m10.in.names <- c("(Intercept)", "rdsales_lag1", "n_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m10.out.names <- c("Const.", "RD-S(t-1)", "NUM_UNC", "ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m11.in.names <- c("(Intercept)", "invest_lag1", "p_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m11.out.names <- c("Const.", "INVEST(t-1)", "PCT_UNC", "ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m12.in.names <- c("(Intercept)", "invest_lag1", "n_unc_terms", "roa", "I(log(at))", "q", "mve", "sp500", "pe_fwd", "age", "leverage", "div", "tang", "price", "bhr", "nanalysts", "dispersion")
m12.out.names <- c("Const.", "INVEST(t-1)", "NUM_UNC", "ROA", "ASSETS", "Q", "MVE", "SP500", "PE", "AGE", "LEVERAGE", "DIV", "TANG", "PRICE", "RETURN", "NANALYSTS", "DISPERSION")

m1 <- names.lm(m1, in.names = m1.in.names, out.names = m1.out.names)
m2 <- names.lm(m2, in.names = m2.in.names, out.names = m2.out.names)
m3 <- names.lm(m3, in.names = m3.in.names, out.names = m3.out.names)
m4 <- names.lm(m4, in.names = m4.in.names, out.names = m4.out.names)
m5 <- names.lm(m5, in.names = m5.in.names, out.names = m5.out.names)
m6 <- names.lm(m6, in.names = m6.in.names, out.names = m6.out.names)
m7 <- names.lm(m7, in.names = m7.in.names, out.names = m7.out.names)
m8 <- names.lm(m8, in.names = m8.in.names, out.names = m8.out.names)
m9 <- names.lm(m9, in.names = m9.in.names, out.names = m9.out.names)
m10 <- names.lm(m10, in.names = m10.in.names, out.names = m10.out.names)
m11 <- names.lm(m11, in.names = m11.in.names, out.names = m11.out.names)
m12 <- names.lm(m12, in.names = m12.in.names, out.names = m12.out.names)

## Export tables
stargazer(m1, m2, m3, m4, m5, m6,
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
          keep = unique(c(m1.out.names, m2.out.names, m3.out.names, m4.out.names, m5.out.names, m6.out.names)),
          label="xs-ols-contemp",
          title="Business Uncertainty Contemporaneous Cross-Sectional Regressions",
          out="report/tables/bunc-xs-ols-tests.tex")

stargazer(m7, m8, m9, m10, m11, m12,
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
          keep = unique(c(m7.out.names, m8.out.names, m9.out.names, m10.out.names, m11.out.names, m12.out.names)),
          label="levels",
          title="Business Uncertainty Cross-Sectional Forecasts",
          out="report/tables/bunc-xs-ols-forecasts.tex")