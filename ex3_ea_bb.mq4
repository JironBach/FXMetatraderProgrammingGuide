//+------------------------------------------------------------------+
//|                                                       ex3-ea.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int MomPeriod=10;//モメンタムの期間
input double MaxMom=10;//(モメンタム100)の最大値
input int SlowMAPeriod=40;//長期移動平均の期間
input double Lots=0.1;//売買ロット数
int Ticket=0;//チケット番号

//ティック時実行関数
void OnTick()
  {
  //１本前の移動平均
  double FastMA1=iCustom(_Symbol,0,"ex10_ind",MomPeriod,MaxMom,0,1);
  double SlowMA1=iMA(_Symbol,0,SlowMAPeriod,0,MODE_SMA,PRICE_CLOSE,1);
  //２本前の移動平均
  double FastMA2=iCustom(_Symbol,0,"ex10_ind",MomPeriod,MaxMom,0,2);
  double SlowMA2=iMA(_Symbol,0,SlowMAPeriod,0,MODE_SMA,PRICE_CLOSE,2);
  int pos=0;//ポジションの状態
  //未決済ポジションの有無
  if(OrderSelect(Ticket,SELECT_BY_TICKET)&&OrderCloseTime()==0){
    pos=1;//買いポジション
    if(OrderType()==OP_SELL)pos=1;//売りポジション
  }
  bool ret;//決済状況
  if(FastMA2<=SlowMA2&&FastMA1>SlowMA1)//買いシグナル
    {//売りポジションがあれば決済注文
      if(pos<0){
        ret=OrderClose(Ticket,OrderLots(),OrderClosePrice(),0);
        if(ret)pos=0;//決済成功すればポジションなしに
      }
      //ポジションがなければ買い注文
      if(pos==0)Ticket=OrderSend(_Symbol,OP_BUY,Lots,Ask,0,0,0);
    }
    if(FastMA2>=SlowMA2&&FastMA1<SlowMA1)//売りシグナル
      {//買いポジションがあれば決済注文
        if(pos>0){
          ret=OrderClose(Ticket,OrderLots(),OrderClosePrice(),0);
          if(ret)pos=0;//決済成功すればポジションなしに
        }
        //ポジションがなければ売り注文
        if(pos==0)Ticket=OrderSend(_Symbol,OP_SELL,Lots,Bid,0,0,0);
      }
  }
