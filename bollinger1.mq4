//+------------------------------------------------------------------+
//|                                                       Volinger1.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input int BBPeriod=20;//ボリンジャーバンドの期間
input double BBDeviation=2;//標準偏差の倍率
input double Lots=0.1;//売買ロット数
input int MinAccountEquity0=6000;//有効証拠金
input int MinAccountBalance=9000;//口座残高
extern int StopLoss=8;
extern int TakeProfit=12;
extern int Slippage=3;

int Ticket=0;//チケット番号
double BBMain[6];
double BBUpper[6];
double BBLower[6];
int MinAccountEquity[6];
bool ret;//決済状況

int pos=0;//ポジションの状態
int modifyOk=0;//StopLossとTakeProfitが設定できたかどうか受け取る変数
int AskTicket=0;//買いチケット
int BidsTicket=0;//売りチケット

//ティック時実行関数
void OnTick()
  {
    if(Digits==3 || Digits==5){
      StopLoss *= 10;
      TakeProfit *= 10;
      Slippage *= 10;
    }
    //StopLossTakeProfit();

    InitBands();
    CheckAccountEquity();
    //未決済ポジションの有無
    if(OrderSelect(AskTicket,SELECT_BY_TICKET)&&OrderCloseTime()==0){
      if(OrderType()==OP_BUY)pos=1;//買いポジション
    }
    if(OrderSelect(BidsTicket,SELECT_BY_TICKET)&&OrderCloseTime()==0){
      if(OrderType()==OP_SELL)pos=-1;//売りポジション
    }
    //WriteComment();

    Signal();

    //損切り
    if(pos==0 && CheckLossCut()){
      if(AskSignal())
        ret=OrderModify(AskTicket, OrderOpenPrice(), OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point, OrderExpiration(), clrBlue);
      if(BidsSignal())
        ret=OrderModify(BidsTicket, OrderOpenPrice(), OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point, OrderExpiration(), clrRed);
      if(ret)pos=0;//決済成功すればポジションなしに
    }

    //買いポジションの決済シグナルがあれば決済注文
    if(pos>0 && CheckBuy()){
      ret=OrderClose(AskTicket,OrderLots(),OrderClosePrice(),0);
      if(ret)pos=0;//決済成功すればポジションなしに
    }
    //売りポジションの決済シグナルがあれば決済注文
    if(pos<0 && CheckSell()){
      ret=OrderClose(BidsTicket,OrderLots(),OrderClosePrice(),0);
      if(ret)pos=0;//決済成功すればポジションなしに
    }
  }

void InitBands(){
  //１本前のボリンジャーバンド
  BBMain[0]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,1);
  BBUpper[0]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,1);
  BBLower[0]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,1);
  //２本前のボリンジャーバンド
  BBMain[1]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,2);
  BBUpper[1]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,2);
  BBLower[1]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,2);
  //3本前のボリンジャーバンド
  BBMain[2]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,3);
  BBUpper[2]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,3);
  BBLower[2]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,3);
  //4本前のボリンジャーバンド
  BBMain[3]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,4);
  BBUpper[3]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,4);
  BBLower[3]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,4);
  //5本前のボリンジャーバンド
  BBMain[4]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,5);
  BBUpper[4]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,5);
  BBLower[4]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,5);
  //6本前のボリンジャーバンド
  BBMain[5]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,6);
  BBUpper[5]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,6);
  BBLower[5]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,6);
}

bool CheckAccountEquity(){
  //１本前の有効証拠金
  MinAccountEquity[0]=MinAccountEquity0;
  //２本前の有効証拠金
  MinAccountEquity[1]=MinAccountEquity[0];
  //３本前の有効証拠金
  MinAccountEquity[2]=MinAccountEquity[1];
  //４本前の有効証拠金
  MinAccountEquity[3]=MinAccountEquity[2];
  //５本前の有効証拠金
  MinAccountEquity[4]=MinAccountEquity[3];
  //６本前の有効証拠金
  MinAccountEquity[5]=MinAccountEquity[4];
  int signal=0;
  if(MinAccountEquity[5]>MinAccountEquity[4]) signal++;
  if(MinAccountEquity[4]>MinAccountEquity[3]) signal++;
  if(MinAccountEquity[3]>MinAccountEquity[2]) signal++;
  if(MinAccountEquity[2]>MinAccountEquity[1]) signal++;
  if(signal>=3){
    return true;
  }else{
    return false;
  }
}

