report_models <- function(...,reglabels=c(), label='', caption='') {
    section_labels <- c('Race', 'Demographics', 'Socioeconomic', 'Neighborhood experience')
    models <- list(...)
    ht <- huxreg(..., statistics=c('nobs'), align='.', borders=0)
    ht[seq(4,(length(reglabels)+1)*2,2), 1] <- reglabels
    ht <- ht %>%
        insert_row(c('Race','','',''),
                     after=(which(ht$names=="(Intercept)")+1)) %>%
        insert_row(c('Demographics','','',''),
                   after=(which(ht$names=="Latinx")+2)) %>%
        insert_row(c('Socioeconomic','','',''),
                   after=(which(ht$names=="Married")+3)) %>%
        insert_row(c('Neighborhood experience','','',''),
                   after=which(ht$names=="$150,000+")+4) %>%
        set_bottom_border(c(1, length(ht$names)+1), everywhere, 1) %>%
        set_italic(which(ht$names %in% section_labels), everywhere, TRUE) %>%
        set_font_size(9.5) %>%
        set_caption(caption) %>%
        set_label(label)
    ht
}
