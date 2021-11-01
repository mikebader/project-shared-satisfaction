# Replication Repository for Shared Satisfaction among Residents Living in Multiracial Neighborhoods

## Description

The repository contains data and files necessary to replicate the analyses in "Shared Satisfaction among Residents Living in Multiracial Neighborhoods" (Bader, forthcoming). 

## Documentation

You may view the steps used to construct and analyze the data (without replicating yourself) at https://mikebader.github.io/project-shared-satisfaction.

## Replication Instructions

If you would like to replicate the analysis yourself, you must have [Git Large File Storage](https://git-lfs.github.com/) installed on your machine and enabled in git:

    git lfs install

Once you have done that, you can clone the repository:

    git clone --recurse-submodules https://github.com/mikebader/project-shared-satisfaction.git

After cloning the repository, you need to download the [Longitudinal Tract Database](https://s4.ad.brown.edu/projects/diversity/Researcher/Bridging.htm) by John Logan and colleagues. You can download the data [here](https://s4.ad.brown.edu/projects/diversity/researcher/LTBDDload/Default.aspx). Request the **full count** data for the year **2000**. 

You will be prompted to download a `.zip` file. Extract the files from that `.zip` file and copy or move the file `ltdb_std_2000_fullcount.csv` into the `data` subdirectory. 

After doing so, you should be able to replicate the analysis by opening the file `analysis/analysis.Rproj` in [RStudio](https://www.rstudio.com/) and building the project. 

Note that lines 503-506 of the file `analysis/data-construction.Rmd` are commented out by default. This permits the replication using the exact version of `dcassvy.Rdata` used in the paper. If you un-comment those line, `dcassvy.Rdata` will be overwritten using randomized multiple imputation datasets that do not match the analysis, and doing so will result in slight variations from the reported results. 

## Manuscript Typesetting

The manuscript is written in Markdown and designed to be typeset with [my custom LaTeX class](https://github.com/mikebader/latex-baderart). To typeset in regular LaTeX, include the following at the end of the YAML block. 

    header-includes: |
        \usepackage{rotating}
        \usepackage{adjustbox}
        \usepackage{ragged2e}
        \usepackage{caption}
        \usepackage{hhline}
        \usepackage{colortbl}
        \usepackage{threeparttable}
        \usepackage{tabularx}
        `\newcolumntype{C}[1]{>{\centering\arraybackslash}p{#1}}
        \newcolumntype{R}[1]{>{\raggedleft\hspace{0pt}\arraybackslash}b{#1}}
        \newcolumntype{L}[1]{>{\RaggedRight\hspace{0pt}\arraybackslash}p{#1}}`{=latex}
        \newcommand{\abouthere}[2]{%
          \begin{center}[Insert #1 \ref{#2} about here]\end{center}%
        }