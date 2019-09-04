## Creates table comparing demographic characteristics of multiethnic
## neighborhoods in DC Area to all neighborhoods in the DC Area.

library(knitr)
library(tidyverse)
library(xtable)
DIR <- '~/work/projects/multiethnic_nhoods/'
DATADIR <- '~/work/data/nhgis/DCArea/tracts/2010/tabular/'

setwd(DIR)

vartypes <- c(
    'children-present',
    'educ-attainment',
    'foreign-born',
    'marital-status',
    'median-age',
    'race-ethnicity'
)

## FUNCTIONS
## Load DC Area data for category of variable
dcarea.data <- function(vartype) {
    f <- paste0(DATADIR, vartype, '/dataset/tracts-2010TIGER-', vartype, '.csv')
    return(read.csv(f))
}

## Return 2-item vector containing mean and standard deviation of variable
meansd <- function(var) {
    return(c(mean=mean(var, na.rm=TRUE), sd=sd(var, na.rm=TRUE)))
}

## Function to create split violin plots
source('analysis/dcarea/split-violin-functions.R')

## DATA PROCESSING
## Load and join data from different categories of variables
dcarea <- lapply(vartypes, dcarea.data) %>%
    reduce(left_join, by='GISJOIN') %>%
    select('GISJOIN', ends_with('15'))

## Calculate proportion of DC-area population made up each racial group
## In 1980
fname <- paste(DATADIR, '../..', '1980/tabular/race-ethnicity/dataset',
                'tracts-1980TIGER-race-ethnicity.csv', sep='/')
dcarea80 <- read.csv(fname)
dcarea80 <- sapply(dcarea80[,c('totpop', 'nhw','nhb','hsp','api')], sum)
print('Per')
prace80 <- round(sapply(dcarea80[2:5], function(x) x/dcarea80[1]),3)*100
kable(prace80,
      caption='Percentage of DC-area residents in each racial group')

## In 2010
n.hsp <- sum(dcarea$hsp15)
n.api <- sum(dcarea$api15)
n.nhw <- sum(dcarea$nhw15)
n.nhb <- sum(dcarea$nhb15)
n.totpop <- sum(dcarea$totpop15)

p.hsp <- n.hsp/n.totpop
p.api <- n.api/n.totpop
p.nhw <- n.nhw/n.totpop
p.nhb <- n.nhb/n.totpop

dcarea.race <- data.frame(
    race=c('Latinx','Asian','Non-Hispanic white', 'Non-Hispanic black'),
    vals=c(p.hsp, p.api, p.nhw, p.nhb))
kable(dcarea.race,
      caption='Percent of DC-area made up of each racial group')

## Calculate percentage of residents that are foreign-born in DC area
print('Percent foreign-born:')
print(sum(dcarea$fbpop15)/sum(dcarea$totpop15))

## Report largest three countries of origin in DC area
source('analysis/dcarea/report-countries-of-origin.R')

## Report percentage of U.S. and DC-area residents with BA or graduate
## degrees by foreign-born status
source('analysis/dcarea/report-educ-by-foreign-born.R')
kable(fbeduc.comp,
      caption='Percent of foreign-born residents in DC area and US with college degrees')

## Report number of people living in multiracial neighborhoods
quadpop <- sum(dcarea[dcarea$quad15==TRUE, 'totpop15'], na.rm=TRUE)
print('Number of people living in multiracial neighborhoods:')
quadpop

## Construct variables for analytic table, and keep only those variables
dcarea <- dcarea %>% mutate(
    ## Children present in HH
    pchildpres = pchpr15 * 100,

    ## Educational attainment
    peduc.lhs = plh15 * 100,
    peduc.hs = phs15 * 100,
    peduc.somecoll = (psc15 + paa15) * 100,
    peduc.ba = pba15 * 100,
    peduc.ma = pgr15 * 100,

    ## Foreign-born
    pfborn = fbpop15 / totpop15 * 100,

    ## Currently married
    pmarried = pmar15 * 100,

    ## Median age (no new variable necessary)

    ## Race-ethnicity
    race.papi = papi15 * 100,
    race.phsp = phsp15 * 100,
    race.pnhb = pnhb15 * 100,
    race.pnhw = pnhw15 * 100
) %>%
    select(GISJOIN, totpop15, pchildpres, pfborn, pmarried, mdage15,
           starts_with('peduc'), starts_with('race'), quad15)

## CONSTRUCT TABLE
## Define list of variables in desired display order
tablevars <- c(grep('^race', names(dcarea), value=TRUE),
               grep('^peduc', names(dcarea), value=TRUE),
               'pfborn', 'pchildpres', 'pmarried')

