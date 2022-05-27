library(targets)
library(dplyr)

nhd01 <- tar_read(scaledResult_01)
nhd02 <- tar_read(scaledResult_02)
nhd11 <- tar_read(scaledResult_11)
#nhd12 <- tar_read(scaledResult_12)
nhd13 <- tar_read(scaledResult_13)
nhd14 <- tar_read(scaledResult_14)
nhd15 <- tar_read(scaledResult_15)
nhd16 <- tar_read(scaledResult_16)

df <- rbind(nhd01, nhd02, nhd11, nhd13, nhd14, nhd15, nhd16)
print(df)

print(mean(df$percEphQ_scaled))
