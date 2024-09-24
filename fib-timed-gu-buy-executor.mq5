#include <Trade/Trade.mqh>
CTrade trade;
// variables
input static double LotSize = 1.0;
input static double  StopLoss = 100.0;
input static double TakeProfit = 200.0;
static double PriceBuyLimit=0.6;
input static double MinPrice = 1.2;
// maxtrades works
input static int MaxTrades = 1;

// time variables
input static int CloseTimeHour = 15;
input static int CloseTimeMin = 15;
static int CloseTimeSec = 0;

input static int BuyTimeHour = 12;
input static int BuyTimeMin = 14;
static int BuyTimeSec = 59;

//Price storage
static int TradeCount = 0;
int ChangeCount = 0;
string AllowTrading = "on";
string direction = "buy";
string CloseTrade = "off";

int OnInit()
  {
//--- create timer
   //EventSetTimer(60);
   EventSetMillisecondTimer(500);
   
//---
   return(INIT_SUCCEEDED);
  }

void OnTimer()
  {      
      // Get the Ask price
     double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
     
    // PriceBuyLimit = Ask - 3*_Point;
     
      MqlDateTime structTime;
      TimeLocal(structTime);
      
      structTime.hour = BuyTimeHour;
      structTime.min = BuyTimeMin;
      structTime.sec = BuyTimeSec;
      
      datetime timeBuy = StructToTime(structTime);
          
          
      double high = iHigh(_Symbol, PERIOD_M15, 0);
      double low = iLow(_Symbol, PERIOD_M15, 0);
      double current = high - low;
      double fibPrice = low + current*0.75;
      
      if(Ask > fibPrice)
      {
         Print("Aks price is more than fib price");
      }
      else
      {
         Print("Fib price is more than Ask price");
      }
    
   Comment(Symbol(),",",EnumToString(Period()),"\n",
           "High: "  ,DoubleToString(high,Digits()),"\n",
           "Low: "   ,DoubleToString(low,Digits()),"\n",
           "current:" ,DoubleToString(current,Digits()), "\n",
           "fibPrice:" ,DoubleToString(fibPrice,Digits()), "\n"
           );    
     
     if(AllowTrading == "on" && direction == "buy")
     if(CloseTrade == "off")
      if(PositionsTotal() == 0)
      if(TradeCount < MaxTrades)
      if(Ask > fibPrice && Ask > MinPrice)
      if(timeBuy == TimeLocal())
      {
         // trade.BuyLimit(LotSize,PriceBuyLimit, _Symbol, PriceBuyLimit - StopLoss*_Point, PriceBuyLimit + TakeProfit*_Point, NULL);
          
          trade.Buy(LotSize, _Symbol, Ask, Ask - StopLoss*_Point, Ask + TakeProfit*_Point, NULL);
          TradeCount = TradeCount + 1;
        
      }
      CheckBuyBreakEvenStop(Ask);
      MoveSLToOneR(Ask);
      CloseTradeBeforeEvent();

  }
  

void CheckBuyBreakEvenStop(double Ask)
{
   // check all open position for the current symbol
   for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
   {
      // get the ticket number
      ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
      
      // get the position buy price
      double PositionBuyPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      // get the position stop loss
      double PositionStopLoss = PositionGetDouble(POSITION_SL);
      
      // get the position take profit
      double PositionTakeProfit = PositionGetDouble(POSITION_TP);
      
      // get the position Type
      double PositionType = PositionGetInteger(POSITION_TYPE);
      
      // get position symbol
      string symbol = PositionGetSymbol(i);
      
      if (_Symbol == symbol)
      if (PositionType == POSITION_TYPE_BUY)
      if (PositionStopLoss < PositionBuyPrice)
      if (Ask > (PositionBuyPrice + 100*_Point))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + 10*_Point, PositionTakeProfit);
         Print(POSITION_SL);
      }
      
      MoveSlToTwoHPoints(Ask);
   }
}

void MoveSlToTwoHPoints(double Ask)
{
   // check all open position for the current symbol
   for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
   {
      // get the ticket number
      ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
      
      // get the position buy price
      double PositionBuyPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      // get the position stop loss
      double PositionStopLoss = PositionGetDouble(POSITION_SL);
      
      // get the position take profit
      double PositionTakeProfit = PositionGetDouble(POSITION_TP);
      
      // get the position Type
      double PositionType = PositionGetInteger(POSITION_TYPE);
      
      // get position symbol
      string symbol = PositionGetSymbol(i);
      
      if (_Symbol == symbol)
      if (PositionType == POSITION_TYPE_BUY)
      if (PositionStopLoss > PositionBuyPrice)
      if(ChangeCount < 1)
      if (Ask > (PositionBuyPrice + 150*_Point))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + 60*_Point, PositionTakeProfit);
         ChangeCount = ChangeCount + 1;
         Print(POSITION_SL);
      }

   }
}

void MoveSLToOneR(double Ask)
{
      // check all open position for the current symbol
   for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
   {
      // get the ticket number
      ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
      
      // get the position buy price
      double PositionBuyPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      // get the position stop loss
      double PositionStopLoss = PositionGetDouble(POSITION_SL);
      
      // get the position take profit
      double PositionTakeProfit = PositionGetDouble(POSITION_TP);
      
      // get the position Type
      double PositionType = PositionGetInteger(POSITION_TYPE);
      
      // get position symbol
      string symbol = PositionGetSymbol(i);
      
      if (_Symbol == symbol)
      if (PositionType == POSITION_TYPE_BUY)
      if (PositionStopLoss > PositionBuyPrice)
      if(Ask > (PositionBuyPrice + 180*_Point))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + 110*_Point, PositionTakeProfit);
         Print(POSITION_SL);
      }
   }
}
void CloseTradeBeforeEvent()
{
      MqlDateTime structTime;
      TimeLocal(structTime);
      
      structTime.hour = CloseTimeHour;
      structTime.min = CloseTimeMin;
      structTime.sec = CloseTimeSec;
      
      datetime timeClose = StructToTime(structTime);
      
      if(TimeLocal() > timeClose)
      {
         // close all the positions
         for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
         {
            ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
            if(PositionSelectByTicket(PositionTicket))
            {
               if(trade.PositionClose(PositionTicket))
               {
                  Print(__FUNCTION__, "Pos #", PositionTicket, "was closed because of close time..");
               }
            }
         }
         
      }
      
      Comment("\n Server Time: ", TimeLocal(),
               "\n Close Time: ", timeClose);
}