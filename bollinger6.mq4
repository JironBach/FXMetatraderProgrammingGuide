//+------------------------------------------------------------------+
//|                                                    Bolinger6.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//プログラムのパラメータ
input int BBPeriod=20;//ボリンジャーバンドの期間
input double BBDeviation=2;//標準偏差の倍率
extern double Lots=0.1;//売買ロット数
extern int StopLoss=8;//損切り
extern int TakeProfit=12;//利食い
extern int Slippage=3;
//プログラムの主要なグローバル変数
int Ticket=0;//チケット番号
double BBMain[6];//ボリンジャーバンド中心
double BBUpper[6];//ボリンジャーバンド上
double BBLower[6];//ボリンジャーバンド下
bool ret;//決済状況
//プログラムの動作に必要なグローバル変数
int pos=0;//ポジションの状態
int modifyOk=0;//StopLossとTakeProfitが設定できたかどうか受け取る変数
int AskTicket=0;//買いチケット
int BidsTicket=0;//売りチケット
//プログラムの動作に必要なパラメータ。externでもいいかも。
int OpenLimitAskNum=3;//チケット買い数上限
int OpenAskNum=4;//チケット買い回数
int OpenLimitBidsNum=3;//チケット売り数上限
int OpenBidsNum=4;//チケット売り回数
int SLLimitAskNum=4;//ロスカット買い上限
int SLAskNum=3;//ロスカット買い回数
int SLLimitBidsNum=4;//ロスカット売り上限
int SLBidsNum=3;//ロスカット売り回数
int LimitBuy=5;//買い決済上限
int BuyNum=6;//買い回数
int LimitSell=5;//売り決済上限
int SellNum=6;//売り回数

//ティック時実行関数
void OnTick()
  {
    if(Digits==3 || Digits==5){
      StopLoss *= 10;
      TakeProfit *= 10;
      Slippage *= 10;
    }
    //StopLossTakeProfit();

    int MaxBands=6;
    InitBands(MaxBands);
    //未決済ポジションの有無
    if(OrderSelect(AskTicket,SELECT_BY_TICKET)&&OrderCloseTime()==0){
      if(OrderType()==OP_BUY)pos=1;//買いポジション
    }
    if(OrderSelect(BidsTicket,SELECT_BY_TICKET)&&OrderCloseTime()==0){
      if(OrderType()==OP_SELL)pos=-1;//売りポジション
    }
    CheckForOpen(OpenLimitAskNum, OpenLimitBidsNum);
    RunStopLoss(SLLimitAskNum, SLLimitBidsNum);
    CheckForClose(LimitBuy, BuyNum, LimitSell, SellNum);
  }

//ボリンジャーバンド初期化
void InitBands(int MaxBands=6){
  for(int i=0; i<MaxBands; i++){
    BBMain[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,i+1);
    BBUpper[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,i+1);
    BBLower[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,i+1);
  }
}

//売買シグナルのチェック
void CheckForOpen(int LimitAskNum=3, int AskNum=4, int LimitBidsNum=3, int BidsNum=4)
{
  //--- go trading only for first tiks of new bar
  //if(Volume[0]>5) return;

  if(AskSignal(LimitAskNum, AskNum))//買いシグナル
  {
   //ポジションがなければ買い注文。利食い予定
   if(pos==0){
     AskTicket=OrderSend(_Symbol,OP_BUY,Lots,Ask,0,OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point, NULL, 0, 0, clrBlue);
   }
  }
  if(BidsSignal(LimitBidsNum, BidsNum))//売りシグナル
  {
   //ポジションがなければ売り注文。損切り予定
   if(pos==0){
     BidsTicket =    OrderSend(_Symbol,OP_SELL,Lots,Bid,0,OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point, NULL, 0, 0, clrRed);
   }
  }
}

//買いシグナル
bool AskSignal(int LimitAskNum, int AskNum=4){
  int signal=0;
  for(int i=0; i<AskNum; i++){
    if(Close[i+1]>BBMain[i]) signal++;
  }
  if(signal>=LimitAskNum){
    return true;
  }else{
    return false;
  }
}

//売りシグナル
bool BidsSignal(int LimitBidsNum, int BidsNum=4){
  int signal=0;
  for(int i=0; i<BidsNum; i++){
    if(Close[i+1]<BBMain[i]) signal++;
  }
  if(signal>=LimitBidsNum){
    return true;
  }else{
    return false;
  }
}

//決済のチェック
void CheckForClose(int CloseBuy=5, int CloseBuyNum=6, int CloseSell=5, int CloseSellNum=6){
  //--- go trading only for first tiks of new bar
  //if(Volume[0]>5) return;

  //買いポジションの決済シグナルがあれば決済注文
  if(pos>0 && CheckBuy(CloseBuy, BuyNum)){
    ret=OrderClose(AskTicket,OrderLots(),OrderClosePrice(),0, clrBlue);
    if(ret)pos=0;//決済成功すればポジションなしに
  }
  //売りポジションの決済シグナルがあれば決済注文
  if(pos<0 && CheckSell(CloseSell, SellNum)){
    ret=OrderClose(BidsTicket,OrderLots(),OrderClosePrice(),0, clrRed);
    if(ret)pos=0;//決済成功すればポジションなしに
  }
}

//買いシグナルのチェック
bool CheckBuy(int LimitSignal, int SignalNum=6){
  int signal=0;
  for(int i=0; i<SignalNum; i++){
    if(Close[i+1]>BBMain[i]) signal++;
  }
  if(signal>=LimitSignal){
    return true;
  }else{
    return false;
  }
}

//売りシグナルのチェック
bool CheckSell(int LimitSignal, int SignalNum=6){
  int signal=0;
  for(int i=0; i<SignalNum; i++){
    if(Close[i+1]<BBMain[i]) signal++;
  }
  if(signal>=LimitSignal){
    return true;
  }else{
    return false;
  }
}

//損切り
void RunStopLoss(int LimitAskNum=4, int AskNum=5, int LimitBidsNum=4, int BidsNum=5){
  if(pos==0 && CheckLossCut(LimitAskNum, LimitBidsNum)){
    if(AskSignal(LimitAskNum, AskNum)){
      ret=OrderModify(AskTicket, OrderOpenPrice(), OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point, OrderExpiration(), clrSkyBlue);
      if(ret)pos=0;//決済成功すればポジションなしに
    }
    if(BidsSignal(LimitBidsNum, BidsNum)){
      ret=OrderModify(BidsTicket, OrderOpenPrice(), OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point, OrderExpiration(), clrOrange);
      if(ret)pos=0;//決済成功すればポジションなしに
    }
  }
}

//損切りのチェック
bool CheckLossCut(int LimitAskNum, int LimitBidsNum){
  int AskSignal=0;
  for(int i=0; i<AskSignal; i++){
    if(Close[i+1]<BBMain[i]) AskSignal++;
  }
  int BidsSignal=0;
  for(int i=0; i<BidsSignal; i++){
    if(Close[i+1]>BBMain[i]) BidsSignal++;
  }
  if(AskSignal>=LimitAskNum || BidsSignal>=LimitBidsNum){
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
