## Analyzes foreign-born population to find top three nations of origin
## among foreign-born population in the DC area

## Source file with function to construct variables for DC area
source('analysis/dcarea/dcarea_functions.R')

## Load file of 2015 ACS data on tract-level foreign-born population
fname <- 'analysis/dcarea/AC52015_foreign_born.csv'
fborn <- read.csv(fname)

## Select only DC-area tracts
dc.fborn <- select.dcarea(fborn)

## Create list of variable names that define regions, not countries
region.vars <- c(
    'ADU4E001', 'ADU4E002', 'ADU4E003', 'ADU4E004', 'ADU4E005',
    'ADU4E013', 'ADU4E021', 'ADU4E028',
    'ADU4E047', 'ADU4E048', 'ADU4E049', 'ADU4E056', 'ADU4E067', 'ADU4E078',
    'ADU4E091', 'ADU4E092', 'ADU4E098', 'ADU4E101', 'ADU4E106', 'ADU4E109',
    'ADU4E117', 'ADU4E118',
    'ADU4E123', 'ADU4E124', 'ADU4E125', 'ADU4E138', 'ADU4E148', 'ADU4E160'
)

## Keep only non-region variables
nonregion.vars <- names(dc.fborn)[!(names(dc.fborn) %in% region.vars)]
dc.fborn <- dc.fborn[, nonregion.vars]

## Sum total population across DC-area tracts by each country of origin
country.sums <- sapply(dc.fborn[, grep('^ADU4', names(dc.fborn), value=TRUE)],
                       function(x) sum(as.numeric(x)))

# Rank countries of origin by population size
country.rank <- sort(country.sums, decreasing=TRUE)

# Report countries of origin by variable name
print('Top three DC-area countries of origin (reported by variable name):')
print(head(country.rank, 3))

