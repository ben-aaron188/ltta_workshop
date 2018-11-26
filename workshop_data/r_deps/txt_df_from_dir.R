###############################################################################
### Creates a dataframe with raw texts from directory
###############################################################################
require(stringr)


txt_df_from_dir = function(dirpath
                           , recursive
                           , to_lower = FALSE
                           , include_processed = FALSE){
  currentwd = getwd()
  setwd(dirpath)
  if(recursive == T){
    print('*** recursive iteration currently only supports one level of depth.')
    print('--- having more depth is possible but needs manual regex setting for file id.')
    file_list = list.files(pattern = '*.txt', recursive = T)
  } else if (recursive == F){
    file_list = list.files(pattern = '*.txt', recursive = F)
  }
  data = do.call("rbind"
                 , lapply(file_list
                          , FUN=function(files) {
                            print(files)
                            print(nchar(readChar(files
                                                 , file.info(files)$size)))
                            paste(files
                                  , readChar(files
                                            , file.info(files)$size)
                                  , sep="@@@")
                          }
                 )
  )

  id = 1:nrow(data)
  data = cbind(data, id)

  data = as.data.frame(data)
  names(data) = c('text', 'id')

  data$Filename = as.factor(str_extract(data$text, '^[^@@@]*'))

  if(recursive == T){
    data$file_id = sub('.*\\/(.*)','\\1', data$Filename)
    data$file_parent = sub('(.*)\\/.*','\\1', data$Filename)
  }

  data$text = sub('.*\\@@@(.*)','\\1', data$text)
  data$text = str_replace_all(data$text, "[\n]", " ")
  data$text = str_replace_all(data$text, ">", " ")
  data$text = str_replace_all(data$text, "--", " ")
  data$text = str_squish(data$text)


  if(to_lower == T){
    data$text = tolower(data$text)
  }
  data$nwords = unlist(lapply(str_split(data$text, ' '), length))

  data = data[,-2]

  if(include_processed == T){
    require(tm)
    ### these might be required ###
    # dyn.load('/Library/Java/JavaVirtualMachines/jdk1.8.0_77.jdk/Contents/Home/jre/lib/server/libjvm.dylib')
    # require(rJava)
    # library(qdap)
    # library(openNLP)
    data$text_proc = sapply(data$text, function(x){
      tm_vec_col = Corpus(VectorSource(x))
      tm_vec_col = tm_map(tm_vec_col, content_transformer(replace_contraction))
      tm_vec_col = tm_map(tm_vec_col, content_transformer(replace_number))
      tm_vec_col = tm_map(tm_vec_col, content_transformer(replace_abbreviation))
      tm_vec_col = tm_map(tm_vec_col, removePunctuation)
      tm_vec_col = tm_map(tm_vec_col, content_transformer(tolower))
      tm_vec_col = tm_map(tm_vec_col, stripWhitespace)
      tm_vec_col = tm_map(tm_vec_col, removeWords, tm::stopwords("en"))
      tm_vec_col = tm_map(tm_vec_col, stripWhitespace)
      tm_vec_col = tm_map(tm_vec_col, content_transformer(tolower))
      tm_vec_col = tm_map(tm_vec_col, stemDocument, language = 'en')
      as.character(as.matrix(tm_vec_col$content))
    })
  }

  data$id = 1:nrow(data)
  setwd(currentwd)

  return(data)
}

#CHANGELOG:
#6 DEC 2017: ADDED processing pipeline for additional text column
#3 MAR 2018: ADDED  recursiveness
#27 APR 2018: ADDED WORD (TOKEN) COUNT + ADDED LINE BREAK FIX
#5 MAY 2018: ADDED LOWER PARAMETER
#30 OCT 2018: ADDED STR SQUISH AND OTHER CLEANING FOR SPEC. CHARS.

#END CHANGELOG

#TODO:
# - col with dir - 1, etc. (param: depth = int)


#usage example:
#new_data = txt_df_from_dir(dirpath = './my_text_folder', recursive = T, include_processed = T, to_lower = F)

#View(new_data)

#load as:
# source('./txt_df_from_dir.R')