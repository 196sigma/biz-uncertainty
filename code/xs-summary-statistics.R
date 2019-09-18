## Reginald Edwards
## 20 October 2017
## Cross-sectional summary statistics and plots
## uncertainty by quintiles of accounting variables across the entire sample period

rm(list=ls())
library(ggplot2)
library(stargazer)
source('../0_code/useful-fn.R')
load('data/mda.RData')

## size
## Size hist
summary.plots <- function(v, xs.plot.name, ts.plot.name, xs.xlimits, xs.title = "", ts.title = ""){
  o <- is.na(mda[,v])
  X <- mda[!o, ]
  X <- get.quantiles2(df = X, by.group = 'filingquarter', x = v, g=10)
  v.quantile.name <- paste(v, 'decile', sep='.')
  o1 <- which(X[, v.quantile.name] == 1)
  o10 <- which(X[, v.quantile.name] == 10)
  
  X1 <- X[o1, c('filingquarter', 'p_unc_terms')]
  X2 <- X[o10, c('filingquarter', 'p_unc_terms')]
  
  ## plot a histogram by cross-sectional quintiles
  png(xs.plot.name)
  plot(density(X$p_unc_terms), xlim = xs.xlimits, main = xs.title, ylab = 'PCT_UNC Freq.', xlab='', type='n')
  points(density(X1$p_unc_terms), type='l', col='blue')
  points(density(X2$p_unc_terms), type='l', col='green')
  dev.off()
  
  ## Size TS plot
  
  q1 <- aggregate(X1$p_unc_terms, by = list(X1$filingquarter), FUN = median)
  names(q1) <- c('filingquarter', 'p_unc_terms')
  q10 <- aggregate(X2$p_unc_terms, by = list(X2$filingquarter), FUN = median)
  names(q10) <- c('filingquarter', 'p_unc_terms')
  
  b <- paste(seq(1991,2017,2),'Q1', sep='')
  png(ts.plot.name)
  plot.ts <- ggplot() + 
    geom_line(data = q1,size=1.5,  aes(x = factor(filingquarter), y = p_unc_terms, colour = "Bottom Decile", group=1)) + 
    scale_x_discrete(breaks = b,  labels = b) +
    xlab('Filing Quarter') +
    ylab('PCT_UNC') + 
    geom_line(data = q10, size=1.5, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Top Decile", group=1))+
    scale_colour_manual("", breaks = c("Bottom Decile", "Top Decile"), values = c("red", "blue"))+
    ggtitle(ts.title)+
    theme(plot.title = element_text(hjust = 0.5), legend.position = "bottom")
  print(plot.ts)
  dev.off()
  rm(list=c('X', 'o1', 'o10', 'X1', 'X2', 'q1', 'q10'))
}

## Total Assets
summary.plots(v = 'at', 
              xs.plot.name = 'report/figures/punc-by-at-xs.png', 
              ts.plot.name = 'report/figures/punc-by-at-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Total Assets Decile",
              xs.title = "Distribution of Uncertainty by Total Assets Decile")

## Book-to-Market
summary.plots(v = 'bm', 
              xs.plot.name = 'report/figures/punc-by-bm-xs.png', 
              ts.plot.name = 'report/figures/punc-by-bm-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Book-to-Market Decile",
              xs.title = "Distribution of Uncertainty by Book-to-Market Decile")

## Age
summary.plots(v = 'age', 
              xs.plot.name = 'report/figures/punc-by-age-xs.png', 
              ts.plot.name = 'report/figures/punc-by-age-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Age Decile",
              xs.title = "Distribution of Uncertainty by Age Decile")

## Turnover
summary.plots(v = 'turnover', 
              xs.plot.name = 'report/figures/punc-by-turn-xs.png', 
              ts.plot.name = 'report/figures/punc-by-turn-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Turnover Decile",
              xs.title = "Distribution of Uncertainty by Turnover Decile")

## BASPREAD
#summary.plots(v = 'baspread', 
#              xs.plot.name = 'report/figures/punc-by-baspread-xs.png', 
#              ts.plot.name = 'report/figures/punc-by-baspread-ts.png',
#              xs.xlimits = c(0, 0.04),
#              xs.title = "Uncertainty Trend by Bid-Ask Spread Decile",
#              ts.title = "Distribution of Uncertainty by Bid-Ask Spread Decile")

## SP 500 firms
## Price
summary.plots(v = 'price', 
              xs.plot.name = 'report/figures/punc-by-price-xs.png', 
              ts.plot.name = 'report/figures/punc-by-price-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Stock Price Decile",
              xs.title = "Distribution of Uncertainty by Stock Price Decile")

## Returns
summary.plots(v = 'bhr', 
              xs.plot.name = 'report/figures/punc-by-bhr-xs.png', 
              ts.plot.name = 'report/figures/punc-by-bhr-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Returns Decile",
              xs.title = "Distribution of Uncertainty by Returns Decile")

## Leverage
summary.plots(v = 'leverage', 
              xs.plot.name = 'report/figures/punc-by-leverage-xs.png', 
              ts.plot.name = 'report/figures/punc-by-leverage-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Leverage Decile",
              xs.title = "Distribution of Uncertainty by Leverage Decile")

## TANG
summary.plots(v = 'tang', 
              xs.plot.name = 'report/figures/punc-by-tang-xs.png', 
              ts.plot.name = 'report/figures/punc-by-tang-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Asset Tangibility Decile",
              xs.title = "Distribution of Uncertainty by Asset Tangibility Decile")

## NANALYSTS
summary.plots(v = 'nanalysts', 
              xs.plot.name = 'report/figures/punc-by-nanalysts-xs.png', 
              ts.plot.name = 'report/figures/punc-by-nanalysts-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Analyst Following Decile",
              xs.title = "Distribution of Uncertainty by Analyst Following Decile")
## DISPERSION
summary.plots(v = 'dispersion', 
              xs.plot.name = 'report/figures/punc-by-dispersion-xs.png', 
              ts.plot.name = 'report/figures/punc-by-dispersion-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Analyst Forecast Dispersion Decile",
              xs.title = "Distribution of Uncertainty by Analyst Forecast Dispersion Decile")

## fPE
summary.plots(v = 'pe_fwd', 
              xs.plot.name = 'report/figures/punc-by-pefwd-xs.png', 
              ts.plot.name = 'report/figures/punc-by-pefwd-ts.png',
              xs.xlimits = c(0, 0.04),
              ts.title = "Uncertainty Trend by Forward P/E Decile",
              xs.title = "Distribution of Uncertainty by Forward P/E Decile")

## histograms of annual earnings 1995 and 2015
## histograms of annual rd 1995 and 2015
## histograms of annual investment 1995 and 2015

