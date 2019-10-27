//+------------------------------------------------------------------+
//|                                           StopLossTakeProfit.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property script_show_inputs

extern int StopLoss=3;
extern int TakeProfit=7;
extern int Slippage=3;

int modifyOk=0;//StopLossとTakeProfitが設定できたかどうか受け取る変数
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
    //損切り利食い関数
    if(Digits==3 || Digits==5){
      StopLoss *= 10;
      TakeProfit *= 10;
      Slippage *= 10;
    }
    for(int i=0; i<OrdersTotal(); i++){
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderType() == OP_BUY)
        modifyOk = OrderModify(OrderTicket(), 0, OrderOpenPrice()-StopLoss*Point, 0, White);
      else if(OrderType() == OP_SELL)
        modifyOk = OrderModify(OrderTicket(), 0, OrderOpenPrice()-StopLoss*Point, 0, White);
      if(modifyOk<0)
        Print("Error in OrderModify. Error code=", GetLastError());
    }
  }
