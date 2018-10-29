library(reshape2)
library(survey)

rm(list=ls())

searches <- read.csv('Dataset/DCAS_2016_searchDimensions.csv')

commnames <- c('brightwood','columbia.heights','germantown','greenbelt',
               'hyattsville','langley.park','wheaton','annandale','arlington',
               'herndon','huntington')
searches$dem.race <- relevel(searches$dem.race, ref="white")
dcas.svy <- svydesign(id=~1,strata=~sample_strata,weights=~weight,data=searches)

race_only <- function(i, stub) {
    mdl <- paste0("nhd.srch.",i,".",stub," ~ + dem.race + nhd.srch.",i,".live")
    # mdl <- paste0(stub,".",i," ~  dem.race + search_live.", i)
    svyglm(mdl, dcas.svy, family="binomial")
}
glm_race_only <- lapply(commnames, race_only, stub="nc")
for(i in 1:11) {
    print(summary(glm_race_only[[i]]))
}

betas_race_only <- sapply(glm_race_only, coef)

## Calculate probabilities from
colnames(betas_race_only) <- c(commnames)
rownames(betas_race_only) <- c('intercept', 'api', 'black', 'latino', 'live')
betas_race_only
logits_race_only <- apply(betas_race_only[2:4,], 1,
                             function(x){x + betas_race_only[1,]})
logits_race_only <- cbind(betas_race_only[1,], logits_race_only)
colnames(logits_race_only) <- c('white','api','black','latino')
probs <- exp(logits_race_only)/(1 + exp(logits_race_only))
probs_long <- melt(probs,value.name='probability')
names(probs_long) <- c('commname','race','probability')

ggplot(probs_long[probs_long$race%in%c('white','black'),], aes(x=race, y=probability, fill=race)) +
    geom_bar(position='dodge', stat='identity') + facet_wrap(~commname, nrow=1) +
    ylim(c(0,1))
ggsave('~/Desktop/dk_probs_test.png', width=9, height=4)
# race_educ <- function(i, stub) {
#     mdl <- paste0("nhd.srch.",i,".",stub)
#     # mdl <- paste0(stub,".",i," ~ dem.race + dem.educ.attain + search_live.", i)
#     svyglm(mdl, dcas.svy, family="binomial")
# }
# glm_race_educ <- lapply(1:11, race_educ, stub="search_dk")
# betas_race_educ <- sapply(glm_race_educ, coef)
# colnames(betas_race_educ) <- c(places)
#
#
