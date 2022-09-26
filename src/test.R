library(ggplot2)
library(dplyr)
library(sf)
net_1005_results <- tar_read(rivNetFin_1005)
results <- tar_read(combined_results)


##RIVER NETWORK MAP 1005-----------------------------------------------------------
net_1005 <- sf::st_read(dsn = '/nas/cee-water/cjgleason/craig/CONUS_ephemeral_data/HUC2_10/NHDPLUS_H_1005_HU4_GDB/NHDPLUS_H_1005_HU4_GDB.gdb', layer='NHDFlowline')
net_1005 <- dplyr::left_join(net_1005, net_1005_results, 'NHDPlusID')
net_1005 <- dplyr::filter(net_1005, is.na(perenniality)==0)

hydrography_1005 <- ggplot(net_1005, aes(color=perenniality, size=Q_cms)) +
  geom_sf()+
  coord_sf(datum = NA)+
  scale_color_manual(name='Stream Type',
                     values=c('#fdae61', '#313695'),
                     labels=c('Ephemeral', 'Not Ephemeral')) +
  scale_size(name='Discharge [cms]',
             range=c(0.4,2),
             breaks=c(0,0.1,1,10,100))+
  labs(tag='D')+
  theme(plot.title = element_text(face = "italic", size = 26),
        plot.tag = element_text(size=26,
                            face='bold'))+
  ggsn::scalebar(net_1005,
           dist_unit="km",
           transform = TRUE,
           dist=25,
           location='bottomleft',
           anchor=c('x'=-110, 'y'=48)) +
  xlab('')+
  ylab('') +
  ggtitle(paste0('Milk River:\n', results[results$huc4 == '1005',]$percQ_eph_flowing_scaled*100, '% ephemeral streamflow'))

ggsave('test.jpg', hydrography_1005, width=8, height=8)
