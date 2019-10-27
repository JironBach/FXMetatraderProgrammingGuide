//+------------------------------------------------------------------+
//|                                                  ex3_scr.mq4.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("Open[0]=",Open[0],"Open[1]=",Open[1]);
   Print("High[0]=",High[0],"High[1]=",High[1]);
   Print("Low[0]=",Low[0],"Low[1]=",Low[1]);
   Print("Close[0]=",Close[0],"Close[1]=",Close[1]);
  }
