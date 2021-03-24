MIcombine_aic <- function(m) { ## Combines imputations, including AIC
    mi <- MIcombine(m)
    if(m[[1]]$aic) {
        aics <- sapply(m, function(x) x$aic)
        mi$aic <- list(mean=mean(aics), var=var(aics))
    }
    return(mi)
}

tidy.MIresult <- function(x, conf_int = FALSE, conf_level = 0.95) {
    output <- as.data.frame(cbind(x$coefficients,
                                  sqrt(diag(x$variance)),
                                  x$df
                                  )) %>%
        magrittr::set_colnames(c('estimate', 'std.error', 'df')) %>%
        mutate(term = names(x$coefficients)) %>%
        select(term, everything()) %>%
        mutate(tvalue=estimate/std.error,
               p.value= 2 * pt(abs(tvalue), df, lower.tail = FALSE))

    if(conf_int & conf_level) {
        a <- (1 - conf_level) / 2
        output <- output %>%
                  mutate(conf.low = estimate + std.error*qt(a, df),
                         conf.high = estimate + std.error*qt((1-a),df))
    }
    class(output) <- "data.frame"
    as_tibble(output)
}

nobs.MIresult <- function(x) {
    svydta <- get(as.character(x$call[[1]])[2])
    return(nrow(svydta$designs[[1]]))
}

glance.MIresult <- function(x) {
    output <- data_frame(AIC = x$aic$mean, aic_v = x$aic$var)
    output$N <- ifelse(any(grepl('nobs', names(x))), x$nobs, nobs(x))
    class(output) <- "data.frame"
    output
}
