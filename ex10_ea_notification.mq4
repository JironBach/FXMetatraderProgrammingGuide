//+------------------------------------------------------------------+
//|                                                       ex10-ea.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input int BBPeriod=20;//ボリンジャーバンドの期間
input double BBDeviation=2;//標準偏差の倍率
input double Lots=0.1;//売買ロット数
input int Slippage=3;//スリッページ
int Ticket=0;//チケット番号
int Magic=20151111;//マジックナンバー

//初期化関数
int OnInit(){
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS)&&OrderSymbol()==_Symbol&&OrderMagicNumber()==Magic)
    {
      Ticket=OrderTicket();
      break;
    }
  }
  return(INIT_SUCCEEDED);
}

//ティック時実行関数
void OnTick()
{
  //１本前のボリンジャーバンド
  double BBMain1=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,1);
  double BBUpper1=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,1);
  double BBLower1=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,1);
  //２本前のボリンジャーバンド
  double BBMain2=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,2);
  double BBUpper2=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,2);
  double BBLower2=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,2);
  int pos=0;//ポジションの状態
  //未決済ポジションの有無
  if(OrderSelect(Ticket,SELECT_BY_TICKET)&&OrderCloseTime()==0){
    if(OrderType()==OP_BUY)pos=1;//買いポジション
    if(OrderType()==OP_SELL)pos=-1;//売りポジション
  }
  bool ret;//決済状況
  //売りポジションの決済シグナルがあれば決済注文
  if(pos<0&&Close[2]>=BBMain2&&Close[1]<BBMain1){
    ret=OrderClose(Ticket,OrderLots(),OrderClosePrice(),Slippage,clrOrange);
    if(ret){
      Alert("Close",_Symbol,"at",OrderClosePrice());
      //SendNotification("Close"+_Symbol+"at"+OrderClosePrice());
      pos=0;//決済成功すればポジションなしに
    }
    //買いポジションの決済シグナルがあれば決済注文
    if(pos>0&&Close[2]<=BBMain2&&Close[1]>BBMain1){
      ret=OrderClose(Ticket,OrderLots(),OrderClosePrice(),Slippage,clrOrange);
      if(ret){
        Alert("Close",_Symbol,"at",OrderClosePrice());
        //SendNotification("Close"+_Symbol+"at"+OrderClosePrice());
        pos=0;//決済成功すればポジションなしに
      }
    }
    if(Close[2]>=BBLower2&&Close[1]<BBLower1)//買いシグナル
    {
      //ポジションがなければ買い注文
      if(pos==0){Ticket=OrderSend(_Symbol,OP_BUY,Lots,Ask,Slippage,0,0,NULL,Magic,0,clrBlue);
        if(Ticket>0){
          Alert("Buy",_Symbol,"at",Ask);
          //SendNotification("Buy"+_Symbol+"at"+Ask);
        }
      }
    }
    if(Close[2]<=BBUpper2&&Close[1]>BBUpper1)//売りシグナル
    {
      //ポジションがなければ売り注文
      if(pos==0){
        Ticket=OrderSend(_Symbol,OP_SELL,Lots,Bid,Slippage,0,0,NULL,Magic,0,clrRed);
        if(Ticket>0){
          Alert("Sell",_Symbol,"at",Bid);
          //SendNotification("Sell"+_Symbol+"at"+Bid);
        }
      }
    }
  }
}
