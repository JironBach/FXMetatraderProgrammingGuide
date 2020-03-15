//+------------------------------------------------------------------+
//|                                                    RSI_Alert.mq4 |
//|            Copyright 2018, xn--fx-dh4apioa4dw635ag17acyvju4f.com |
//+------------------------------------------------------------------+
#property copyright "xn--fx-dh4apioa4dw635ag17acyvju4f.com"
#property link      "https://xn--fx-dh4apioa4dw635ag17acyvju4f.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//---- input parameters
extern int revel_up = 70;
extern int revel_low = 30;
extern int RSI_Period = 14;
extern int Time_interval = 60;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetTimer(Time_interval);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
 void OnDeinit(const int reason){
   EventKillTimer();
   Comment("");
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   double P = iCustom(NULL, 0, "RSI", RSI_Period, 0, 0);
   
   Comment("RSI Alert : RSI(",RSI_Period,") Interval(",Time_interval,") Level(",revel_up,"-",revel_low,")");      
   if(revel_low >= P)
   {
      string Ps = DoubleToStr(P, 2);
      Alert(Symbol()," RSI UNDER TF(",Period(),") ",Ps);
   }
   else if(revel_up <= P)
   {
      string Ps = DoubleToStr(P, 2);
      Alert(Symbol()," RSI OVER TF(",Period(),") ",Ps);
   }

  }
//+------------------------------------------------------------------+
