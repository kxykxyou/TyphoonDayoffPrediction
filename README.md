# Typhoon Day-off Predictor
Given typhoon alert and weather infos, predicting tomorrow will be dayoff or not

## Topic：Predict Typhoon Day-off With Official Alert Announcemnet And Weather data
(在已知今天發布颱風警報（不論海警或陸警）的情況下，預測明天是否放假)

## Data origin
1. 行政院人事總處歷次天災放假查詢：https://www.dgpa.gov.tw/informationlist?uid=374
2. 中央氣象局測站歷史觀測紀錄查詢系統：https://e-service.cwb.gov.tw/HistoryDataQuery/index.jsp
3. 中央氣象局測站資料查詢：https://e-service.cwb.gov.tw/wdps/obs/state.htm
4. 中央氣象局有發警報颱風列表：https://rdc28.cwb.gov.tw/TDB/public/warning_typhoon_list/

## User Interface
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/UI.png' width = '700'>

## System workflow
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/UserFlow.png' width = '700'>

## Model Building
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/ModelBuilding01.png' width = '500'>
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/ModelBuilding02.png' width = '500'>
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/ModelBuilding03.png' width = '500'>
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/ModelBuilding04.png' width = '500'>

## Model Assessment
### Confusion matrix
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/ConfusionMatrix.png' width = '700'>

### ROC曲線
<img src='https://github.com/kxykxyou/TyphoonDayoffPrediction/blob/master/Illustrations/ROCCurve.png' width = '500'>
