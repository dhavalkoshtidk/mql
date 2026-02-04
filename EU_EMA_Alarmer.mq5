#include<Trade/Trade.mqh>

CTrade trade;
/*
input static double  StopLoss = 200;
input static double TakeProfit = 400;
*/
int fastEMA = 18;
int slowEMA = 50;
int shift = 0;

int buyCount = 0;
int sellCount = 0;

MqlRates bar[];
string signal = "";
/*
int TradeCountBuy = 0;
int TradeCountSell = 0;
int BuySignalCount = 0; 
int SellSignalCount = 0; 
*/


void OnTick()
  {
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

   
   MqlRates PriceInfo[];
   
   ArraySetAsSeries(PriceInfo, true);
   
   CopyRates(_Symbol, _Period, 0, 10, PriceInfo);
   
   string signal = "";
   
   double EMA18ARRAY[], EMA50ARRAY[], ADXARRAY[];
   
   int EMA18Definition = iMA(_Symbol, _Period, 18, 0, MODE_EMA, PRICE_CLOSE);
   
   int EMA50Definition = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   int ADXDifinition = iADX(_Symbol, _Period, 14);
   
   ArraySetAsSeries(EMA18ARRAY, true);
   ArraySetAsSeries(EMA50ARRAY, true);
   ArraySetAsSeries(ADXARRAY, true);
   
   CopyBuffer(EMA18Definition, 0, 0, 10, EMA18ARRAY);
   CopyBuffer(EMA50Definition, 0, 0, 10, EMA50ARRAY);
   CopyBuffer(ADXDifinition, 0, 0, 14, ADXARRAY);
   
   double ADXValue = NormalizeDouble(ADXARRAY[0], 2); 
   
  /* int fastCurr = iMA(_Symbol, _Period, 18, shift, MODE_EMA, PRICE_CLOSE);
   
   int slowCurr = iMA(_Symbol, _Period, 50, shift, MODE_EMA, PRICE_CLOSE);
   
   int fastPrev = iMA(_Symbol, _Period, 18, shift + 1, MODE_EMA, PRICE_CLOSE);
   
   int slowPrev = iMA(_Symbol, _Period, 50, shift + 1, MODE_EMA, PRICE_CLOSE);*/
   
   //Print("CurrentFastEMA" , EMA18ARRAY[1]);
   Print("Current ADX ", ADXValue);
   Print("EA is running, Please be patient!");
   
   if (EMA18ARRAY[0] > EMA50ARRAY[0] && EMA18ARRAY[1] < EMA50ARRAY[1] )
   if(buyCount < 10)
   {
      signal = "buy";
      buyCount ++;
      Print("buyCount is ", buyCount);
      
      Alert("Bullish EMA crossover!");
      SendNotification("Bullish EMA crossover!");
      Print("Bullish EMA crossover at ", TimeToString(TimeCurrent()));
   }
   
   if ( EMA18ARRAY[0] < EMA50ARRAY[0] && EMA18ARRAY[1] > EMA50ARRAY[1])
   if(sellCount <10)
   {
      signal = "sell";
      sellCount ++;
      Print("sellCount is ", sellCount);
      
      Alert("Bearish EMA crossover!");
      SendNotification("Bearish EMA crossover!");
      Print("Bearish EMA crossover at ", TimeToString(TimeCurrent()));
   }
  /* if (signal == "buy")
   {
     Alert("Bullish EMA crossover!");
     Print("Bullish EMA crossover at ", TimeToString(TimeCurrent()));
   } 
   if ( signal == "sell")  
   {
      Alert("Bearish EMA crossover!");
      Print("Bearish EMA crossover at ", TimeToString(TimeCurrent()));
   }*/
}

