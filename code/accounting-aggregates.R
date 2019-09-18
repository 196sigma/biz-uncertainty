## Reginald Edwards
## 8 Nov 2017
## 14 Nov 2017
## Make time-series plots of the aggregate accounting variables of interest (ROA, RD, INVEST)

rm(list=ls())
dev.off()
library(sas7bdat)
library(ggplot2)
source('../0_code/useful-fn.R')
aggs.q <- read.sas7bdat("data/accaggq.sas7bdat")
names(aggs.q) <- tolower(names(aggs.q))
summary(aggs.q)
o <- which(aggs.q$datafqtr == '')
if(length(o)>0) aggs.q <- aggs.q[-o,]

## Summary Statistics
## Plots
## time series plot of quarterly earnings (roa)
b <- paste(seq(1991,2017,2),'Q1', sep='')

png('report/figures/roa-ts.png')
ggplot() +
  geom_line(data = aggs.q, size=1, aes(x=factor(datafqtr), y=roa, group=1)) +
  scale_x_discrete(breaks = b,  labels = b) +
  xlab('Filing Quarter') +
  ylab('ROA')+
  ggtitle("Time series of earnings (ROA).")+
  theme(plot.title = element_text(hjust = 0.5))
dev.off()

## time series plot of quarterly rd, four quarter moving averages
aggs.q$rd.ma <- as.numeric(ma(log(aggs.q$rd)))
aggs.q$rdsales.ma <- as.numeric(ma(aggs.q$rdsales))
aggs.q$rdearn.ma <- as.numeric(ma(aggs.q$rdearn))
aggs.q$rdeq.ma <- as.numeric(ma(aggs.q$rdeq))

aggs.q$rdsales.ma.scaled <- aggs.q$rdsales.ma/aggs.q[2, 'rdsales.ma']
aggs.q$rdearn.ma.scaled <- aggs.q$rdearn.ma/aggs.q[2, 'rdearn.ma']
aggs.q$rdeq.ma.scaled <- aggs.q$rdeq.ma/aggs.q[2, 'rdeq.ma']

png('report/figures/rd-ts.png')
ggplot() +
  geom_line(data = aggs.q, size=1, aes(x=factor(datafqtr), y=rdsales.ma.scaled, color = "RDSales", group=1)) +
  scale_x_discrete(breaks = b,  labels = b) +
  xlab('Filing Quarter') +
  ylab('RD') +
  geom_line(data = aggs.q, size=1, aes(x=factor(datafqtr), y=rdeq.ma.scaled, color = "RDEQ", group=1)) +
  geom_line(data = aggs.q, size=1, aes(x=factor(datafqtr), y=rdearn.ma.scaled, color = "RDEARN", group=1)) +
  scale_colour_manual("", breaks = c("RDSales", "RDEQ", "RDEARN"), values = c("purple", "blue", "green"))+
  ggtitle("Time series of R&D as a fraction of sales, equity, and net income.")+
  theme(plot.title = element_text(hjust = 0.5), legend.position="bottom")
dev.off()

## time series plot of quarterly investment
png('report/figures/invest-ts.png')
ggplot() +
  geom_line(data = aggs.q, size=1, aes(x=factor(datafqtr), y=invest, group=1)) +
  scale_x_discrete(breaks = b,  labels = b) +
  xlab('Filing Quarter') +
  ylab('INVEST')+
  ggtitle("Time series of investment.") +
  theme(plot.title = element_text(hjust = 0.5))
dev.off()
