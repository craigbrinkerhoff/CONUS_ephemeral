################
## Code to re-orient precip data from 0 - 360 longitudes to -180 - 180. This was done locally on my PC and the code is included here for posterity's sake.
## Craig Brinkerhoff
## Summer 2022
###############

library(raster)

precip1 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1980.nc" )
precip2 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1981.nc" )
precip3 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1982.nc" )
precip4 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1983.nc" )
precip5 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1984.nc" )
precip6 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1985.nc" )
precip7 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1986.nc" )
precip8 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1987.nc" )
precip9 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1988.nc" )
precip10 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1989.nc" )
precip11<- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1990.nc" )
precip12 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1991.nc" )
precip13 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1992.nc" )
precip14 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1993.nc" )
precip15 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1994.nc" )
precip16 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1995.nc" )
precip17 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1996.nc" )
precip18 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1997.nc" )
precip19 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1998.nc" )
precip20 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.1999.nc" )
precip21 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.2000.nc" )
precip22 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.2001.nc" )
precip23 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.2002.nc" )
precip24 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.2003.nc" )
precip25 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.2004.nc" )
precip26 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.2005.nc" )
precip27 <- brick("C:\\Users\\cbrinkerhoff\\Downloads\\precip.V1.0.2006.nc" )
precip <- raster::stack(precip1, precip2, precip3, precip4, precip5, precip6, precip7, precip8, precip9, precip10)#, precip11, precip12, precip13, precip14, precip15, precip16, precip17, precip18, precip19, precip20, precip21, precip22, precip23, precip24, precip25, precip26, precip27)
writeRaster(precip, 'dailyPrecip_1980_2010')
precip <- rotate(precip)


plot(precip$X0000.12.30)
lons <- ncvar_get(precip, varid = 'lon')
lons <- 180 - lons

ncvar_add(precip, ncvar_def('lon', units = 'degrees_east', dim=list(10)))
