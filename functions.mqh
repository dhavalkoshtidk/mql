/*#include <Trade/Trade.mqh>
CTrade trade;*/

int ChangeCount = 0;
int ChangeSellCount = 0;
int SlToRCount = 0;

double ProfitablePips = 0;
double ProfitableSellPips = 0;
double ExtraPips = 0;

//SLoss must be in decimal (0.00250) format
double CalLotSize(double Risk, double SLoss)
{
   double TickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double TickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double LotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(TickSize == 0 || TickValue == 0 || LotStep == 0) 
   {  
      Print(__FUNCTION__, " > Lotsize cannot be calculated!");
      return 0;
   }
      
   double MoneyLotStep = (SLoss/TickSize) * TickValue * LotStep;
   
   if(MoneyLotStep == 0)
   {
      return 0;
   }
   
   double lots = NormalizeDouble((Risk / MoneyLotStep) * LotStep, 2);
    
   return lots;
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
      
      ProfitablePips = NormalizeDouble((PositionTakeProfit - PositionBuyPrice)/_Point, _Digits);
      
      double BEPips = MathRound(0.5*ProfitablePips);
      ExtraPips = MathRound(0.05*ProfitablePips);
      

      
      
      if (_Symbol == symbol)
      if (PositionType == POSITION_TYPE_BUY)
      if (PositionStopLoss < PositionBuyPrice)
      if (Ask > (PositionBuyPrice + BEPips*_Point))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + ExtraPips*_Point, PositionTakeProfit);
         Print(POSITION_SL);
         SendNotification("SL at Breakeven!");
      }
      
      
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
      
      double HRProfitPips = MathRound(0.75*ProfitablePips);
      double HRProfit = MathRound(0.3*ProfitablePips);
      
      Print("ProfitablePips is ", ProfitablePips);
      Print("HRProfitPips is ", HRProfitPips);
      Print("HRProfit is ", HRProfit);
      
      if (_Symbol == symbol)
      //if (PositionType == POSITION_TYPE_BUY)
     // if (PositionStopLoss > PositionBuyPrice)
      if(ChangeCount < 1)
      if (Ask > (PositionBuyPrice + HRProfitPips*_Point))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + HRProfit*_Point, PositionTakeProfit);
         ChangeCount = ChangeCount + 1;
         Print(POSITION_SL);
         SendNotification("SL at half R!");
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
      
      double RProfitPips = MathRound(0.85*ProfitablePips);
      double RProfit = MathRound(0.55*ProfitablePips);
      
      if (_Symbol == symbol)
      if (PositionType == POSITION_TYPE_BUY)
      if (SlToRCount < 1)
      if (PositionStopLoss > PositionBuyPrice)
      if(Ask > (PositionBuyPrice + RProfitPips*_Point))
      {
         trade.PositionModify(PositionTicket, PositionBuyPrice + RProfit*_Point, PositionTakeProfit);
         Print(POSITION_SL);
         SlToRCount = SlToRCount + 1;
         SendNotification("SL at one R!");
      }
   }
}

void CloseTradeBeforeEvent(int CloseTimeHour, int CloseTimeMin)
{
      MqlDateTime structTime;
      TimeLocal(structTime);
      
      structTime.hour = CloseTimeHour;
      structTime.min = CloseTimeMin;
      structTime.sec = 59;
      
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
                  SendNotification("Position was closed because of close time..");
               }
            }
         }
         
      }

}

//-----------------------------------------------------------------------------------------------------------------------------//

void CheckSellBreakEvenStop(double Bid)
{
   // Check all open positions for the current symbol
   for(int i=PositionsTotal()-1; i>=0; i--)  // count all positions
   {
      // get the ticket number
      ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
      
      // get the position buy price
      double PositionSellPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      // get the position stop loss
      double PositionStopLoss = PositionGetDouble(POSITION_SL);
      
      // get the position take profit
      double PositionTakeProfit = PositionGetDouble(POSITION_TP);
      
      // get the position Type
      double PositionType = PositionGetInteger(POSITION_TYPE);
      
      // get position symbol
      string symbol = PositionGetSymbol(i);
      
      ProfitableSellPips = NormalizeDouble((PositionSellPrice - PositionTakeProfit)/_Point, _Digits);
      
      double BEPips = MathRound(0.5*ProfitableSellPips);
      ExtraPips = MathRound(0.05*ProfitableSellPips);
      
      
      // if chart symbol equals position symbol
      if(_Symbol == symbol)
      if(PositionType == POSITION_TYPE_SELL)
      if(PositionStopLoss > PositionSellPrice)
      if(Bid < (PositionSellPrice - BEPips*_Point))
      {
         // Modify the stop loss
         trade.PositionModify(PositionTicket, PositionSellPrice - ExtraPips*_Point, PositionTakeProfit);
         SendNotification("SL at Breakeven!");
      }
      
      
   }
 } 
 
 void MoveSellSlToTwoHPoints(double Bid)
{
   // check all open position for the current symbol
   for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
   {
      // get the ticket number
      ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
      
      // get the position buy price
      double PositionSellPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      // get the position stop loss
      double PositionStopLoss = PositionGetDouble(POSITION_SL);
      
      // get the position take profit
      double PositionTakeProfit = PositionGetDouble(POSITION_TP);
      
      // get the position Type
      double PositionType = PositionGetInteger(POSITION_TYPE);
      
      // get position symbol
      string symbol = PositionGetSymbol(i);
      
      double HRProfitPips = MathRound(0.75*ProfitableSellPips);
      double HRProfit = MathRound(0.3*ProfitableSellPips);
      
      if (_Symbol == symbol)
      if (PositionType == POSITION_TYPE_SELL)
      if (PositionStopLoss < PositionSellPrice)
      if(ChangeSellCount < 1)
      if (Bid < (PositionSellPrice - HRProfitPips*_Point))
      {
         trade.PositionModify(PositionTicket, PositionSellPrice - HRProfit*_Point, PositionTakeProfit);
         ChangeSellCount = ChangeSellCount + 1;
         Print(POSITION_SL);
         SendNotification("SL at half R!");
      }
   }
}
 
void MoveSellSLToOneR(double Bid)
{
   // check all open position for the current symbol
   for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
   {
      // get the ticket number
      ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
      
      // get the position buy price
      double PositionSellPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      
      // get the position stop loss
      double PositionStopLoss = PositionGetDouble(POSITION_SL);
      
      // get the position take profit
      double PositionTakeProfit = PositionGetDouble(POSITION_TP);
      
      // get the position Type
      double PositionType = PositionGetInteger(POSITION_TYPE);
      
      // get position symbol
      string symbol = PositionGetSymbol(i);
      
      double RProfitPips = MathRound(0.85*ProfitableSellPips);
      double RProfit = MathRound(0.55*ProfitableSellPips);
      
      if (_Symbol == symbol)
      if (PositionType == POSITION_TYPE_SELL)
      if (PositionStopLoss < PositionSellPrice)
      if (SlToRCount < 1)
      if (Bid < (PositionSellPrice - RProfitPips*_Point))
      {
         trade.PositionModify(PositionTicket, PositionSellPrice - RProfit*_Point, PositionTakeProfit);
         Print(POSITION_SL);
         SlToRCount = SlToRCount + 1;
         SendNotification("SL at one R!");
      }
   }
} 

void CheckSLHit(double price)
{
   for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
   {
      double PositionStopLoss = PositionGetDouble(POSITION_SL);
      if(price == PositionStopLoss)
      {
         Print("Stoploss has been hit!");
         SendNotification("Stoploss has been hit!");
      }
   }
}
 
