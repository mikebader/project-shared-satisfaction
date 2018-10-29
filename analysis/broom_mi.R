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

glance.MIresult <- function(x) {
    output <- data_frame(r.squared=NA, adj.r.squared=NA, sigma=NA)
    class(output) <- "data.frame"
    output
}

nobs.MIresult <- function() {
    NULL
}

# tidy(m1, conf_int=TRUE)
# glance(m1)
# huxreg(m1, statistics=c(''))
