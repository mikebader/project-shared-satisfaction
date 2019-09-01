library(prediction)

## get.margins; fit = single fitted model
## Returns AMEs, margins and fitted values whites on the link scale for
## a fitted model
get.margins <- function(fit) {
    res <- list()

    ## Set baseline data to everyone being white
    d0 <- fit$data
    d0$dem.race <- 'white'

    ## Predict outcome on link scale when all respondents are white
    pred0 <- prediction(fit, data=d0, type='link')

    ## Calculate marginal effects on link scale for other races
    m <- margins(fit, variables='dem.race', data=des$variables,
                 design=des, type='link')
    ame <- summary(m)
    ame$V <- ame$SE^2

    ## Return values
    res$ame <- ame      ## Summarized AMEs
    res$margins <- m    ## Calculated margins
    res$pred0 <- pred0  ## Average predicted values for whites
    return(res)
}

## get.predictions; res = get.margins() object
## Calculates probabilities based on summing individual marginal effects
## with predicted outcomes for whites
get.predictions <- function(res) {
    pred0 <- res$pred0
    mlink <- res$margins
    N <- length(pred0$fitted)
    fitted <- data.frame(white=rep(0,N),
                         mlink[grep('^dydx_', names(mlink))])
    mprobs <- sapply(fitted, function(x) {
        stats::weighted.mean(plogis(x+pred0$fitted), w=des$variables$weight)
    })
    names(mprobs) <- gsub('^dydx_dem\\.race','',names(mprobs))
    return(mprobs)
}

## calculate.pvals; amelist = list of get.margins() objects
## Returns AMEs on link scale with p-values based on combining multiply
## imputed variances, predicted probabilities, and AMEs on
## response scale
calculate.pvals <- function(amelist) {
    res <- list()
    AMEs <- lapply(amelist, function(x) x$ame)
    pwide <- as.data.frame(AMEs)

    AME.cols <- grep('AME$', names(pwide))
    V.cols <- grep('V$', names(pwide))

    # pwide$dem.race <- sub('dem\\.race','', pwide[,1])
    pwide$AMEmi <- apply(pwide[, AME.cols], 1, mean)
    pwide$Vin <- apply(pwide[, V.cols], 1, mean)
    pwide$Vbn <- (1/length(modelset))*apply((pwide[, V.cols]-pwide$Vin)^2, 1, sum)
    pwide$Vmi <- pwide$Vin + (1 + (1/length(modelset)))*pwide$Vbn
    pwide$pmi <- pnorm(abs(pwide$AMEmi/sqrt(pwide$Vmi)), lower.tail = FALSE)*2

    res$AME_link <- pwide[, c('AMEmi','Vin','Vbn','Vmi','pmi')]
    res$pred <- apply(sapply(amelist, get.predictions), 1, mean)
    res$AME_resp <- res$pred[1:4] - res$pred[1]
    return(res)
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
