#property strict
#property indicator_separate_window//別ウィンドウに表示
#property indicator_buffers 1//表示する指標バッファの数
#property indicator_type1 DRAW_LINE//指標の種類
#property indicator_color1clr Violet//ラインの色
#property indicator_width1 2//ラインの太さ
#property indicator_style1 STYLE_SOLID//ラインの種類

//指標バッファ用の配列の宣言
double Buf[];//平滑化した指標（表示する）
double Mom[];//モメンタムの指標（表示しない）
input int MomPeriod=10;//モメンタムの期間
input int Smooth=5;//移動平均の期間

//初期化関数
int OnInit()
  {
    IndicatorBuffers(2);//指標バッファを２個使用する
    //配列を指標バッファに関連付ける
    SetIndexBuffer(0,Buf);//平滑化した指標
    SetIndexBuffer(1,Mom);//モメンタムの指標
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
  const int &spread[])
  {
    int limit=rates_total-prev_calculated;//プロットするバーの数
    for(int i=0;i<limit;i++){
      //モメンタムの計算
      Mom[i]=iMomentum(_Symbol,0,MomPeriod,PRICE_CLOSE,i);
    }
    for(int i=0;i<limit;i++){
      //平滑化の計算
      Buf[i]=iMAOnArray(Mom,0,Smooth,0,MODE_SMA,i);
    }
    return(rates_total-1);
  }
