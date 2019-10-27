//+------------------------------------------------------------------+
//|                                                      ex2-ind.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
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
    Buf[0]=Close[0];
    Buf[1]=Close[1];
    Buf[2]=Close[2];
    Buf[3]=Close[3];
    Buf[4]=Close[4];
    return(rates_total);
  }
