## Reginald Edwards
## 17 October 2017
## 7 Nov 2017
## Plots and descriptive stats for uncertainty measures

rm(list=ls())
dev.off()
library(ggplot2)
source('../0_code/ff48.R')
source('../0_code/useful-fn.R')
load('data/mda.RData')

## Time trend
punc.by.quarter <- aggregate(mda$p_unc_terms, by = list(mda$filingquarter), FUN = median)
names(punc.by.quarter) <- c('filingquarter', 'p_unc_terms')

#plot(punc.by.quarter$p_unc_terms, type='l')

b <- paste(seq(1991,2017,2),'Q1', sep='')
png('report/figures/bunc-by-quarter.png')
par(mar=c(5,3,2,2)+0.1)
ggplot() + 
  geom_line(data = punc.by.quarter, aes(x = factor(filingquarter), y = p_unc_terms, group=1)) + 
  scale_x_discrete(breaks = b,  labels = b) +
  xlab('Filing Quarter') +
  ylab('PCT_UNC') +
  xlab('') +
  ggtitle("Business Uncertainty by Filing Quarter") + 
  theme(plot.title = element_text(hjust = 0.5))
dev.off()


## Disaggregated time trends. calcualte uncertainty metrics: average fraction of terms by filing year
group.terms <- function(unc.terms){
  X <- mda[, c('filingquarter', 'n_unc_terms', unc.terms)]
  X$p_unc_terms <- rowSums(X[, unc.terms], na.rm = TRUE)/X$n_unc_terms
  o <- which(is.nan(X$p_unc_terms))
  X[o,'p_unc_terms'] <- 0
  a <- aggregate(X$p_unc_terms, by = list(X$filingquarter), FUN = mean, na.action = na.omit)
  names(a) <- c('filingquarter', 'p_unc_terms')
  return(a)
}
unc.terms1 <- c('uncertain', 'uncertainty')
unc.terms2 <- c('challenges', 'challenge')
unc.terms3 <- c('risks', 'risky', 'risk')
unc.terms4 <- c('decreased', 'decrease', 'pressure', 'reduced', 'reduce', 'reduces')
unc.terms5 <- c('antitrust', 'taxes', 'tax', 'regulation', 'regulate', 'regulated')
unc.terms6 <- c('financing', 'finance')
unc.terms7 <- c('disruptions', 'disruption', 'disrupt')
unc.terms8 <- c('terrorism', 'terror')
unc.terms9 <- c('concern', 'concerns', 'concerned')

a1 <- group.terms(unc.terms1)
a2 <- group.terms(unc.terms2)
a3 <- group.terms(unc.terms3)
a4 <- group.terms(unc.terms4)
a5 <- group.terms(unc.terms5)
a6 <- group.terms(unc.terms6)
a7 <- group.terms(unc.terms7)
a8 <- group.terms(unc.terms8)
a9 <- group.terms(unc.terms9)

mycolors <- rgb(0,1,seq(0,1,.1))[1:9]
b <- paste(seq(1991,2017,2),'Q1', sep='')
ggplot() + 
  geom_line(data = a1, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 1", group=1)) + 
  scale_x_discrete(breaks = b,  labels = b) +
  xlab('Filing Quarter') +
  ylab('punc') +
  geom_line(data = a2, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 2", group=1)) +
  geom_line(data = a3, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 3", group=1)) +
  geom_line(data = a4, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 4", group=1)) +
  geom_line(data = a5, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 5", group=1)) +
  geom_line(data = a6, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 6", group=1)) +
  geom_line(data = a7, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 7", group=1)) +
  geom_line(data = a8, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 8", group=1)) +
  geom_line(data = a9, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Group 9", group=1)) +
  scale_colour_manual("", breaks = c("Group 1", "Group 2", "Group 3", "Group 4", "Group 5", "Group 6", "Group 7", "Group 8","Group 9"), values = mycolors) +
  xlab(" ") +
  labs(title="TITULO")
  
  
  
## by industry
## SIC 2
# mda$sic2 <- substr(mda$sich,1,2)
# table(mda$sic2)
# ## Fama-French 48
# #mda[, c("ff48", "ff48desc")] <- sapply(X = list(mda$sich), FUN = get.ff48)
# mda[,c('ff48', 'ff48desc')] <- c(NA, NA)
# for(i in 1:nrow(mda)){
#   if(mda[i,'sich']){
#     mda[i,c('ff48', 'ff48desc')] <- get.ff48(mda[i,'sich'])  
#   }
# }

## Calculate time trends for uncertainty by market cap quintile
mda <- get.quantiles(df = mda, by.group = filingquarter, x = mve)
o <- which(mda$mvequint == 1)
X <- mda[o, c('filingquarter', 'p_unc_terms')]
q1 <- aggregate(X$p_unc_terms, by = list(X$filingquarter), FUN = mean, na.action = na.omit)
names(q1) <- c('filingquarter', 'p_unc_terms')

o <- which(mda$mvequint == 5)
X <- mda[o, c('filingquarter', 'p_unc_terms')]
q5 <- aggregate(X$p_unc_terms, by = list(X$filingquarter), FUN = mean, na.action = na.omit)
names(q5) <- c('filingquarter', 'p_unc_terms')

b <- paste(seq(1991,2017,2),'Q1', sep='')
png('report/figures/bunc-by-mve.png', width = 480*1.5, height = 480*1.5)
ggplot() + 
  geom_line(data = q1,size=1.5,  aes(x = factor(filingquarter), y = p_unc_terms, colour = "Bottom Quintile", group=1)) + 
  scale_x_discrete(breaks = b,  labels = b) +
  xlab('Filing Quarter') +
  ylab('punc') + 
  geom_line(data = q5, size=1.5, aes(x = factor(filingquarter), y = p_unc_terms, colour = "Top Quintile", group=1))+
  scale_colour_manual("", breaks = c("Bottom Quintile", "Top Quintile"), values = c("red", "blue"))+
  ggtitle("Uncertainty by Market Capitalization")+
  theme(plot.title = element_text(hjust = 0.5), legend.position = "bottom")
dev.off()