//シグナル
void Signal(){
  if(AskSignal())//買いシグナル
  {
    //ポジションがなければ買い注文
    //OrderSend(_Symbol,OP_BUY,Lots,Ask,0,0,0);
    //利食い予定
    //if(pos==0)// && AccountEquity()>MinAccountEquity0 && AccountBalance()>MinAccountBalance)
      AskTicket=OrderSend(_Symbol,OP_BUY,Lots,Ask,0,OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point);
    //modifyOk = OrderModify(OrderTicket(), 0, OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point, White);
  }
  if(BidsSignal())//売りシグナル
  {
    //ポジションがなければ売り注文
    //if(pos==0)Ticket=OrderSend(_Symbol,OP_SELL,Lots,Bid,0,0,0);
    //損切り予定
    //if(pos==0)// && AccountEquity()>MinAccountEquity0 && AccountBalance()>MinAccountBalance)
      BidsTicket =    OrderSend(_Symbol,OP_SELL,Lots,Bid,0,OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point);
    //modifyOk = OrderModify(OrderTicket(), 0, OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point, White);
  }
}
//買い
bool CheckBuy(){
  int signal=0;
  if(Close[3]>BBMain[2]) signal++;
  if(Close[2]>BBMain[1]) signal++;
  if(Close[1]>BBMain[0]) signal++;
  if(signal>=2){
    return true;
  }else{
    return false;
  }
}

//売り
bool CheckSell(){
  int signal=0;
  if(Close[3]<BBMain[2]) signal++;
  if(Close[2]<BBMain[1]) signal++;
  if(Close[1]<BBMain[0]) signal++;
  if(signal>=2){
    return true;
  }else{
    return false;
  }
}

//買いシグナル
bool AskSignal(){
  int signal=0;
  if(Close[4]>BBMain[3]) signal++;
  if(Close[3]>BBMain[2]) signal++;
  if(Close[2]>BBMain[1]) signal++;
  if(Close[1]>BBMain[0]) signal++;
  if(signal>=3){
    return true;
  }else{
    return false;
  }
}

//売りシグナル
bool BidsSignal(){
  int signal=0;
  if(Close[4]<BBMain[3]) signal++;
  if(Close[3]<BBMain[2]) signal++;
  if(Close[2]<BBMain[1]) signal++;
  if(Close[1]<BBMain[0]) signal++;
  if(signal>=3){
    return true;
  }else{
    return false;
  }
}

//損切り
bool CheckLossCut(){
  int AskSignal=0;
  if(Close[6]<BBMain[5]) AskSignal++;
  if(Close[5]<BBMain[4]) AskSignal++;
  if(Close[4]<BBMain[3]) AskSignal++;
  if(Close[3]<BBMain[2]) AskSignal++;
  if(Close[2]<BBMain[1]) AskSignal++;
  if(Close[1]<BBMain[0]) AskSignal++;

  int BidsSignal=0;
  if(Close[6]>BBMain[5]) BidsSignal++;
  if(Close[5]>BBMain[4]) BidsSignal++;
  if(Close[4]>BBMain[3]) BidsSignal++;
  if(Close[3]>BBMain[2]) BidsSignal++;
  if(Close[2]>BBMain[1]) BidsSignal++;
  if(Close[1]>BBMain[0]) BidsSignal++;

  if(AskSignal>=5 || BidsSignal>=5){
    return true;
  }else{
    return false;
  }
}

void WriteComment(){
  //指標値の表示
  Comment("pos=",pos,
    "\nClose[4]=",Close[4],"Close[3]=",Close[3],"Close[2]=",Close[2],"Close[1]=",Close[1],
    "\nBBMain4=",BBMain[3],"BBMain3=",BBMain[2],"BBMain2=",BBMain[1],"BBMain1=",BBMain[0]
  );
}

//損切り利食い関数
/*
void StopLossTakeProfit(){
  for(int i=0; i<OrdersTotal(); i++){
    if(OrderSelect(i, SELECT_BY_POS) == false) break;
    if(OrderSymbol() != Symbol()) continue;
    if(OrderType() == OP_BUY)
      modifyOk = OrderModify(OrderTicket(), 0, OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point, White);
    else if(OrderType() == OP_SELL)
      modifyOk = OrderModify(OrderTicket(), 0, OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point, White);
    if(modifyOk<0)
      Print("Error in OrderModify. Error code=", GetLastError());
  }
}
*/
