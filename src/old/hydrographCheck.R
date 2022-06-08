library(dataRetrieval)
library(ggplot2)
library(targets)
library(dplyr)
library(grwat)
library(readr)

verifyDF <- tar_read(combined_verify)

summ <- verifyDF[verifyDF$perenniality == 'ephemeral' & verifyDF$baseflow_cf == 'perennial',]

listPlots <- list()
for(i in summ$GageIDMA){
  test <- readNWISstat(siteNumbers = i,
                       parameterCd = '00060', #discharge
                       startDate = '1970-10-01',
                       endDate = '2018-09-30')
  
  test$Q_cms <- test$mean_va * 0.0283
  test$day <- 1:nrow(test)
  
  # Visualize for 2020 year
  listPlots[[i]] <- ggplot(test) +
    geom_area(aes(day, Q_cms), fill = 'steelblue', color = 'black')
}

write_rds(listPlots, 'cache/false_positives.rds')


# 
# 
# hdata = test %>%
#   mutate(Qbase = gr_baseflow(Q_cms, method = 'maxwell'))
# 
# # Visualize for 2020 year
# ggplot(hdata) +
#   geom_area(aes(day, Q_cms), fill = 'steelblue', color = 'black') +
#   geom_area(aes(day, Qbase), fill = 'orangered', color = 'black')
