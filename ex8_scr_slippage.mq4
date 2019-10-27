//+------------------------------------------------------------------+
//|                                                  ex3_scr.mq4.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_confirm
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
    int ticket;
    ticket=OrderSend(_Symbol,OP_BUY,0.1,Ask,3,0,0);//新規買い注文
    MessageBox("チケット番号="+ticket);
  }
