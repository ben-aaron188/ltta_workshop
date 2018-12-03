###############################################################################
###############################################################################
### FULL MASTER AND SERVANT SCRIPT
### Modifies text column input to vectorized and scaled sentiments sensitive of valence shifters.
### INPUT: text column + params
### OUTPUT: dataframe with scaled sentiments of equal size
###############################################################################

#1. PREPROCESSING
##accepts string input, constructs context cluster, and weighs sentiment
##INPUT: string input + params on valence shifter weights and cluster size
##OUTPUT: vector of transformed sentiments (or: dataframe - use this for debugging)
ncs_preprocess = function(string_input
                          , cluster_lower_ = 2
                          , cluster_upper_ = 2
                          , weight_negator_ = -1
                          , weight_amplifier_ = 1.5
                          , weight_deamplifier_ = 0.5
                          , weight_advcon_ = 0.25
                          , return_df = F
                          , verbose = F
                          ){

  require(stringr)
  require(data.table)
  require(lexicon)

  if(return_df == F){
    print('Function will return a vector of modified sentiments')
  } else if(return_df == T){
    print('Function will return a dataframe')
  }

  mod_string = paste(string_input, collapse = ' ')
  mod_string = str_replace_all(mod_string, "[.,;:!?]", "")
  mod_string = tolower(mod_string)
  mod_string = unlist(str_split(mod_string, " "))
  mod_string = mod_string[nchar(mod_string) > 0]

  #transform to data table
  text.raw = data.table(text = mod_string
                        , index = 1:length(mod_string))

  #load hash tables OPTIMIZE!
  hash.sentiment = lexicon::hash_sentiment_jockers_rinker
  hash.valence_shifters = lexicon::hash_valence_shifters

  #locate sentiments
  text.sentiment = merge(text.raw
                         , hash.sentiment
                         , by.x = 'text'
                         , by.y = 'x'
                         , all.x = TRUE)
  text.sentiment = text.sentiment[order(index),]

  #locate valence shifters
  text.valence_shifters = merge(text.sentiment
                                , hash.valence_shifters
                                , by.x = 'text'
                                , by.y = 'x'
                                , all.x = TRUE)
  text.valence_shifters = text.valence_shifters[order(index),]

  text.table = text.valence_shifters

  #recode valence shifters
  names(text.table)[3:4] = c('sentiment'
                             , 'valence'
  )

  #key to valence shifters:
  #1 = negator
  #2 = amplifier
  #3 = deamplifier
  #4 = adversative conjunction
  text.table$weights = ifelse(is.na(text.table$valence), 1,
                              ifelse(text.table$valence == 1, weight_negator_,
                                     ifelse(text.table$valence == 2, weight_amplifier_,
                                            ifelse(text.table$valence == 3, weight_deamplifier_,
                                                   weight_advcon_))))

  text.table$sentiment_score = text.table$sentiment
  text.table$sentiment_score[is.na(text.table$sentiment_score)] = 0
  text.table$sentiment_score_mod = text.table$sentiment_score

  for(i in 1:length(text.table$sentiment_score)){
    if(text.table$sentiment_score[i] != 0){
      cluster_boundary_lower = ifelse((i-cluster_lower_) > 0, (i-cluster_lower_), 1)
      cluster_boundary_upper = ifelse((i+cluster_upper_) < length(text.table$sentiment_score), (i+cluster_upper_), length(text.table$sentiment_score))
      a = text.table$weights[cluster_boundary_lower:cluster_boundary_upper]
      a[(1+cluster_lower_)] = text.table$sentiment_score[i]
      text.table$sentiment_score_mod[i] = prod(a, na.rm = T)

      if(verbose == T){
        print(paste('sentiment change for "', text.table$text[i], '": ',  text.table$sentiment_score[i], ' --> ', prod(a), sep=""))

      }

    }
  }

  if(return_df == T){
    new_text.table = text.table
  } else if(return_df == F){
    new_text.table = text.table$sentiment_score_mod
  }

  modified_sentiment_indices = which(text.table$sentiment_score != text.table$sentiment_score_mod)
  prop_changed = round(length(modified_sentiment_indices)/length(text.table$sentiment_score_mod), 2)
  print(paste('Proportion of total modified sentiments: ', prop_changed, sep=""))

  return(new_text.table)
}