## Create table of values for multiethnic and all DC Area tracts
quads <- t(sapply(dcarea[dcarea$quad15==TRUE, tablevars], meansd))
tracts <- t(sapply(dcarea[, tablevars], meansd))
tracttbl <- data.frame(quads, tracts)

## List of variable names to be published in the table
tblnames <- c('\\emph{Racial composition}&&&\\\\Percent Asian',
              'Percent Hispanic',
              'Percent non-Hispanic black',
              'Percent non-Hispanic white',
              '\\emph{Educational attainment}&&&\\\\Percent less than high school',
              'Percent high school',
              'Percent some college', 'Percent bachelor\'s degree',
              'Percent professional degree',
              '\\emph{Other demographic characteristics}&&&\\\\Percent foreign-born',
              'Percent of households with children present',
              'Percent married (not separated)'
)

## Create table with formatting
tbl <- data.frame(tblnames, quads, blank=rep(' ', nrow(quads)), tracts)
tbl[,c(2,3,5,6)] <- lapply(tbl[,c(2,3,5,6)], function(x) sprintf('%3.1f', x))
# tbl[,c(3,6)] <- lapply(tbl[,c(3,6)], function(x) paste0('(',x,')'))
colnames(tbl) <- c('Variable', 'Mean', 'S.D.','', 'Mean', 'S.D.')

## Write table to file
fname <- 'analysis/tables/nhood_descriptives.tex'
quad_tbl <- xtable(tbl,
                   caption='Means and standard deviations of tract-level variables in multiethnic and quadrivial neighborhoods in the DC Area',
                   align=c('l','p{2in}','R{4em}','R{4em}','p{1em}','R{4em}','R{4em}'),
                   label='tab:nhddescriptives')
print.xtable(quad_tbl,
             booktabs=TRUE,
             caption.placement='top',
             include.rownames=FALSE,
             file=fname,
             sanitize.text.function = identity,
             timestamp='')
colsets <- paste('&\\multicolumn{2}{p{8em}}{\\centering Multiethnic neighborhoods}&',
                 '&\\multicolumn{2}{p{8em}}{\\centering All neighborhoods}\\\\ ')
tbltxt <- readLines(fname)
tbltxt <- c(tbltxt[1:8], colsets, tbltxt[9:length(tbltxt)])
writeLines(tbltxt, fname)

## TABLES OF MULTIETHNIC NEIGHBORHOOD LOCATIONS
## Construct variables measuring multiethnic neighborhoods, both those included
## and those excluded due to no-majority constraint
racevars <- paste0('race.',c('papi','pnhb','phsp','pnhw'))
dcarea$othmulti <- apply(sapply(dcarea[, racevars],
                                function(x) !is.na(x) & x>=10), 1, all)
dcarea$exclmulti <- dcarea$quad15 != dcarea$othmulti
dcarea$county <- factor(substr(as.character(dcarea$GISJOIN), 2, 7))
levels(dcarea$county) <- c(
    'D.C.'
    , 'Montgomery county'
    , 'Prince George\'s county'
    , 'Arlington county'
    , 'Fairfax county'
    , 'Fairfax city'
    , 'Falls Church city'
    , 'Alexandria city'
)

## Breakdown of multiethnic neighborhoods by county
table(dcarea[, c('county', 'quad15')])
sort(table(dcarea[, c('county', 'quad15')])[,2], decreasing=TRUE)

## Breakdown of 'excluded' multiethnic neighborhoods by county
excl_juris <- table(dcarea[, c('county', 'exclmulti')])
N_excluded <- sum(excl_juris[,2])
## Listing of racial composition for all 'excluded' multiethnic nhoods
dcarea[!is.na(dcarea$exclmulti) & dcarea$exclmulti==TRUE,
       c('county', racevars)]
dcarea[!is.na(dcarea$exclmulti) & dcarea$exclmulti==TRUE & dcarea$race.pnhw>50,
       c('county', racevars)]
dcarea[!is.na(dcarea$exclmulti) & dcarea$exclmulti==TRUE & dcarea$race.pnhb>50,
       c('county', racevars)]
dcarea[!is.na(dcarea$exclmulti) & dcarea$exclmulti==TRUE & dcarea$race.phsp>50,
       c('county', racevars)]





## Violin plots of racial composition
# g <- ggplot(dcarea, aes(x=quad15, y=race.phsp)) + geom_violin()
#
# dcarea$x <- 1
# g <- ggplot(dcarea, aes(x=x, y=race.pnhw, fill=quad15)) + geom_split_violin()
#

print('end')
