library(dplyr)
library(psych)
library(lubridate)
library(openxlsx)

df = read.csv('/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_2_numerical_wind.csv', header = T, row.names = 'X')
df_station = read.csv('/Users/shyanechang/Desktop/AI_Class/專題/data/station_info/existing_station.csv', header = T)
df_station_info = df_station[c(1,3:5)]
colnames(df_station_info) = c('StnID', 'StnHeight', 'lon', 'lat')

day_shiftting = function(df){
  df_shiftting = df[c('ObsDate', 'StnID', 'Dayoff')]
  df_shiftting$ObsDate = df_shiftting$ObsDate %>% as.Date
  df_shiftting$TmrDate = df_shiftting$ObsDate + days(1)
  df_shiftting$ODSID = paste(df_shiftting$ObsDate,df_shiftting$StnID, sep = '_')
  df_shiftting$TDSID = paste(df_shiftting$TmrDate,df_shiftting$StnID, sep = '_')
  df_shiftting$TmrDayoff = c(NA)
  for(idx in 1:dim(df_shiftting)[1]){
    if(df_shiftting$TDSID[idx] %in% df_shiftting$ODSID){
      df_shiftting$TmrDayoff[idx] = df_shiftting$Dayoff[which(df_shiftting$TDSID[idx] == df_shiftting$ODSID)]
      print(idx)
    }}
  TmrDayoff = df_shiftting$TmrDayoff
  return(cbind(df, TmrDayoff))
}
# df_day_shiftting = df %>% day_shiftting

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
  df$WD_vector_x = sqrt(df$WS) * WD_unit_vector_x
  df$WD_vector_y = sqrt(df$WS) * WD_unit_vector_y
  df$WDGust_vector_x = sqrt(df$WSGust) * WDGust_unit_vector_x
  df$WDGust_vector_y = sqrt(df$WSGust) * WDGust_unit_vector_y
  return(df)
}
# df_wind = df_day_shiftting %>% add_wind_vector

sep_by_class_for_DCT = function(df){
  objs_colnames = colnames(df)[c(2, 4:6, 9:20, 46, 47)]  # 每個鄉鎮市有沒有算都會一樣的columns
  num_colnames = colnames(df)[c(2, 4:6, 21:30, 35:45, 52:54)]
  wind_colnames = colnames(df)[c(2, 4:6, 48:51)]
  df_objs = df[objs_colnames]
  df_num = df[num_colnames]
  df_wind = df[wind_colnames]
  list_DCT = list(df_objs, df_num, df_wind)
  return(list_DCT)
}


sep_by_class_for_DC = function(df){
  objs_colnames = colnames(df)[c(2, 4:5, 9:20, 46, 47)]
  num_colnames = colnames(df)[c(2, 4:5, 21:30, 35:45, 52:54)]
  wind_colnames = colnames(df)[c(2, 4:5, 48:51)]
  df_objs = df[objs_colnames]
  df_num = df[num_colnames]
  df_wind = df[wind_colnames]
  list_DC = list(df_objs, df_num, df_wind)
  return(list_DC)
}

clean_to_DCT = function(list_DCT){
  df_DCT_obj = list_DCT[[1]] %>% group_by(ObsDate, Region, County, Township) %>% distinct()
  df_DCT_num = list_DCT[[2]] %>% group_by(ObsDate, Region, County, Township) %>% summarise_all(list(mean), na.rm = T) %>% as.data.frame()
  df_DCT_wind = list_DCT[[3]] %>% group_by(ObsDate, Region, County, Township) %>% summarise_all(list(mean), na.rm = T) %>% as.data.frame()
  df_DCT_temp = merge(df_DCT_obj, df_DCT_num, by = c('ObsDate', 'Region', 'County', 'Township'))
  df_DCT = merge(df_DCT_temp, df_DCT_wind, by = c('ObsDate', 'Region', 'County', 'Township'))
  return(df_DCT)
}

clean_to_DC = function(list_DC){
  df_DC_obj = list_DC[[1]] %>% group_by(ObsDate, Region, County) %>% distinct()
  df_DC_num = list_DC[[2]] %>% group_by(ObsDate, Region, County) %>% summarise_all(list(mean), na.rm = T) %>% as.data.frame()
  df_DC_wind = list_DC[[3]] %>% group_by(ObsDate, Region, County) %>% summarise_all(list(mean), na.rm = T) %>% as.data.frame()
  df_DC_temp = merge(df_DC_obj, df_DC_num, by = c('ObsDate', 'Region', 'County'))
  df_DC = merge(df_DC_temp, df_DC_wind, by = c('ObsDate', 'Region', 'County'))
  return(df_DC)
}




main_DCT = function(df){
  df_DCT = df %>% sep_by_class_for_DCT %>% clean_to_DCT
  return(df_DCT)
  }

main_DC = function(df){
  df_DC = df %>% sep_by_class_for_DC %>% clean_to_DC
  return(df_DC)
}

df_preprocessed = df %>% day_shiftting %>% add_wind_vector

colnames(df_preprocessed)[c(19,20)] = c('born_spotE', 'born_spotN')

df_preprocessed_height = merge(df_preprocessed, df_station_info, by = 'StnID', all.x = T)

df_DC_result = main_DC(df_preprocessed_height)
df_DCT_result = main_DCT(df_preprocessed_height)

write.csv(df_preprocessed_height, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_6_D.csv', fileEncoding = "UTF-8")
write.csv(df_DC_result, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_6_DC.csv', fileEncoding = "UTF-8")
write.csv(df_DCT_result, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_6_DCT.csv', fileEncoding = "UTF-8")
# write.xlsx(df_preprocessed, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_5_D.xlsx', overwrite = T)
# write.xlsx(df_DC_result, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_5_DC.xlsx', overwrite = T)
# write.xlsx(df_DCT_result, '/Users/shyanechang/Desktop/AI_Class/專題/data/station_observation/data_ver_5_DCT.xlsx', overwrite = T)