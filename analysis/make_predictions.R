## make.prediction; fit=single fitted model
## Function to calculate probabilities using mean/mode of non-race
## variables and tract number '51059452600' (median value of satisfaction
## among tracts) for a fit model on the logistic scale
make.prediction <- function(fit, vars, at = "mean_or_mode") {
    modelvars <- names(attr(fit$terms, 'dataClasses'))
    p.vars <- intersect(modelvars, vars)
    newdata <- data.frame(sample_tract=levels(dcas16$sample_tract)[1],
                          raceeth=c('white','asian','black','latino'))
    if(at == "mean_or_mode") {
        if(length(p.vars)>0) newdata <- data.frame(
            newdata, mean_or_mode(fit$data[, p.vars]))
    }
    if(at == "intercept") {
        if(length(p.vars)>0) {
            zeros <- matrix(rep(0, length(p.vars)*nrow(newdata)),
                               ncol=length(p.vars))
            colnames(zeros) <- p.vars
            newdata <- cbind(newdata, as.data.frame(zeros))
        }

    }
    # print(head(newdata))
    Ps <- predict(fit, newdata=newdata, type='link', se.fit=TRUE) %>%
        as.data.frame()
    Ps$V <- Ps$SE^2
    Ps$raceeth <- c('white','asian','black','latino')
    return(Ps[, c('raceeth', 'link', 'V')])
}

## pr.values; modelset=set of fit models from multiple imputation
## Function that returns predicted probability and confidence intervals
## combining multiple imputation results using Rubin's rules
MIpredict <- function(
    modelset,
    vars = c('age', 'forborn', 'man', 'kids', 'married', 'educ',
             'nhdsize', 'nhdyrs'),
    at = "mean_or_mode"
) {
    pwide <- cbind(as.data.frame(lapply(modelset, make.prediction, vars, at)))
    yhat.cols <- grep('link$', names(pwide))
    V.cols <- grep('V$', names(pwide))

    pwide$mean <- apply(pwide[, yhat.cols], 1, mean)
    pwide$Vin <- apply(pwide[, V.cols], 1, mean)
    pwide$Vbn <- (1/length(modelset))*apply((pwide[, V.cols]-pwide$Vin)^2, 1, sum)
    pwide$Vmi <- pwide$Vin + (1 + (1/length(modelset)))*pwide$Vbn
    pwide$p <- plogis(pwide$mean)
    pwide$lci <- plogis(pwide$mean - 1.96*sqrt(pwide$Vmi))
    pwide$uci <- plogis(pwide$mean + 1.96*sqrt(pwide$Vmi))

    return(data.frame(raceeth=c('white','asian','black','latino'),
                      pwide[, c('p', 'lci', 'uci')]))
}
