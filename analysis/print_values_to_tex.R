## SAVE VALUES STORED FOR EXPORT TO LATEX IN .TEX FILE
fname <- 'values_to_tex.tex'
cat('%% Values recorded from analysis source files\n', file=fname)
source('print_values_to_tex.R')

write.texcmds <- function(x, file=stdout()) {
    cat(paste0('\\newcommand{\\', names(texcmds[x]), '}{', texcmds[x], '}'),
        file=file, sep="\n", append=TRUE)
}
sapply(seq_along(texcmds), write.texcmds, file=fname)
