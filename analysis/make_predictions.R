library(prediction)

## Apply Rubin's rules to combine estimates and standard errors of
## average marginal effects (AMEs) across imputations

## **IT IS COMPUTATIONALLY INEFFICIENT TO RUN `margins()` TWICE, CAN'T
## FIGURE OUT A BETTER WAY**
MIame <- function(modelset) {
    fitnames <- names(modelset)
    amelist <- lapply(fitnames, function(fit) summary(margins(modelset[[fit]], variables='dem.race', design=dcassvy$designs[[fit]])))
    prs <- sapply(amelist, function(x) x$AME)
    means <- apply(prs, 1, mean)
    return(means)
}

MIame_pval <- function(modelset) {
    amelist <- lapply(seq_along(modelset), function(fit) {
        ame <- summary(
            margins(modelset[[fit]], variables='dem.race',
                    design=dcassvy$designs[[fit]], type='link')
            )
        ame$V <- ame$SE^2
        return(ame)
        })
    pwide <- as.data.frame(amelist)
    AME.cols <- grep('^AME', names(pwide))
    V.cols <- grep('^V', names(pwide))

    pwide$mean <- apply(pwide[, AME.cols], 1, mean)
    pwide$Vin <- apply(pwide[, V.cols], 1, mean)
    pwide$Vbn <- (1/length(modelset))*apply((pwide[, V.cols]-pwide$Vin)^2, 1, sum)
    pwide$Vmi <- pwide$Vin + (1 + (1/length(modelset)))*pwide$Vbn
    pwide$pval <- pnorm(abs(pwide$mean/sqrt(pwide$Vmi)), lower.tail = FALSE)
    return(pwide$pval)
}



## make.prediction; fit=single fitted model
## Function to calculate probabilities using mean/mode of non-race
## variables and tract number '51059452600' (median value of satisfaction
## among tracts) for a fit model on the logistic scale
make.prediction <- function(fit) {
    modelvars <- names(attr(fit$terms, 'dataClasses'))
    vars <- c('age', 'forborn', 'man', 'kids', 'married', 'educ',
              'nhdsize', 'nhdyrs')
    p.vars <- intersect(modelvars, vars)
    newdata <- data.frame(sample_tract='51059452600',
                          dem.race=c('white','api','black','latino'))
    if(length(p.vars)>0) newdata <- data.frame(
        newdata, mean_or_mode(fit$data[, p.vars]))
    Ps <- predict(fit, newdata=newdata, type='link', se.fit=TRUE) %>%
        as.data.frame()
    Ps$V <- Ps$SE^2
    Ps$dem.race <- c('white','api','black','latino')
    return(Ps[, c('dem.race', 'link', 'V')])
}

## pr.values; modelset=set of fit models from multiple imputation
## Function that returns predicted probability and confidence intervals
## combining multiple imputation results using Rubin's rules
MIpredict <- function(modelset) {
    pwide <- cbind(as.data.frame(lapply(modelset, make.prediction)))
    yhat.cols <- grep('link$', names(pwide))
    V.cols <- grep('V$', names(pwide))

    pwide$mean <- apply(pwide[, yhat.cols], 1, mean)
    pwide$Vin <- apply(pwide[, V.cols], 1, mean)
    pwide$Vbn <- (1/length(modelset))*apply((pwide[, V.cols]-pwide$Vin)^2, 1, sum)
    pwide$Vmi <- pwide$Vin + (1 + (1/length(modelset)))*pwide$Vbn
    pwide$p <- plogis(pwide$mean)
    pwide$lci <- plogis(pwide$mean - 1.96*sqrt(pwide$Vmi))
    pwide$uci <- plogis(pwide$mean + 1.96*sqrt(pwide$Vmi))

    return(data.frame(dem.race=c('white','api','black','latino'),
                      pwide[, c('p', 'lci', 'uci')]))
}

## plot.predictions; m1=data frame of predicted probs from race-only model
##                   m3=data frame of predicted probs from race + control model
## Plots predicted probabilities at means/modes of variables of race-only
## and race+controls model side-by-side
plot.predictions <- function(m1, m3) {
    dta <- rbind(m1, m3)
    dta$model <- factor(rep(c(1,2), each=4),
                        labels=c('Race only', 'With controls'))
    g <- ggplot(dta, aes(x=dem.race, y=p, ymin=lci, ymax=uci)) +
        geom_point(size=2.25) +
        geom_linerange(size=1) +
        scale_color_grey() +
        coord_fixed(ratio=1.5) +
        scale_y_continuous(limits=c(0,1)) +
        scale_x_discrete(labels=c('Asian','Black','Latinx','White')) +
        labs(y='Probability', x='Race') +
        facet_grid(.~model)
    return(g)
}
