#property strict
#property indicator_chart_window//チャートウィンドウに表示
#property indicator_buffers 3//指標バッファの数
#property indicator_type1 DRAW_LINE//指標０の種類
#property indicator_type2 DRAW_LINE//指標１の種類
#property indicator_type3 DRAW_LINE//指標２の種類
#property indicator_color1 clrRed//ベースラインの色
#property indicator_color2 clrBlue//上位ラインの色
#property indicator_color3 clrBlue//下位ラインの色

//指標バッファ用の配列の宣言
double BufMain[];//ベースライン
double BufUpper[];//上位ライン
double BufLower[];//下位ライン
input int BBPeriod=20;//ボリンジャーバンドの期間
input double BBDeviation=2;//標準偏差の倍率

//初期化関数
int OnInit()
  {//配列を指標バッファに関連付ける
    SetIndexBuffer(0,BufMain);//ベースライン
    SetIndexBuffer(1,BufUpper);//上位ライン
    SetIndexBuffer(2,BufLower);//下位ライン
    return(INIT_SUCCEEDED);
  }

//指標計算関数
int OnCalculate(
    const int rates_total,
    const int prev_calculated,
    const datetime &time[],
    const double &open[],
    const double &high[],
    const double &low[],
    const double &close[],
    const long &tick_volume[],
    const long &volume[],
    const int &spread[]
  )
  {
    int limit=rates_total-prev_calculated;//プロットするバーの数
    for(int i=0;i<limit;i++){
      BufMain[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,i);
      BufUpper[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,i);
      BufLower[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,i);
    }
    return(rates_total-1);
  }
