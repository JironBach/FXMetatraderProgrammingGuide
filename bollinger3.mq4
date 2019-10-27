//+------------------------------------------------------------------+
//|                                                    Bolinger3.mq4 |
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
input int LimitBuyFlg=10;
input int LimitSellFlg=10;
int BuyFlg=0;
int SellFlg=0;

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
    CheckForOpen();
    RunStopLoss();
    CheckForClose();
  }

//ボリンジャーバンド初期化
void InitBands(){
  int MaxBands=6;
  for(int i=0; i<MaxBands; i++){
    BBMain[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_MAIN,i+1);
    BBUpper[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_UPPER,i+1);
    BBLower[i]=iBands(_Symbol,0,BBPeriod,BBDeviation,0,PRICE_CLOSE,MODE_LOWER,i+1);
  }
}

//有効証拠金初期化・チェック
bool CheckAccountEquity(){
  MinAccountEquity[0]=MinAccountEquity0;
  for(int i=0; i<5; i++){
    MinAccountEquity[i+1]=MinAccountEquity[i];
  }
  int signal=0;
  for(int i=1; i<5; i++){
    if(MinAccountEquity[i+1]>MinAccountEquity[i]) signal++;
  }
  if(signal>=3){
    return true;
  }else{
    return false;
  }
}

//売買シグナルのチェック
void CheckForOpen()
{
  //--- go trading only for first tiks of new bar
  //if(Volume[0]>1) return;

  if(AskSignal())//買いシグナル
  {
   //ポジションがなければ買い注文。利食い予定
   if(pos==0){// && AccountEquity()>MinAccountEquity0 && AccountBalance()>MinAccountBalance){
     AskTicket=OrderSend(_Symbol,OP_BUY,Lots,Ask,0,OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point, NULL, 0, 0, clrBlue);

   //BuyFlg++;
   }/*else{
     if(BuyFlg>=LimitBuyFlg)BuyFlg=0;
   }*/
  }
  if(BidsSignal())//売りシグナル
  {
   //ポジションがなければ売り注文。損切り予定
   if(pos==0){// && AccountEquity()>MinAccountEquity0 && AccountBalance()>MinAccountBalance){
     BidsTicket =    OrderSend(_Symbol,OP_SELL,Lots,Bid,0,OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point, NULL, 0, 0, clrRed);

     //SellFlg++;
   }/*else{
     if(SellFlg>LimitSellFlg)SellFlg=0;
   }*/
  }
}

//決済のチェック
void CheckForClose(){
  //--- go trading only for first tiks of new bar
  //if(Volume[0]>1) return;

  //買いポジションの決済シグナルがあれば決済注文
  if(pos>0 && CheckBuy()){
    ret=OrderClose(AskTicket,OrderLots(),OrderClosePrice(),0, clrBlue);
    if(ret)pos=0;//決済成功すればポジションなしに
  }
  //売りポジションの決済シグナルがあれば決済注文
  if(pos<0 && CheckSell()){
    ret=OrderClose(BidsTicket,OrderLots(),OrderClosePrice(),0, clrRed);
    if(ret)pos=0;//決済成功すればポジションなしに
  }
}

//買いシグナルのチェック
bool CheckBuy(){
  int signal=0;
  int MaxSignal=6;
  for(int i=0; i<MaxSignal; i++){
    if(Close[i+1]>BBMain[i]) signal++;
  }
  int LimitSignal=5;
  if(signal>=LimitSignal){
    return true;
  }else{
    return false;
  }
}

//売りシグナルのチェック
bool CheckSell(){
  int signal=0;
  int MaxSignal=6;
  for(int i=0; i<MaxSignal; i++){
    if(Close[i+1]<BBMain[i]) signal++;
  }
  int LimitSignal=5;
  if(signal>=LimitSignal){
    return true;
  }else{
    return false;
  }
}

//損切り
void RunStopLoss(){
  if(pos==0 && CheckLossCut()){
    if(AskSignal()){
      ret=OrderModify(AskTicket, OrderOpenPrice(), OrderOpenPrice()-StopLoss*Point, OrderOpenPrice()+TakeProfit*Point, OrderExpiration(), clrSkyBlue);
      if(ret)pos=0;//決済成功すればポジションなしに
    }
    if(BidsSignal()){
      ret=OrderModify(BidsTicket, OrderOpenPrice(), OrderOpenPrice()+StopLoss*Point, OrderOpenPrice()-TakeProfit*Point, OrderExpiration(), clrOrange);
      if(ret)pos=0;//決済成功すればポジションなしに
    }
  }
}

//損切りのチェック
bool CheckLossCut(){
  int AskSignal=0;
  int LimitAskNum=4;
  for(int i=0; i<LimitAskNum; i++){
    if(Close[i+1]<BBMain[i]) AskSignal++;
  }
  int BidsSignal=0;
  int LimitBidsNum=4;
  for(int i=0; i<LimitBidsNum; i++){
    if(Close[i+1]>BBMain[i]) BidsSignal++;
  }
  if(AskSignal>=2 || BidsSignal>=2){
    return true;
  }else{
    return false;
  }
}

//買いシグナル
bool AskSignal(){
  int signal=0;
  int AskNum=4;
  for(int i=0; i<AskNum; i++){
    if(Close[i+1]>BBMain[i]) signal++;
  }
  int LimitAskNum=3;
  if(signal>=LimitAskNum){
    return true;
  }else{
    return false;
  }
}

//売りシグナル
bool BidsSignal(){
  int signal=0;
  int BidsNum=4;
  for(int i=0; i<BidsNum; i++){
    if(Close[i+1]<BBMain[i]) signal++;
  }
  int LimitBidsNum=3;
  if(signal>=LimitBidsNum){
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
