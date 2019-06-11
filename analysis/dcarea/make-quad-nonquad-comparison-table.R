## Creates table comparing demographic characteristics of multiethnic
## neighborhoods in DC Area to all neighborhoods in the DC Area.

library(tidyverse)
rm(list=ls())
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
    select('GISJOIN', ends_with('14'))

## Construct variables for analytic table, and keep only those variables
dcarea <- dcarea %>% mutate(
    ## Children present in HH
    pchildpres = pchpr14 * 100,

    ## Educational attainment
    peduc.lhs = plh14 * 100,
    peduc.hs = phs14 * 100,
    peduc.somecoll = (psc14 + paa14) * 100,
    peduc.ba = pba14 * 100,
    peduc.ma = pgr14 * 100,

    ## Foreign-born
    pfborn = fbpop14 / totpop14 * 100,

    ## Currently married
    pmarried = pmar14 * 100,

    ## Median age (no new variable necessary)

    ## Race-ethnicity
    race.papi = papi14 * 100,
    race.phsp = phsp14 * 100,
    race.pnhb = pnhb14 * 100,
    race.pnhw = pnhw14 * 100
) %>%
    select(GISJOIN, pchildpres, pfborn, pmarried, mdage14,
           starts_with('peduc'), starts_with('race'), quad14)

## CONSTRUCT TABLE
## Define list of variables in desired display order
tablevars <- c(grep('^race', names(dcarea), value=TRUE),
               grep('^peduc', names(dcarea), value=TRUE),
               'pfborn', 'pchildpres', 'pmarried')

## Create table of values for multiethnic and all DC Area tracts
quads <- t(sapply(dcarea[dcarea$quad14==TRUE, tablevars], meansd))
tracts <- t(sapply(dcarea[, tablevars], meansd))
tracttbl <- data.frame(quads, tracts)

## List of variable names to be published in the table
tblnames <- c('\\emph{Racial composition}&&\\\\Percent Asian',
              'Percent Hispanic',
              'Percent non-Hispanic black',
              'Percent non-Hispanic white',
              '&&\\\\\\emph{Educational attainment}&&\\\\Percent less than high school',
              'Percent high school',
              'Percent some college', 'Percent bachelor\'s degree',
              'Percent professional degree',
              '\\emph{Other demographic characteristics}&&\\\\Percent foreign-born',
              'Percent of households with children present',
              'Percent married (not separated)'
)

## Create table with formatting
tbl <- data.frame(tblnames, quads, tracts)
tbl[,c(2:5)] <- lapply(tbl[,c(2:5)], function(x) sprintf('%3.1f', x))
tbl[,c(3,5)] <- lapply(tbl[,c(3,5)], function(x) paste0('(',x,')'))
colnames(tbl) <- c('Variable', 'Mean', 'S.D.', 'Mean', 'S.D.')

## Write table to file
fname <- 'analysis/tables/nhood_descriptives.tex'
print.xtable(xtable(tbl,
                    caption='Means and standard deviations of tract-level variables in multiethnic and quadrivial neighborhoods in the DC Area',
                    align=c('l','p{2in}','R{4em}','R{4em}','R{4em}','R{4em}'),
                    label='tab:nhd_descriptives'),
             booktabs=TRUE,
             caption.placement='top',
             include.rownames=FALSE,
             file=fname,
             sanitize.text.function = identity,
             timestamp='')

colsets <- paste('&\\multicolumn{2}{p{8em}}{\\centering Multiethnic neighborhoods}',
                 '&\\multicolumn{2}{p{8em}}{\\centering All neighborhoods}\\\\ ')
tbltxt <- readLines(fname, -1)
tbltxt <- c(tbltxt[1:8], colsets, tbltxt[9:length(tbltxt)])
writeLines(tbltxt, fname)

## Violin plots of racial composition
# g <- ggplot(dcarea, aes(x=quad14, y=race.phsp)) + geom_violin()
#
# dcarea$x <- 1
# g <- ggplot(dcarea, aes(x=x, y=race.pnhw, fill=quad14)) + geom_split_violin()
#
