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
    Print("通貨ペア＝",_Symbol);
    Print("小数桁数＝",_Digits);
    Print("最小値幅＝",_Point);
    Print("タイムフレーム＝",_Period);
  }
