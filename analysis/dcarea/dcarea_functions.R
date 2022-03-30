## Functions to create data for DC Area
## (DC & surrounding jurisdictions, including independent cities)

select.dcarea <- function(dta) {
## Arguments: `dta`: dataset from from which to select observations in
##                   the DC Area
## Returns: dataset containing only observations from the DC area

    ## Identify counties to keep in DC Area dataset using FIPS county codes
    counties <- c(
          '110001'  # D.C.
        , '240031'  # Montgomery County
        , '240033'  # Prince George's County
        , '510013'  # Arlington County
        , '510059'  # Fairfax County
        , '510510'  # Alexandria city
        , '510600'  # Fairfax city
        , '510610'  # Falls Church city
    )

    ## Select counties using regular expression based on FIPS codes above
    ## and common `GISJOIN` variable
    re <- paste0('^G', counties, collapse = '|')
    dcarea <- dta[grep(re, dta$GISJOIN, perl=TRUE),]

    ## Replace factor variables to contain only levels in the DC area
    if('COUNTY' %in% names(dcarea)) {
        dcarea$COUNTY <- factor(dcarea$COUNTY)
    }
    if('STATE' %in% names(dcarea)) {
        dcarea$STATE <- factor(dcarea$STATE)
    }
    return(dcarea)
}
