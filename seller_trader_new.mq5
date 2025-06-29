#include<Trade/Trade.mqh>
#include <Trader/functions.mqh>

CTrade trade;

input static int BuyingTimeHour = 13;
input static int BuyingTimeMin = 14;
static int TimeSec = 59;

input static int closingTradingHour = 14;
input static int closingTradingMinutes = 14;

double SlPrice = 0;
double SL = 0;
double RiskValue = 300;
double ProfitPips = 0;
double SlPips = 0;
double BePips = 0;
double HRPips = 0;
double RPips = 0;

double HRProfitPips = 0;
double RProfitPips = 0;
double Lots = 0;

static int MaxTrades = 1;
static int TradeCount = 0;

MqlRates bar[];

int OnInit()
  {
//--- create timer
   //EventSetTimer(60);
   EventSetMillisecondTimer(500);
   ArraySetAsSeries(bar, true);
//---
   return(INIT_SUCCEEDED);
  }
  
void OnTimer()
  {
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
  // Print("Ask price is : ", Ask);
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 20, bar);
      
   //Print("Previous candle low - ", bar[1].low);
   
   MqlRates PriceInfo[];
   
   ArraySetAsSeries(PriceInfo, true);
   
   CopyRates(_Symbol, _Period, 0, 10, PriceInfo);
   
   double currCandleHigh = NormalizeDouble(PriceInfo[0].high, _Digits);
   double prevCandleHigh = NormalizeDouble(bar[1].high, _Digits);
   
   double MaxPrice = fmax(currCandleHigh, prevCandleHigh);
   
   double ComparePrice = NormalizeDouble((MaxPrice - Bid), _Digits);
   
   Print("Compare price is : ", ComparePrice);
   if (ComparePrice <= 90*_Point)
   {
      SlPrice = Bid + 100*_Point;
      SL = 0.00100;
      ProfitPips = 155;
      BePips = 100;
      HRPips = 150;
      RPips = 170;
      HRProfitPips = 60;
      RProfitPips = BePips;
     // Print("SL is ", SlPrice);
   }else
   {
      SlPrice = NormalizeDouble(MaxPrice, _Digits) + 10*_Point;
      Print("SlPrice is ", SlPrice);
      SL = NormalizeDouble(SlPrice - Bid, _Digits);
      Print("SL is ", SL);
      ProfitPips = MathRound(1.55 * SL / _Point);
      BePips = MathRound(Bid - 0.5*ProfitPips);
      HRPips = MathRound(Bid - 0.75*ProfitPips);
      RPips = MathRound(Bid - 0.85*ProfitPips);
      HRProfitPips = MathRound(Bid - 0.30*ProfitPips);
      RProfitPips = BePips;
   }
   
   MqlDateTime structTime;
   TimeLocal(structTime);
   
   structTime.hour = BuyingTimeHour;
   structTime.min = BuyingTimeMin;
   structTime.sec = TimeSec;
   
   datetime timeBuy = StructToTime(structTime);
   
   //ObjectDelete(0,"SL Line");
     
   Lots = CalLotSize(RiskValue, SL);
   //Print("Lotsize is : ", Lots);
   SlPips = MathRound(SL / _Point);
   Print("SlPips is : ", SlPips);
   Print("Profitpips is ", ProfitPips);
   /*Print("BEPips is ", BePips);
   Print("HRPips is : ", HRPips);
   Print("RPips is : ", RPips);
   Print("HRProfit is : ", HRProfitPips);*/
   
   if(PositionsTotal() == 0)
   if(TradeCount < MaxTrades)
   if(timeBuy == TimeLocal())
   {
      //ObjectCreate(0,"SL Line",OBJ_HLINE,0,0, SlPrice);
      trade.Sell(Lots, _Symbol, Bid, Bid + SlPips*_Point, Bid - ProfitPips*_Point, NULL);
      TradeCount = TradeCount + 1;
   }
      CheckSellBreakEvenStop(Bid);
     // MoveSellSlToTwoHPoints(Bid);
     // MoveSellSLToOneR(Bid);
      CloseTradeBeforeEvent(closingTradingHour, closingTradingMinutes);
}
