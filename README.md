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


The manuscript is written in Markdown and designed to be typeset into a PDF using [pandoc](https://pandoc.org/). To typeset with pandoc, you will first need to install the [`pandoc-xnos`](https://github.com/tomduck/pandoc-xnos#installation) filter suite (instructions at link). Then navigate to the `drafts` directory of the repository and use the following command:

    pandoc multiethnic-nhoods.md -o multiethnic-nhoods.pdf --filter pandoc-xnos --citeproc