predicted.margins.race <- function(fit){
    races <- c("white", "asian", "black", "latino")
    beta_hat <- coef(fit)
    X <- model.matrix(fit)
    N <- nrow(X)

    Xs <- lapply(races, function(r){
        x <- X
        racecols <- grep("^raceeth", colnames(x))
        x[, racecols] <- 0
        colnum <- grep(r, colnames(x))
        if(length(colnum)==1) x[, colnum] <- 1
        return(x)
    })

    yhats <- lapply(Xs, function(Xi){
        yhat <- Xi %*% beta_hat
    })

    pr <- sapply(yhats, function(yhat) mean(plogis(yhat)))
    J <- sapply(1:4, function(i){
        (t(dlogis(yhats[[i]])) %*% Xs[[i]])/N
    })
    J <- t(J)
    vcov <- J %*% vcov(fit) %*% t(J)
    # SE <- sqrt(diag(vcov))

    pmarg <- tibble(
        raceeth=races,
        Pr=pr,
        SE=sqrt(diag(vcov)),
        lci=Pr - qnorm(.975)*SE,
        uci=Pr + qnorm(.975)*SE
    )
    attr(pmarg, "jacobian") <- J
    attr(pmarg, "vcov") <- vcov
    attr(pmarg, "fit") <- fit
    return(pmarg)
}

marginal.effects.race<- function(pmarg){
    mfx <- pmarg$Pr[-1] - pmarg$Pr[1]
    J <- attr(pmarg, "jacobian")
    J <- J[2:4,] - matrix(rep(J[1,,drop=FALSE],3), nrow=3, byrow=TRUE)
    vcov <- J %*% vcov(attr(pmarg, "fit")) %*% t(J)
    mfx <- tibble(raceeth=pmarg$raceeth[-1], marginal.eff = mfx) %>%
        mutate(
        SE = sqrt(diag(vcov)),
        z = marginal.eff/SE,
        p = pnorm(z, lower.tail=FALSE)*2,
        lci = marginal.eff - qnorm(.975)*SE,
        uci = marginal.eff + qnorm(.975)*SE
    )
    attr(mfx, "vcov") <- vcov
    attr(mfx, "jacobian") <- J
    return(mfx)
}

MImargins <- function(modelset, param=c("predicted", "margins")){
    M <- length(modelset)
    pmargs <- lapply(modelset, predicted.margins.race)

    if(match.arg(param)=="predicted") {
        prs <- sapply(pmargs, function(m) m$Pr ) ## KxM matrix of pred. probs
        V <- sapply(pmargs, function(m) diag(attr(m, "vcov"))) ## KxM matrix of variances
        nms <- unlist(pmargs[[1]][,1])
    }
    else{
        mgns <- lapply(pmargs, marginal.effects.race)
        prs  <- sapply(mgns, function(m) m$marginal.eff)
        V <- sapply(mgns, function(m) diag(attr(m, "vcov"))) ## KxM matrix of variances
        nms <- unlist(pmargs[[1]][-1,1])
    }
    yhats <- rowMeans(prs)                     ## Kx1 vector of mean pred. probs
    Vin <- rowMeans(V)                       ## Kx1 vector of mean variances
    Vbn <- (1/(M-1))*rowSums((prs - yhats)^2)  ## Kx1 vector of between variances
    Vmi <- Vin + (1 + 1/M)*Vbn               ## Kx1 vector of total variances
    SEs <- sapply(Vmi, sqrt)

    return(tibble(raceeth=nms, val=yhats, SE=SEs))
}

