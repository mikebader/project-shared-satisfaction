### Need to make this for models in analysis
### Apply Rubin's Rules to the predictions to calculate adjusted SEs

newdata <- data.frame(dem.race=c('white','api','black','latino'),
                      sample_tract="51059452600",
                      educ='B.A.', nhdsize='1-9 blocks',
                      age=d['age','mean'], nhdyrs=d['nhdyrs','mean'],
                      forborn=d['forborn','mean'], man=d['man','mean'],
                      kids=d['kids','mean'], married=d['married','mean']
                      )
newdata <- data.frame(dem.race=c('white','api','black','latino'),
                      sample_tract="51059452600",
                      educ='B.A.', nhdsize='1-9 blocks',
                      age=d['age','mean'], nhdyrs=d['nhdyrs','mean'],
                      forborn=FALSE, man=FALSE,
                      kids=FALSE, married=FALSE
)
mfac_test <- with(dcassvy, svyglm(satisfied ~ dem.race + sample_tract + educ + nhdsize+
                                      age + nhdyrs + I(forborn*1) + I(man*1) +
                                      I(kids*1) + I(married*1), family=binomial()))
predict(mfac_test$imp1, newdata=newdata, type='response')
