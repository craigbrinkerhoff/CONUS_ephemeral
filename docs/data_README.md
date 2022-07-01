### Guide to data that drives (and validates) the model

- CONUS Water Table Depth Model
  - **Filename:** conus_MF6_SS_Unconfined_250_dtw.tif
  - **Data:** https://doi.org/10.5066/P91LFFN1
  - **Paper:** https://doi.org/10.1029/2019WR026724
  - **Resolution/Scale:** 250m
  - **Years:** 2000-2013

- CONUS Long-Term Gauge-Based Daily Precip Model
  - **Filename:** dailyPrecip_1980_2010.gri
    - yearly daily aggregated via `src/netcdf_prep.R`
  - **Data:** https://psl.noaa.gov/data/gridded/data.unified.daily.conus.html#source
  - **Paper (validation)**: https://doi.org/10.1029/2007JD009132
  - **Paper (algorithm):** https://doi.org/10.1175/JHM583.1
  - **Resolution/Scale:** 28km
  - 1980-2010

- CONUS hydrography and mean annual streamflow model
  - **Filename:** `src/CONUS_ephemeral_data/` directories
  - **Link:** https://www.usgs.gov/national-hydrography/nhdplus-high-resolution
  - **Resolution/Scale:** 1:24,000
  - **Years:** 1970-2000 (validated against 1970-2018)

- CONUS nitrogen/phosphorous model
  - **Filename:** none for now
  - **Data:** https://doi.org/10.1594/PANGAEA.899168
  - **Paper**: https://doi.org/10.1038/s41597-020-0478-7
  - **Resolution/Scale:** 1km
  - 1994-2018

- USGS Streamgauge data
  - **Filename:** NA
  - **Data:** Accessed via `dataRetrieval` R package
  - **Resolution/Scale:** NA

- USGS HUC4 Runoff Data
  - **Filename:** HUC4_runoff_mm.txt
  - **Data (indirect):** https://waterwatch.usgs.gov/index.php?id=romap3&sid=w__download
  - **Paper (concept):** https://doi.org/10.1111/1752-1688.12431
  - **Resolution/Scale:** HUC4 basins
  - **Years:** 1970-2021

- EPA/Corps Voluntary WOTUS Jurisdictional Determinations Database
  - **Filename**: jds202206201319.csv
  - **Data:** https://watersgeo.epa.gov/cwa/CWA-JDs/
  - **Paper:** NA
  - **Resolution/Scale:** NA
