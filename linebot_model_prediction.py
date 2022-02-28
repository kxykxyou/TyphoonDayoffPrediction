elif mtext in locations:
    locationName = mtext
    try:
        df_get = get(locationName)  # 獲得天氣data
        data1 = get_datashow(locationName)
        if df_get.isna().sum().sum() != 0:  # 判斷是否需要補值
            kNN_imputer = joblib.load('kNN_imputer.joblib')
            df_imputed = kNN_imputer.transform(df_get)
            df_imputed = pd.DataFrame(df_imputed, columns = df_get.columns)

        df_full = merge_typhoon_data(df_imputed)  # 合併
        MMscaler = joblib.load('MMscaler.joblib')
        x = MMscaler.transform(df_full)
        model = joblib.load('rf_model.joblib')
        prediction = model.predict_proba(x)
        dayoff_proba = prediction[0][1]*100

#         if dayoff_proba >= 90:
#             try:
#                 message = f'明天放颱風假機率:{round(dayoff_proba, 1)}%\n超高機率放颱風假，祝您假期愉快！'
#             except:
#                 message = "不好意思~請您再試一次"
#         elif dayoff_proba >= 80:
#             try:
#                 message = f'明天放颱風假機率:{round(dayoff_proba, 1)}%\n高機率放颱風假，請做好準備！'
#             except:
#                 message = "不好意思~請您再試一次"
#         elif dayoff_proba >= 60:
#             try:
#                 message = f'明天放颱風假機率:{round(dayoff_proba, 1)}%\n可以期待一下颱風假！'
#             except:
#                 message = "不好意思~請您再試一次"
#         elif dayoff_proba >= 40:
#             try:
#                 message = f'明天放颱風假機率:{round(dayoff_proba, 1)}%\n預言大師也算不準明天到底會不會放颱風假...'
#             except:
#                 message = "不好意思~請您再試一次"
#         elif dayoff_proba >= 20:
#             try:
#                 message = f'明天放颱風假機率:{round(dayoff_proba, 1)}%\n明天不太可能放颱風假哦！'
#             except:
#                 message = "不好意思~請您再試一次"
#         else:
#             try:
#                 message = f'明天放颱風假機率:{round(dayoff_proba, 1)}%\n您還是別妄想颱風假了～～'
#             except:
#                 message ="不好意思~請您再試一次"
#         print(message)
    except:
        print('再試一次')
else:
    print(f'{mtext} not in locations')


# def get(locationName):
#     url = 'https://opendata.cwb.gov.tw/api/v1/rest/datastore/O-A0003-001?'
#     params = {
#         'Authorization': 'CWB-5393733F-1F8E-4BD2-A358-0360AABEE6EB',
#         'format': 'JSON',
#         'locationName': locationName,
#     }

#     url = url + urllib.parse.urlencode(params)
#     data = requests.get(url).json()
#     stnInfo = data['records']['location'][0]
#     weatherElement = data['records']['location'][0]['weatherElement']
#     obs = {
#         'lat': [float(stnInfo['lat'])],
#         'lon': [float(stnInfo['lon'])],
#     }
#     name_mapping = {
#         'lat': 'lat',
#         'lon': 'lon',
#         'Dayoff': 'Dayoff',
#         'ELEV': 'StnHeight',
#         'HUMD': 'RH',  
#         'D_TX': 'T.Max',
#         'D_TN': 'T.Min',
#         'TEMP': 'Temperature',
#         'PRES': 'StnPres',  
#         '24R': 'Precp',
#         'WD_vector_x': 'WD_vector_x',
#         'WD_vector_y': 'WD_vector_y',
#         'WDGust_vector_x': 'WDGust_vector_x',
#         'WDGust_vector_y': 'WDGust_vector_y',
#         'WDSD': 'A',
#         'WDIR': 'B',
#         'H_XD': 'C',
#         'H_FX': 'D',

