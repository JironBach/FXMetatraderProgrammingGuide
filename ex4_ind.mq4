#property strict
#property indicator_chart_window//チャートウィンドウに表示
#property indicator_buffers 1//指標バッファの数
#property indicator_type1 DRAW_LINE//指標の種類
#property indicator_color1 clrRed//ラインの色
#property indicator_width1 2//ラインの太さ
#property indicator_style1 STYLE_SOLID//ラインの種類

double Buf[];//指標バッファ用の配列の宣言

//初期化関数
int OnInit()
  {
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
      const int &spread[]
    )
    {
      for(int i=0;i<10;i++){
        Buf[i]=(Open[i]+High[i]+Low[i]+Close[i])/4;}
        return(rates_total);
    }
