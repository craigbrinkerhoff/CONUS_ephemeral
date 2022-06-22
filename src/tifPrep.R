library(terra)

n1 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TN_1km_winter.tif" )
n2 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TN_1km_spring.tif" )
n3 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TN_1km_summer.tif" )
n4 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TN_1km_autumn.tif" )

TN_MA <- mean(n1, n2, n3, n4)
plot(TN_MA)

p1 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TP_1km_winter.tif" )
p2 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TP_1km_spring.tif" )
p3 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TP_1km_summer.tif" )
p4 <- rast("C:\\Users\\cbrinkerhoff\\Downloads\\TP_1km_autumn.tif" )

TP_MA <- mean(p1, p2, p3, p4)
plot(n4)
