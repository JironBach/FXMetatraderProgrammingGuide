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
    int ticket;//チケット番号
    ticket=OrderSend(_Symbol,OP_SELL,0.1,Bid,3,0,0);//新規売り注文
    MessageBox("チケット番号="+ticket);
  }
