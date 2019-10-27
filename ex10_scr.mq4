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
    Print("証拠金通貨：",AccountInfoString(ACCOUNT_CURRENCY));
    Print("レバレッジ：",AccountInfoInteger(ACCOUNT_LEVERAGE));
    Print("残高：",AccountInfoDouble(ACCOUNT_BALANCE));
    Print("有効証拠金：",AccountInfoDouble(ACCOUNT_EQUITY));
    Print("必要証拠金：",AccountInfoDouble(ACCOUNT_MARGIN));
    Print("余剰証拠金：",AccountInfoDouble(ACCOUNT_MARGIN_FREE));
    Print("証拠金維持率：",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
  }
