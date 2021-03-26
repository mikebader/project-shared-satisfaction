report_models <- function(
    ...,
    reglabels=c(),
    label=NULL,
    caption=NULL,
    use.headers=FALSE
    ) {
    fe_rows <- function(tab) {
        beta_rows <- grep('^sample_tract',tab$names,perl=TRUE)
        se_rows <- beta_rows+1
        return(c(beta_rows, se_rows))
    }
    ht <- huxreg(..., statistics=c("N", "AIC"), align='.', borders=0)
    if(length(fe_rows(ht)) > 1) ht <- ht[-1*fe_rows(ht),]
    if(length(reglabels) > 0) ht[seq(4,(length(reglabels)+1)*2,2), 1] <- reglabels
    last.row <- nrow(ht)
    ncols <- ncol(ht)
    ht <- ht %>%
        set_number_format(which(ht$names=="N"), -1, "%4.0f") %>%
        set_top_border(which(ht$names=="N"), everything(), TRUE) %>%
        set_font_size(9.5)
    if(!is.null(caption)) ht <- set_caption(ht, caption)
    if(!is.null(label)) ht <- set_label(ht, label)
    if(use.headers==TRUE) {
        section_labels <- c('Race', 'Demographics', 'Socioeconomic',
                            'Neighborhood perceptions')
        ht <- ht %>%
            insert_row(c('Race',rep('', ncols-1)),
                       after=(which(ht$names=="Asian")-1)) %>%
            insert_row(c('Demographics',rep('', ncols-1)),
                       after=(which(ht$names=="Age"))) %>%
            insert_row(c('Socioeconomic',rep('', ncols-1)),
                       after=(which(ht$names=="Married")+3)) %>%
            insert_row(c('Neighborhood perceptions',rep('', ncols-1)),
                       after=which(ht$names=="B.A.")+6)
        ht <- set_italic(ht, which(ht$names %in% section_labels), everywhere, TRUE)
    }
    ht
}
