# Replication Repository for Shared Satisfaction among Residents Living in Multiracial Neighborhoods

## Description

The repository contains data and files necessary to replicate the analyses in "Shared Satisfaction among Residents Living in Multiracial Neighborhoods" (Bader, forthcoming). 

## Documentation

You may view the steps used to construct and analyze the data (without replicating yourself) at https://mikebader.github.io/project-shared-satisfaction.

## Replication Instructions

Data may be replicated by extracting all .zip files into a common directory. 

After doing so, you need to download the [Longitudinal Tract Database](https://s4.ad.brown.edu/projects/diversity/Researcher/Bridging.htm) by John Logan and colleagues. You can download the data [here](https://s4.ad.brown.edu/projects/diversity/researcher/LTBDDload/Default.aspx). Request the **full count** data for the year **2000**. 

You will be prompted to download a `.zip` file. Extract the files from that `.zip` file and copy or move the file `ltdb_std_2000_fullcount.csv` into the `data` subdirectory. 

You should be able to replicate the analysis by opening the file `analysis/analysis.Rproj` in [RStudio](https://www.rstudio.com/) and building the project. You can do this one of two ways:

Using the graphical user interface (GUI).

: If you open the `analysis/analysis.Rproj` file in Rstudio, a tab labeled "Build" should appear in the Environment/History window in RStudio. Click on that tab and then click the "Build Book" button. 

Using the command-line in the console.

: Type the following command into the console:

        renv::restore()

    Then restart R by either pressing Cmd/Ctrl-Shift-0 or navigating to  Session->Restart and enter the following command into the console:

        rmarkdown::render_site(encoding = "UTF-8")

Both methods will replicate the analyses. Note, however, that lines 503-506 of the file `analysis/data-construction.Rmd` are commented out by default. This permits the replication using the exact version of `dcassvy.Rdata` used in the paper. If you un-comment those line, `dcassvy.Rdata` will be overwritten using randomized multiple imputation datasets that do not match the analysis, and doing so will result in slight variations from the reported results. 

The results will be saved in a series of HTML files the `docs` directory. 

The documentation may also be viewed at [https://mikebader.github.io/project-shared-satisfaction/](https://mikebader.github.io/project-shared-satisfaction/). The code contained in each `.Rmd` file in the `analysis` directory corresponds to sections of the documentation:

------------------------------------------------------------------------------------
`.Rmd` file                   Documentation section
----------------------------  ------------------------------------------------------
`descriptives-dcarea.Rmd`     [2. Description of DC-Area & Multiracial
                              Neighborhood Populations][dcarea]

`data-construction.Rmd`       [3. Data Construction][construction]

`descriptives-survey.Rmd`     [4. Sample Descriptive Statistics][dcas]

`analysis-internal.Rmd`       [5. Satisfaction Within Multiracial Neighborhoods][wn]

`analysis-comparative.Rmd`    [6. Satisfaction Comparison Between Multiethnic 
                              Neighborhoods and DC-Area Population][bn]

`analysis-change.Rmd`         [7. Perceptions of Neighborhood Change][change]

`supplement.Rmd`              [8. Supplement][supplement]
------------------------------------------------------------------------------------

[dcarea]: https://mikebader.github.io/project-shared-satisfaction/description-of-dc-area-multiracial-neighborhood-populations.html
[construction]: https://mikebader.github.io/project-shared-satisfaction/data-construction.html
[dcas]: https://mikebader.github.io/project-shared-satisfaction/sample-descriptive-statistics.html#sample-descriptive-statistics
[wn]: https://mikebader.github.io/project-shared-satisfaction/satisfaction-within-multiracial-neighborhoods.html
[bn]: https://mikebader.github.io/project-shared-satisfaction/satisfaction-comparison-between-multiethnic-neighborhoods-and-dc-area-population.html
[change]: https://mikebader.github.io/project-shared-satisfaction/perceptions-of-neighborhood-change.html
[supplement]: https://mikebader.github.io/project-shared-satisfaction/supplement.html

Note that lines 503-506 of the file `analysis/data-construction.Rmd` are commented out by default. This permits the replication using the exact version of `dcassvy.Rdata` used in the paper. If you un-comment those line, `dcassvy.Rdata` will be overwritten using randomized multiple imputation datasets that do not match the analysis, and doing so will result in slight variations from the reported results. 

## Manuscript Typesetting

The manuscript is written in Markdown and designed to be typeset into a PDF using [pandoc](https://pandoc.org/). To typeset with pandoc, you will first need to install the [`pandoc-xnos`](https://github.com/tomduck/pandoc-xnos#installation) filter suite (instructions at link). Then navigate to the `drafts` directory of the repository and use the following command:

    pandoc multiethnic-nhoods.md -o multiethnic-nhoods.pdf --filter pandoc-xnos --citeproc
