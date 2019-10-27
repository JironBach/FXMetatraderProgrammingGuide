#property strict
#property indicator_chart_window//チャートウィンドウに表示
#property indicator_buffers 1//指標バッファの数
#property indicator_type1 DRAW_LINE//指標の種類
#property indicator_color1 clrRed//ラインの色
#property indicator_width1 2//ラインの太さ
#property indicator_style1 STYLE_SOLID//ラインの種類
double Buf[];//指標バッファ用の配列の宣言
input int MomPeriod=10;//モメンタムの期間
input double MaxMom=10;//(モメンタム100)の最大値

//初期化関数
int OnInit(){
  SetIndexBuffer(0,Buf);//配列を指標バッファに関連付ける
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
    if(prev_calculated==0)limit--;//１回目の実行時のみlimitを1減らす
    for(int i=limit-1;i>=0;i--){
      double mom=iMomentum(_Symbol,0,MomPeriod,PRICE_CLOSE,i);
      double a=MathMin(MathAbs(mom-100)/MaxMom,1);
      Buf[i]=a*Close[i]+(1-a)*Buf[i+1];
    }
    return(rates_total-1);
  }
