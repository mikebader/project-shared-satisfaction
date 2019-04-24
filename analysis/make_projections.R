### Need to make this for models in analysis
### Apply Rubin's Rules to the predictions to calculate adjusted SEs

# newdata <- data.frame(dem.race=c('white','api','black','latino'),
#                       sample_tract="51059452600",
#                       educ='B.A.', nhdsize='1-9 blocks',
#                       age=d['age','mean'], nhdyrs=d['nhdyrs','mean'],
#                       forborn=d['forborn','mean'], man=d['man','mean'],
#                       kids=d['kids','mean'], married=d['married','mean'],
#                       satisfied=as.numeric(coef(mean_satisfied)))
# newdata <- data.frame(dem.race=c('white','api','black','latino'),
#                       sample_tract="51059452600",
#                       educ='B.A.', nhdsize='1-9 blocks',
#                       age=d['age','mean'], nhdyrs=d['nhdyrs','mean'],
#                       forborn=FALSE, man=FALSE,
#                       kids=FALSE, married=FALSE,
#                       satisfied=0
# )

MIpredict <- function(mlist) {
    # newdata <- data.frame(dem.race=c('white','api','black','latino'),
    #                       sample_tract="51059452600",
    #                       educ='B.A.', nhdsize='1-9 blocks',
    #                       age=d['age','mean'], nhdyrs=d['nhdyrs','mean'],
    #                       forborn=d['forborn','mean'], man=d['man','mean'],
    #                       kids=d['kids','mean'], married=d['married','mean'],
    #                       satisfied=0)
    newdata <- data.frame(dem.race=c('white','api','black','latino'),
                          sample_tract="51059452600",
                          educ='B.A.', nhdsize='1-9 blocks',
                          age=50, nhdyrs=7,
                          forborn=FALSE, man=FALSE,
                          kids=FALSE, married=FALSE,
                          satisfied=0,
                          nhd.srch.herndon.live=FALSE,
                          nhd.srch.wheaton.live=FALSE,
                          nhd.srch.germantown.live=FALSE
    )
    for (i in mlist) {
        for(b in c('forborn', 'man', 'kids', 'married')) {
            idx <- grep(b, names(i$coefficients))
            if(length(idx)>0) names(i$coefficients['idx']) <- b
        }
    }
    preds <- lapply(mlist, predict, newdata=newdata, type='link', se=TRUE,
                    interval='confidence', vcov=TRUE) %>%
        as.data.frame()
    betas <- apply(preds[seq(1,9,2)], 1, mean)
    v.in <- apply(preds[seq(2,10,2)]^2,1,mean)
    v.bn <- apply((preds[seq(1,9,2)]-betas)^2, 1, sum)/4
    Vs <- v.in + v.bn*(1+1/5)
    mi <- data.frame(beta=betas, se=sqrt(Vs))
    mi$P <- plogis(mi$beta)
    mi$lci <- plogis(mi$beta - (1.96*mi$se))
    mi$uci <- plogis(mi$beta + (1.96*mi$se))
    return(mi)
}
