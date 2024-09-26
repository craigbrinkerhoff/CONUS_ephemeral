library(targets)

#DEPENDING ON HOW YOU ARE SUBMITING JOBS, PICK ONE OF THESE THREE OPTIONS (and set _targets.R accordingly)

#tar_make_future(mainMap1, workers=50)
tar_make(mainMap1)
