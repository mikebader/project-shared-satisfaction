library(dplyr)
library(ggplot2)
library(stargazer)

rm(list=ls())

dataDIR <- '~/work/data/dcas/dcas2016/'
setwd('~/work/projects/multiethnic_nhoods/')

## Merge preference-level data with respondent-level data
load(paste0(dataDIR,'Dataset/R/DCAS_2016_PreferenceLevel.Rdata'))
prefs <- dcas
load(paste0(dataDIR,'Dataset/R/DCAS_2016_weighted.Rdata'))
prefs <- left_join(prefs, dcas, by='studycase')

## Recode variables
prefs$dem.race <- relevel(prefs$dem.race, ref='white')
prefs$dem.hi_income <- prefs$dem.income.cat4 %in% levels(prefs$dem.income.cat4)[4]
table(prefs[,c('dem.income.cat4','dem.income')])

## Create entropy values for communities
entropy <- function(pct){
    prop <- pct/100
    return(prop*log(1/prop))
}
entropy_max <- sum(sapply(rep(25,4), entropy))
prefs$entropy <- colSums(apply(
    prefs[,c('pctnhw','pctnhb','pctlat','pctapi')], 1, entropy
))/entropy_max * 100

## Drop Langley Park because it is an extreme outlier on entropy
qplot(prefs$entropy)
prefs <- prefs[prefs$commname!='langley.park',]

## Set survey weights
prefs_svy <- svydesign(id=~1,strata=~sample_strata,weights=~weight,data=prefs)

## Model seriously consider on entropy
cons_1 <- svyglm(search_cons ~ entropy*dem.race + search_live ,prefs_svy,family=binomial)
summary(cons_1)
cons_2 <- svyglm(search_cons ~ entropy*dem.race + medval*dem.hi_income + search_live ,prefs_svy,family=binomial)
summary(cons_2)

## Model never consider on entropy
ncons_1 <- svyglm(search_nc ~ entropy*dem.race + search_live ,prefs_svy,family=binomial)
summary(ncons_1)
ncons_2 <- svyglm(search_nc ~ entropy*dem.race + medval*dem.hi_income + search_live ,prefs_svy,family=binomial)
summary(ncons_2)


## Report model results
var_order <- c('entropy','entropy:dem.raceapi', 'entropy:dem.raceblack',
               'entropy:dem.racelatino', 'medval', 'medval:dem.hi_income',
               'dem.raceapi', 'dem.raceblack', 'dem.racelatino',
               'dem.hi_income', 'search_live')
var_labels <- c('Entropy',
                '\\quad $\\times$ Asian', '\\quad $\\times$ Black',
                '\\quad $\\times$ Latino',
                'Median Home Value', '\\quad $\\times$ High income',
                'Asian', 'Black', 'Latino', 'High income',
                'Lives in the community')

stargazer(cons_1, cons_2,
          title="Estimated coefficients for logistic regression of seriously considering communities",
          order=var_order, covariate.labels=var_labels,
          dep.var.caption='', dep.var.labels.include=FALSE,
          no.space=TRUE, align=TRUE, label='tab:consider',
          out='analysis/tables/consider_entropy.tex')

stargazer(ncons_1, ncons_2,
          title="Estimated coefficients for logistic regression of never considering communities",
          order=var_order, covariate.labels=var_labels,
          dep.var.caption='', dep.var.labels.include=FALSE,
          no.space=TRUE, align=TRUE, label='tab:neverconsider',
          out='analysis/tables/never_entropy.tex')