#end of preprocessing

#2. full version: iterative over df column
##accepts input column, uses ncs_preprocessing, transforms string inputs to dct transformed values
##INPUT: string input column, id column + params
##OUTPUT: dataframe of dims bins*length(txt_input_col)
ncs_full = function(txt_input_col
                    , txt_id_col
                    , low_pass_filter_size = 5
                    , transform_values = T
                    , normalize_values = F
                    , min_tokens = 10
                    , cluster_lower = 2
                    , cluster_upper = 2
                    , weight_negator = -1
                    , weight_amplifier = 1.5
                    , weight_deamplifier = 0.5
                    , weight_advcon = 0.25
                    , bins = 100
                    , verbose = F
){

  require(syuzhet)

  currentwd = getwd()
  t1 = Sys.time()

  if(weight_negator < weight_deamplifier){
    print('###################################################')
    print(paste('Initialized ____'))
    print(paste('Cluster size: -', cluster_lower, " : +", cluster_upper, sep=""))
    print(paste('Negator weight: ', weight_negator, sep=""))
    print(paste('Amplifier weight: ', weight_amplifier, sep=""))
    print(paste('De-amplifier weight: ', weight_deamplifier, sep=""))
    print(paste('Adv. conj. weight: ', weight_advcon, sep=""))
    print('###################################################')
  } else {
    print('WARNING: Negator weight must be lower than deamplifier weight')
  }


  txt_col = txt_input_col
  id_col = txt_id_col
  empty_matrix = matrix(data = 0
                        , nrow = bins
                        , ncol = length(txt_col)
  )
  for(i in 1:length(txt_col)){
    if(length(unlist(str_split(txt_col[i], ' '))) >= min_tokens) {
      print(paste('Performing NCS extraction: ', id_col[i], sep=""))
      print(paste('- - - - - - - - - - ', i, '/', length(id_col),  sep=""))
      a = ncs_preprocess(string_input = txt_col[i]
                         , cluster_lower_ = cluster_lower
                         , cluster_upper_ = cluster_upper
                         , weight_negator_ = weight_negator
                         , weight_amplifier_ = weight_amplifier
                         , weight_deamplifier_ = weight_deamplifier
                         , weight_advcon_ = weight_advcon
                         , return_df = F
                         , verbose = verbose)
      text.scored = a
      text.scored_binned = get_dct_transform(text.scored
                                             , x_reverse_len=bins
                                             , low_pass_size = low_pass_filter_size
                                             , scale_range = transform_values
                                             , scale_vals = normalize_values)
      empty_matrix[, i] = text.scored_binned
      print('==================== NEXT ====================')
    } else {
      empty_matrix[, i] = rep(NA, bins)
    }

  }
  final_df = as.data.frame(empty_matrix)
  colnames(final_df) = txt_id_col
  t2 = Sys.time()
  print(t2-t1)
  setwd(currentwd)
  return(final_df)
}

#end of full

#3. USAGE EXAMPLE
##for texts from source, use the function: https://github.com/ben-aaron188/r_helper_functions/blob/master/txt_df_from_dir.R
# data = data.frame('text' = character(3)
#                   , 'text_id' = character(3))
# data$text = c('this is a super, great positive sentence and I just love doing this. Now this will be very negative and with disgusting words and ugly phrases'
#               , 'here we begin in a bad, bad, and ugly way but quickly become overly positive for all the great things this exciting code can do'
#               , "I haven't been sad in a long time. I am extremely happy today. It's a good day. But suddenly I'm only a little bit happy. Then I'm not happy at all. In fact, I am now the least happy person on the planet. There is no happiness left in me. Wait, it's returned! I don't feel so bad after all!")
# data$text_id = c('text1', 'text2', 'text3')
#
# ncs_full(txt_input_col = data$text
#          , txt_id_col = data$text_id
#          , low_pass_filter_size = 5
#          , transform_values = T
#          , normalize_values = F
#          , min_tokens = 10
#          , cluster_lower = 2
#          , cluster_upper = 2
#          )

### END

#TODO
#- progress bar