desc <- function(dat, x) {
    capture.output(
        res <- summary(MIcombine(
            with(dat, svymean(as.formula(paste0('~',x))))))
    )
    return(res[,1:2])
}

make.desc <- function(dat) {
    ## Independent variable (race)
    d <- desc(dat, 'raceeth')

    ## Demographic variables
    d <- rbind(d, desc(dat, 'age'))
    d['age','results'] <- d['age','results'] + 50
    d <- rbind(d, desc(dat, 'forborn')[2,])
    d <- rbind(d, desc(dat, 'man')[2,])
    d <- rbind(d, desc(dat, 'kids')[2,])
    d <- rbind(d, desc(dat, 'married')[2,])

    ## SES variables
    d <- rbind(d, desc(dat, 'educ')[c(2,1,3:5),])

    ## Neighborhood experience variables
    d <- rbind(d, desc(dat, 'nhdyrs'))
    d['nhdyrs','results'] <- d['nhdyrs','results']
    d <- rbind(d, desc(dat, 'nhdsize'))

    N <- paste0("Sample respondents (N): Total=", nrow(dat), ",")
    Ntbl <- table(dat$designs[[1]]$variables$raceeth)
    Ns <- paste0(
        sub("^(\\w)", "\\U\\1", names(Ntbl), perl = TRUE), "=", Ntbl,
        collapse = ", "
    )
    Nrow <- matrix(c(NA, NA), nrow = 1)
    rownames(Nrow) <- paste(N, Ns)
    colnames(Nrow) <- c("results", "se")
    d <- rbind(d, Nrow)

    return(d)
}


descriptive.table <- function(table, fname, caption, lab) {
    category_label <- function(df, lbl, before) {
        rn <- grep(before, df$Variable) - 1
        df %>% insert_row(c("", lbl), after = rn, fill = "")
    }
    ftnt <- rownames(table)[nrow(table)]
    tbl <- as_huxtable(table) %>%
        set_caption(caption) %>%
        set_label(lab) %>%
        set_table_environment("sidewaystable") %>%
        category_label("\\emph{Race}", "^White") %>%
        category_label("\\emph{Demographics}", "^Age") %>%
        category_label("\\emph{Education}", "^Less than H\\.S\\.") %>%
        category_label("\\emph{Neighborhood experience}",
                       "^Years in neighborhood") %>%
        insert_row(
            c("", "", "Total sample", "", "Asians", "", "Blacks", "",
              "Latinxs", "", "Whites", "")
        ) %>%
        merge_cells(1, 3:4) %>% merge_cells(1, 5:6) %>% merge_cells(1, 7:8) %>%
        merge_cells(1, 9:10) %>% merge_cells(1, 11:12) %>%
        set_align(1, everywhere, "center") %>%
        set_col_width(3:10, "0.4in") %>%
        set_bold(1:2, everywhere) %>%
        set_bottom_border(c(2, nrow(.)-1), everywhere, TRUE) %>%
        merge_across(nrow(.)) %>%
        set_escape_contents(everywhere, everywhere, FALSE) %>%
        set_tb_padding(everywhere, everywhere, 0) %>%
        set_top_padding(grep("emph\\{", .$Variable), everywhere, 8)
    tbl[2, ] <- c("", "Variable", rep(c("Mean", "S.D."), 5))
    cat(
        sub("\\(\\\\#(tab:.+?)\\)", "\\\\label{\\1\\}", to_latex(tbl[, -1])),
        file = fname
    )
    tbl
}

