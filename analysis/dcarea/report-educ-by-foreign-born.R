## Analyzes the U.S.-born and foreign-born population that has
## BA and graduate degrees in the U.S. and the DC area

## Source file with function to construct variables for DC area
source('analysis/dcarea/dcarea_functions.R')

## Load file of 2015 ACS data on tract-level foreign-born population
fname <- 'analysis/dcarea/AC52015_educ_by_foreign_born.csv'

fbeduc <- read.csv(fname)
us.fbba <- sum(fbeduc$fbba, na.rm=TRUE) / sum(fbeduc$fbtot25o, na.rm=TRUE)
us.fbgr <- sum(fbeduc$fbgr, na.rm=TRUE) / sum(fbeduc$fbtot25o, na.rm=TRUE)

dc.fbeduc <- select.dcarea(fbeduc)
dc.fbba <- sum(dc.fbeduc$fbba, na.rm=TRUE) / sum(dc.fbeduc$fbtot25o, na.rm=TRUE)
dc.fbgr <- sum(dc.fbeduc$fbgr, na.rm=TRUE) / sum(dc.fbeduc$fbtot25o, na.rm=TRUE)

fbeduc.comp <- data.frame(degree=c('BA', 'MA+'),
                          DC=round(c(dc.fbba, dc.fbgr),3)*100,
                          US=round(c(us.fbba, us.fbgr),3)*100)


