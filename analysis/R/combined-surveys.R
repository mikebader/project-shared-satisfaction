library(foreign)

wgts <- foreign::read.spss('../data/DCAS_Reweight_U1044_Confidential.sav') %>%
    as_tibble() %>%
    mutate(across(everything(), ~trimws(.x))) %>%
    mutate(
        wave = if_else(study=="O1087", "dcas16", "dcas18"),
        rid = if_else(wave=="dcas16", trimws(studycase), trimws(RID)),
        totwgt = as.numeric(TOTALWEIGHT),
        totwgt18 = as.numeric(TOTAL2018WEIGHT)
    )

idvarsC <- c('rid', 'strata')
dcasC <- bind_rows(
    select(dcas16, c(!!!vars, !!!nominals, !!!nivars, 'rid', 'strata')),
    select(dcas18, c(!!!vars, !!!nominals, !!!nivars, 'rid', 'strata')),
) %>%
    left_join(select(wgts, rid, totwgt)) %>%
    mutate(
        nhdsmp = if_else(grepl("^Global", strata), "quad",
                 if_else(grepl("^Latino", strata), "latino", "all")),
        nhdsmp = ordered(nhdsmp, levels=c("all", "quad", "latino"))
    ) %>%
    subset(
        raceeth != 'other'
    )
contrasts(dcasC$nhdsmp) <- contr.treatment(3)
idvarsC <- c(idvarsC, 'totwgt', 'nhdsmp')

dcasCmi <- amelia(dcasC[, unique(c(vars, nominals, nivars, idvarsC))],
                  m=5, noms=nominals, emburn=c(500,500), p2s=FALSE,
                  idvars=c(nivars, idvarsC))
dcasCsvy <- svydesign(id=~rid, weights=~totwgt,
                       data=imputationList(dcasCmi$imputations)) %>%
svy.center()


m1bn <- "nhdsmp * raceeth"
m2bn <- paste(m1bn, "+ agec + forbornc + manc + kidsc + marriedc"
              ,"+ educ1c + educ3c + educ4c + educ5c"
)
m3bn <- paste(m2bn, "+ ownc + nhdyrsc + nhdsize2c + nhdsize3c")

m1C <- with(dcasCsvy, svyglm(
    as.formula(paste('satisfied ~', m1bn)), family=binomial,
    contrasts = list(nhdsmp = "contr.treatment"))
)

m2C <- with(dcasCsvy, svyglm(
    as.formula(paste('satisfied ~', m2bn)), family=binomial,
    contrasts = list(nhdsmp = "contr.treatment"))
)

m3C <- with(dcasCsvy, svyglm(
    as.formula(paste('satisfied ~', m3bn)), family=binomial,
    contrasts = list(nhdsmp = "contr.treatment"))
)

regression_labelsC <- c(racelabs[1:3],
                        "Multiracial neighborhoods",
                        paste("~x ", racelabs[1:3]),
                        "Predom. Latinx neighborhoods",
                        paste("~x ", racelabs[1:3]),
                        regression_labels[-1:-3])
coef_names <- c("(Intercept)",
                paste0("raceeth", racelevs[2:4]),
                paste0("nhdsmpquad", c("", paste0(":raceeth", racelevs[2:4]))),
                paste0("nhdsmplatino", c("", paste0(":raceeth", racelevs[2:4]))),
                "agec", "forbornc", "manc", "kidsc", "marriedc",
                paste0("educ", c(1, 3:5), "c"), "ownc", "nhdyrsc",
                paste0("nhdsize", c(2, 3), "c"))
cmb_tbl <- report_models(
    MIcombine_aic(m1C), MIcombine_aic(m2C), MIcombine_aic(m3C)
    , reglabels=regression_labelsC, coefs=coef_names
)
cmb_tbl

cmb_tbl_cap <- paste(
    "Logistic regression coefficients and standard errors predicted",
    "from models estimating neighborhood satisfaction among residents",
    "combining DCAS 2016 and DCAS 2018 data"
)
cmb_tbl <- report_models(
    MIcombine_aic(m1C), MIcombine_aic(m2C), MIcombine_aic(m3C),
    caption = cmb_tbl_cap,
    label = "tab:combined",
    reglabels = regression_labelsC,
    use.headers = TRUE,
    coefs=coef_names
) %>%
    set_top_padding(0) %>%
    set_bottom_padding(0) %>%
    set_bottom_border(1, everything(), TRUE)
cmb_tbl_tex <- gsub("```(.+\\n)?", "", raw_latex(to_latex(cmb_tbl)), perl=TRUE)
cmb_tbl_tex <- gsub("(\\\\begin\\{tabular\\})", "\\\\small\n\\1", cmb_tbl_tex)
cmb_tbl_tex <- gsub("\\\\~\\{\\}x", "$~~~\\\\times$ ", cmb_tbl_tex)
cat(cmb_tbl_tex, file="tables/supp-combined.tex")
cmb_tbl

odds_quad <- exp(coef(MIcombine_aic(m3C))['nhdsmpquad'])
psat_nhw_quad <- plogis(sum(coef(MIcombine_aic(m3C))[c('(Intercept)', 'nhdsmpquad')]))
psat_nhw_all <- plogis(sum(coef(MIcombine_aic(m3C))[c('(Intercept)')]))

psat_nhb_quad <- plogis(sum(coef(MIcombine_aic(m3C))[
    c('(Intercept)', 'nhdsmpquad', 'raceethblack', 'nhdsmpquad:raceethblack')]))
psat_nhb_all <- plogis(sum(coef(MIcombine_aic(m3C))[
    c('(Intercept)', 'raceethblack')]))
psat_hsp_quad <- plogis(sum(coef(MIcombine_aic(m3C))[
    c('(Intercept)', 'nhdsmpquad', 'raceethlatino', 'nhdsmpquad:raceethlatino')]))
psat_hsp_all <- plogis(sum(coef(MIcombine_aic(m3C))[
    c('(Intercept)', 'raceethlatino')]))
