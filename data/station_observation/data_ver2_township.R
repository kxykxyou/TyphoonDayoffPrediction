library(dplyr)
library(psych)

df = read.csv('/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_2_numerical_wind.csv', header = T, row.names = 'X')

add_wind_vector = function(df){
  # 處理wind
  # transform WS, WG, WSGust, WDGust
  # 氣象角度轉為及座標單位向量公式：(-theta + 90) * pi/180
  WD = df$WD
  WDGust = df$WDGust
  WD_trans_x = ((-WD + 90) * pi/180) %>% cos %>% round(., 5)
  WD_trans_y = ((-WD + 90) * pi/180) %>% sin %>% round(., 5)
  WDGust_trans_x = ((-WDGust + 90) * pi/180) %>% cos %>% round(., 5)
  WDGust_trans_y = ((-WDGust + 90) * pi/180) %>% sin %>% round(., 5)
  
  WD_unit_vector_x = WD_trans_x
  WD_unit_vector_y = WD_trans_y
  WDGust_unit_vector_x = WDGust_trans_x
  WDGust_unit_vector_y = WDGust_trans_y
  # df$WD_unit_vector = WD_unit_vector
  # df$WDGust_unit_vector = WDGust_unit_vector
  df$WD_vector_x = df$WS * WD_unit_vector_x
  df$WD_vector_y = df$WS * WD_unit_vector_y
  df$WDGust_vector_x = df$WSGust * WDGust_unit_vector_x
  df$WDGust_vector_y = df$WSGust * WDGust_unit_vector_y
  return(df)
}
df_1 = df %>% add_wind_vector

# 生成資料欄位DCT/DC(ObsDate_Township / ObsDate_County)作為後續要merge的key

# add_DC_DCT = function(df){
#   df$DC = paste(df$ObsDate, df$County, sep = '_')
#   df$DCT = paste(df$ObsDate, df$County, df$Township, sep = '_')
#   return(df)
# }

sep_by_class_for_DCT = function(df){
  objs_colnames = colnames(df)[c(1, 4:6, 9:20, 46)]
  num_colnames = colnames(df)[c(1, 4:6, 21:30, 35:45)]
  wind_colnames = colnames(df)[c(1, 4:6, 47:50)]
  df_objs = df[objs_colnames]
  df_num = df[num_colnames]
  df_wind = df[wind_colnames]
  list_DCT = list(df_objs, df_num, df_wind)
  return(list_DCT)
}

sep_by_class_for_DC = function(df){
  objs_colnames = colnames(df)[c(1, 4:5, 9:20, 46)]
  num_colnames = colnames(df)[c(1, 4:5, 21:30, 35:45)]
  wind_colnames = colnames(df)[c(1, 4:5, 47:50)]
  df_objs = df[objs_colnames]
  df_num = df[num_colnames]
  df_wind = df[wind_colnames]
  list_DC = list(df_objs, df_num, df_wind)
  return(list_DC)
}

clean_to_DCT = function(list_DCT){
  df_DCT_obj = list_DCT[[1]] %>% group_by(ObsDate, Region, County, Township) %>% distinct()
  df_DCT_num = list_DCT[[2]] %>% group_by(ObsDate, Region, County, Township) %>% summarise_all(list(mean), na.rm = T) %>% as.data.frame()
  df_DCT_wind = list_DCT[[3]] %>% group_by(ObsDate, Region, County, Township) %>% summarise_all(list(sum), na.rm = T) %>% as.data.frame()
  df_DCT = merge(df_DCT_obj, df_DCT_num, by = c('ObsDate', 'Region', 'County', 'Township'))
  return(df_DCT)
}

clean_to_DC = function(list_DC){
  df_DC_obj = list_DC[[1]] %>% group_by(ObsDate, Region, County) %>% distinct()
  df_DC_num = list_DC[[2]] %>% group_by(ObsDate, Region, County) %>% summarise_all(list(mean), na.rm = T) %>% as.data.frame()
  df_DC_wind = list_DC[[3]] %>% group_by(ObsDate, Region, County) %>% summarise_all(list(sum), na.rm = T) %>% as.data.frame()
  df_DC = merge(df_DC_obj, df_DC_num, by = c('ObsDate', 'Region', 'County'))
  return(df_DC)
}



main_DCT = function(df){
  df_DCT = df %>% add_wind_vector() %>% sep_by_class_for_DCT %>% clean_to_DCT
  return(df_DCT)
  }

main_DC = function(df){
  df_DC = df %>% add_wind_vector() %>% sep_by_class_for_DC %>% clean_to_DC
  return(df_DC)
}

df_DC_result = main_DC(df)
df_DCT_result = main_DCT(df)
write.csv(df_DC_result, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_3_DC.csv', fileEncoding = "UTF-8")
write.csv(df_DCT_result, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_3_DCT.csv', fileEncoding = "UTF-8")
