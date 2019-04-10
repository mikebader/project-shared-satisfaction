report_models <- function(...,reglabels=c(), label='', caption='') {
    fe_rows <- function(tab) {
        beta_rows <- grep('^sample_tract',tab$names,perl=TRUE)
        se_rows <- beta_rows+1
        return(c(beta_rows, se_rows))
    }
    section_labels <- c('Race', 'Demographics', 'Socioeconomic', 'Neighborhood perceptions')
    models <- list(...)
    assign('models',models,envir=.GlobalEnv)
    ht <- huxreg(..., statistics='', align='.', borders=0)
    ht <- ht[-1*fe_rows(ht),]
    ht[seq(4,(length(reglabels)+1)*2,2), 1] <- reglabels
    ht <- ht %>%
        insert_row(c('Race','','','',''),
                     after=(which(ht$names=="Asian")-1)) %>%
        insert_row(c('Demographics','','','',''),
                   after=(which(ht$names=="Latinx")+2)) %>%
        insert_row(c('Socioeconomic','','','',''),
                   after=(which(ht$names=="Married")+3)) %>%
        insert_row(c('Neighborhood perceptions','','','',''),
                   after=which(ht$names=="B.A.")+4) %>%
        insert_row(c('AIC', sapply(models, function(x) round(x$aic$mean, 3))),
                   after=which(ht$names==">50 blocks")+5) %>%
        set_bottom_border(row=c(1,length(ht$names)+4, length(ht$names)+3), col=everywhere, value=1) %>%
        set_italic(which(ht$names %in% section_labels), everywhere, TRUE) %>%
        set_font_size(9.5) %>%
        set_caption(caption) %>%
        set_label(label)
    ht
}
