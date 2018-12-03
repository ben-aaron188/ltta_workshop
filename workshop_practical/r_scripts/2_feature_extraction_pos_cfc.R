# ---
# title: "Feature extraction 1: POS"
# subtitle: "EuroCSS workshop: LTTA"
# subtitle: creators for change data
# output: html_notebook
# author:  B Kleinberg https://github.com/ben-aaron188
# ---

rm(list = ls())

## load data
setwd('/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/main_data')
load('eurocss_cfc_data_full.RData')

require(qdap)
require(data.table)
#require(rJava)

# empty_matrix = matrix(0, ncol(dt.data), 26)
# empty_list = list()
# for(i in 1:length(dt.sampled  _balanced)){
#   print(paste('processing: ', i, '/16000', sep=""))
#   pos_test = pos(dt.data$text[i]
#                  , zero.replace = 0
#                  , percent = T)
#   pos_prop = pos_test$POSprop
#   pos_prop$Filename = dt.data$Filename[i]
#   dt.data
#   empty_list[[i]] = pos_prop
#   print("~~~~ next ~~~~")
# }


#non-parallel
##simple loop w/ memory cleaning
setwd('./loop_run_pos_cfc')
seq_max = nrow(dt.data)
seq_min = 1
seq_batch = seq(seq_min, seq_max, 500)
for(i in seq_batch){
  print(i)
  seq_index = which(i == seq_batch)
  if(seq_index < length(seq_batch)){
    new_index = seq_batch[seq_index]:(seq_batch[seq_index+1]-1)
  } else {
    new_index = seq_batch[seq_index]:seq_max
  }
  print(paste('processing batch from: ', min(new_index), ' to ', max(new_index), sep=""))
  pos_test = pos(dt.data$text[new_index]
                 , zero.replace = 0
                 , percent = T)
  pos_prop = pos_test$POSprop
  pos_prop$Filename = dt.data$Filename[new_index]
  savename = paste(paste('batch', min(new_index), max(new_index), sep="_"), '.RData', sep="")
  save(pos_prop
       , file = savename)
  rm(pos_prop)
}

#rbind all from directory
files = list.files()
temp_list = list()
for(i in files){
  seq_index = which(i == files)
  load(i)
  temp_list[[seq_index]] = pos_prop
  rm(i)
}
pos_proportions = rbindlist(temp_list, fill = T)

pos_proportions[is.na(pos_proportions)] = 0

#remove duplicated columns
if(length(which(duplicated(names(pos_proportions)))) > 0){
  pos_proportions = pos_proportions[, -which(duplicated(names(pos_proportions)))]
}


dt.data_pos = merge(dt.data, pos_proportions, by = 'Filename')

dt.data_pos = dt.data_pos[, -3]

save(dt.data_pos
     , file='/Users/bennettkleinberg/Dropbox/workshop_eurocss/hackathon_data/features/eurocss_cfc_POS.RData')