#     }
    for i in range(len(weatherElement)):  ###########
        name = weatherElement[i]['elementName']
        value = weatherElement[i]['elementValue']
        if name in name_mapping.keys():
            obs[name] = [float(value)]
            if float(value) < -90:
                obs[name] = [np.nan]
            else:
                if name == 'HUMD':
                    v = float(value)*100
                    obs[name] = [v]

    #     # 處理wind
    #     # 轉換 WS, WG, WSGust, WDGust
    #     # 氣象角度轉為及座標單位向量公式：(-theta + 90) * pi/180，再分別以cos, sin處理得到單位向量
    #     # 風速x單位向量
    # try:
    #     WD = obs['WDIR'][0]
    #     WS = obs['WDSD'][0]
    #     WD_unit_vector_x = round(np.cos((-WD + 90) * np.pi/180), 5)
    #     WD_unit_vector_y = round(np.sin((-WD + 90) * np.pi/180), 5)
    #     WD_vector_x = np.sqrt(WS) * WD_unit_vector_x
    #     WD_vector_y = np.sqrt(WS) * WD_unit_vector_y
    # except:
    #     WD_vector_x = np.nan
    #     WD_vector_y = np.nan

    # try:
    #     WDGust = obs['H_XD'][0]
    #     WSGust = obs['H_FX'][0]
    #     WDGust_unit_vector_x = round(np.cos((-WDGust + 90) * np.pi/180), 5)
    #     WDGust_unit_vector_y = round(np.sin((-WDGust + 90) * np.pi/180), 5)
    #     WDGust_vector_x = np.sqrt(WSGust) * WDGust_unit_vector_x
    #     WDGust_vector_y = np.sqrt(WSGust) * WDGust_unit_vector_y
    # except:
    #     WDGust_vector_x = np.nan
    #     WDGust_vector_y = np.nan

    # obs['WD_vector_x'] = WD_vector_x
    # obs['WD_vector_y'] = WD_vector_y
    # obs['WDGust_vector_x'] = WDGust_vector_x
    # obs['WDGust_vector_y'] = WDGust_vector_y
    
    # df = pd.DataFrame(obs)
    # df = df.rename(name_mapping, axis=1)
    # df = df.drop(['A', 'B', 'C', 'D', ], axis=1)
    df = df.reindex(sorted(df.columns), axis = 1)
    # return df


# def kNN_imputation(df):
#     # kNN補值，若沒有NA則
#     kNN_imputer = joblib.load(os.getcwd()+'/models/kNN_imputer.joblib')
#     df = kNN_impoter.fit_transform(df)
#     return df


def merge_typhoon_data(df_get):
 #    颱風的資料寫死在這裡，選的是莫拉克颱風
  #  1. 字典形式列出特徵工程後還存在的颱風參數
 #   2. 合併抓下來的觀測資料與颱風資料
 #   3. 回傳含有颱風&觀測資料的dataframe
    # 1.
    typhoon_feature = {
        'Dayoff': [1.],  # 假設放假
        'route_3': [1.],
        'route_2': [1.],
        'route_--': [1.],
        'hpa': [955.],
        'TyWS': [40.],
        'X7_radius': [250.],
        'X10_radius': [100.],
        'alert_num': [36.],
        'born_spotE': [136.],
        'born_spotN': [21.],
    }

    df_typhoon = pd.DataFrame(typhoon_feature)
    df_get = df_get.join(df_typhoon, how='left')
    df_get = df_get.reindex(sorted(df_get.columns), axis=1)
    return df_get


# def MM_scale(df):
#     # 使用fit training set的MinMaxScaler壓縮data到0~1之間
#     MMscaler = joblib.load(os.getcwd()+'/models/MMscaler.joblib')
#     df_MM = MMscaler.transform(df)

#     return df_MM


# def prediction(x):
#     # 使用model進行預測
#     # 要改成mtext回覆的格式
#     model = joblib.load(os.getcwd()+'/models/rf_model.joblib')
#     prediction = model.predict_proba(x)
#     dayoff_proba = prediction[0][1]*100
#     return dayoff_proba



