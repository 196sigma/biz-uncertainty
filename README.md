## Biz Uncertainty
### Reginald Edwards
### 2018
Measuring aggregate business uncertainty from firms' filings (10-K's.)
### CODE
* uncertainty-summary-statistics.R: Plots and descriptive stats for uncertainty measures
	- 'report/figures/bunc-by-quarter.jpeg'
	- 
	
* xs-summary-statistics: uncertainty by quintiles of accounting variables across the entire sample period
	- 'report/figures/punc-by-at-xs.jpeg'
	- 'report/figures/punc-by-at-ts.jpeg'
	-
	
* accounting-aggregates.R: Make time-series plots of the aggregate accounting variables of interest (ROA, RD, INVEST)
	- 'report/figures/roa-ts.png'
	- 'report/figures/rd-ts.png'
	- 'report/figures/invest-ts.png'

	* summary-statistics.R

* ts-analysis.R: Trend, seasonality, and business cycle analysis, stats, and plots
	- 'report/figures/nunc-acf.png'
	- 'report/figures/punc-acf.png'
	- 'report/figures/roa-acf.png'
	- 'report/figures/invest-acf.png'
	- 'report/figures/rdearn-acf.png'
	- 'report/figures/rdsales-acf.png'
	- 'report/figures/rdeq-acf.png'
	
* nunc-var.R: Vector autoregression analysis and plots for NUM_UNC variable
* punc-var.R: Vector autoregression analysis and plots for PCT_UNC variable

* xs-ols-validation.R: Cross-sectional validation (regression of uncertainty measure on controls)
	- 'report/tables/punc-xs-ols.tex'

* ols-forecast-roa.R	
	- 'report/tables/ols-forecast-roa.tex'
	
* ols-forecast-rd.R	
	- 'report/tables/ols-forecast-rd.tex'
	
* ols-forecast-invest.R	
	- 'report/tables/ols-forecast-invest.tex'

* xs-ols-tests.R: Cross-Sectional Regressions and Forecasts
	- report/tables/bunc-xs-ols-tests.tex
	- report/tables/bunc-xs-ols-forecasts.tex
