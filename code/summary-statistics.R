###################################################################################################
## summary-statistics.R
## AUTHOR:
## CREATED: 7 Nov 2017
## MODIFIED:
## DESCRIPTION:
###################################################################################################

setwd("C:/Users/Reginald/Dropbox/Research/biz-uncertainty")

rm(list=ls())

library(sas7bdat)
library(stargazer)
library(xtable)
source('../0_code/useful-fn.R')

## Read in and prepare data
load('data/mda.RData')
X <- mda
factors <- sapply(X, is.factor); X[factors] <- lapply(X[factors], as.character) ## Covnert factors to characters

varnames <- list()
varnames[["age"]]="AGE"
varnames[["at"]]="AT"
varnames[["baspread"]]="BASPREAD"
varnames[["bhr"]]="BHR"
varnames[["div"]]="DIV"
varnames[["leverage"]]="LEVERAGE"
varnames[["mve"]]="MVE"
varnames[["nanalysts"]]="ANALYSTS"
varnames[["pe_fwd"]]="PE"
varnames[["price"]]="PRICE"
varnames[["q"]]="Q"
varnames[["roa"]]="ROA"
varnames[["sp500"]]="SP500"
varnames[["tang"]]="TANG"
varnames[["turnover"]]="TURNOVER"
varnames[["negearn"]]="LOSS"
varnames[["dispersion"]]="DISPERSION"
varnames[["invest"]]="INVEST"
varnames[["rdsales"]]="RD-S"
varnames[["rdearn"]]="RD-NI"
varnames[["rdeq"]]="RD-BOOK"

## OLS sample
summary.stats <- get.summary.stats(X, variables)
write.csv(summary.stats, file="report/tables/summary-stats.csv")

(X.cor <- cor(X[, c(variables,"n_unc_terms", "p_unc_terms")], use="pairwise.complete.obs", method = "spearman"))
cornames <- row.names(X.cor)
row.names(X.cor) <- paste("(", 1:length(cornames), ")", sep="")
colnames(X.cor) <- paste("(", 1:length(cornames), ")", sep="")
corcaption <- "\\tiny "
for(i in 1:length(cornames)) corcaption <- paste(corcaption, row.names(X.cor)[i], ": ", varnames[[cornames[i]]], "; ", sep="")

upper<-round(X.cor,3)
upper[upper.tri(X.cor)]<-""
(upper<- as.data.frame(upper))
print.xtable(xtable(upper, caption=corcaption, digits=3) ,floating = TRUE, floating.environment = "sidewaystable", type="latex", file="report/tables/correlation-matrix.tex")
