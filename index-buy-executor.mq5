#include <Trade/Trade.mqh>
CTrade trade;
// variables
input static double LotSize = 0.8;
input static double  StopLoss = 25.0;
input static double TakeProfit = 50.0;
double PriceBuyLimit=0;
static int MaxTrades = 1;

// time variables
input static int CloseTimeHour = 14;
input static int CloseTimeMin = 15;
static int CloseTimeSec = 0;

input static int BuyTimeHour = 12;
input static int BuyTimeMin = 14;
static int BuyTimeSec = 59;

//Price storage
string AllowTrading = "on";
int TradeCount = 0;
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
     //PriceBuyLimit = Ask - 0.30;
     
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
      if(timeBuy == TimeLocal())
    //  if(Ask > fibPrice)
      {
         trade.Buy(LotSize, _Symbol, Ask, Ask - StopLoss, Ask + TakeProfit, NULL);       
         TradeCount = TradeCount + 1;
         Print("---counter is :---", TradeCount);  
      }
      
      CheckBuyBreakEvenStop(Ask);
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
      if (Ask > (PositionBuyPrice + 25.0))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + 2.0, PositionTakeProfit);
      }
      
      MoveSlToTwentyPoints(Ask);
   }
}

void MoveSlToTwentyPoints(double Ask)
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
      if (Ask > (PositionBuyPrice + 40.0))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + 27.0, PositionTakeProfit);
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