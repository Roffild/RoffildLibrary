/*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* https://github.com/Roffild/RoffildLibrary
*/
#include "Statistic.mqh"

/**
 * The object for COrderData.
 */
class COrderDataObject
{
public:
   COrderDataObject *prev, *next;
   string order_symbol;
   double order_point;
   ENUM_TIMEFRAMES order_period;
   int order_variant;
   bool order_sell;
   double order_openprice;
   datetime order_opentime;
   datetime order_opentimebar;
   double order_closeprice;
   datetime order_closetime;
   int order_takeprofit;
   int order_stoploss;
   int order_profit;
   int order_bars;
   int order_maxbars;
   int order_count;

   COrderDataObject(string symbol, ENUM_TIMEFRAMES period,
      int variant, bool sell, double openprice, datetime opentime,
      int takeprofit, int stoploss, int maxbars)
   {
      prev = NULL;
      next = NULL;
      order_symbol = symbol == "" ? _Symbol : symbol;
      order_point = SymbolInfoDouble(order_symbol, SYMBOL_POINT);
      order_period = period;
      order_variant = variant;
      order_sell = sell;
      order_openprice = openprice;
      order_opentime = opentime;
      order_opentimebar = opentime - (opentime % PeriodSeconds(period));
      order_closeprice = NULL;
      order_closetime = NULL;
      order_takeprofit = takeprofit;
      order_stoploss = stoploss;
      order_profit = NULL;
      order_bars = NULL;
      order_maxbars = maxbars;
      order_count = 1;
   }

   virtual bool compare(COrderDataObject &order)
   {
      return bool(
         order_symbol == order.order_symbol &&
         order_period == order.order_period &&
         order_variant == order.order_variant &&
         order_sell == order.order_sell &&
         order_opentimebar == order.order_opentimebar &&
         order_opentime == order.order_opentime
      );
   }
};

/**
 * Simulation of orders with attached data for research.
 */
class COrderData
{
protected:
   int lastday;
   MqlRates rt[], rtmin[];

   virtual bool deleteOrder(COrderDataObject *order, const bool show, const bool stats)
   {
      if (show) {
         string objname = statistic.name + "_" + string(order.order_opentime) + "_" +
            string(GetMicrosecondCount());
         const color clr = order.order_sell ? clrSalmon : clrCornflowerBlue;
         ObjectCreate(0, objname + "start", OBJ_ARROW, 0, order.order_opentime, order.order_openprice);
         ObjectSetInteger(0, objname + "start", OBJPROP_ARROWCODE, 161);
         ObjectSetInteger(0, objname + "start", OBJPROP_ANCHOR,
            order.order_sell ? ANCHOR_BOTTOM : ANCHOR_TOP);
         ObjectSetInteger(0, objname + "start", OBJPROP_COLOR, clr);
         ObjectCreate(0, objname, OBJ_ARROWED_LINE, 0, order.order_opentime,
            order.order_openprice, order.order_closetime, order.order_closeprice);
         ObjectSetInteger(0, objname, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, objname, OBJPROP_COLOR, clr);
      }
      if (stats) {
         statistic.plus((ulong(order.order_variant + INT_MAX) << 16) |
            (ulong(order.order_sell) << 8) | ulong(order.order_profit > 0));
      }
      return true;
   }

public:
   bool enable;
   bool visual;
   COrderDataObject *orders_first, *orders_last;
   CStatistic statistic;

   COrderData()
   {
      enable = true;
      visual = false;
      ZeroMemory(lastday);
      statistic.name = "OrderData";
   }

   ~COrderData()
   {
      tick(true);
      COrderDataObject *order = orders_first, *next = NULL;
      while (CheckPointer(order) != POINTER_INVALID) {
         next = order.next;
         delete order;
         order = next;
      }
   }

   /**
    * Adds a processing order.
    * For best performance, you need to use one copy of the class for one pair (Symbol + Period).
    */
   bool order(string symbol, ENUM_TIMEFRAMES period,
      int variant, bool sell, double openprice, datetime opentime,
      int takeprofit, int stoploss, int maxbars = 0, int deviation = 5, COrderDataObject *order = NULL)
   {
      if (enable == false) {
         if (CheckPointer(order) != POINTER_INVALID) {
            delete order;
         }
         return true;
      }
      const double real = SymbolInfoDouble(symbol, sell ? SYMBOL_BID : SYMBOL_ASK);
      if (MathAbs(openprice - real) > (deviation * SymbolInfoDouble(symbol, SYMBOL_POINT))) {
         if (CheckPointer(order) != POINTER_INVALID) {
            delete order;
         }
         return false;
      }
      if (CheckPointer(order) == POINTER_INVALID) {
         order = new COrderDataObject(symbol, period, variant, sell,
            real, opentime, takeprofit, stoploss, maxbars);
      } else {
         order.order_openprice = real;
      }
      if (CheckPointer(orders_last) != POINTER_INVALID) {
         /*COrderDataObject *curr = orders_last;
         int deep = 5;
         while (deep > 0 && CheckPointer(curr) != POINTER_INVALID) {
            if (curr.compare(order)) {
               curr.order_count++;
               delete order;
               return true;
            }
            curr = curr.prev;
            deep--;
         }*/
         orders_last.next = order;
      } else {
         orders_first = order;
      }
      order.prev = orders_last;
      order.next = NULL;
      orders_last = order;
      statistic.plus((ulong(variant + INT_MAX) << 16) | (ulong(false) << 8) | ulong(true),
         "Variant=" + string(variant) + " Buy Profit", 0);
      statistic.plus((ulong(variant + INT_MAX) << 16) | (ulong(false) << 8) | ulong(false),
         "Variant=" + string(variant) + " Buy Loss", 0);
      statistic.plus((ulong(variant + INT_MAX) << 16) | (ulong(true) << 8) | ulong(true),
         "Variant=" + string(variant) + " Sell Profit", 0);
      statistic.plus((ulong(variant + INT_MAX) << 16) | (ulong(true) << 8) | ulong(false),
         "Variant=" + string(variant) + " Sell Loss", 0);
      return true;
   }

   /**
    * Processes the added orders at the beginning of each day.
    * @param now start processing immediately
    */
   void tick(bool now = false)
   {
      if (enable == false) {
         return;
      }
      MqlDateTime day;
      TimeCurrent(day);
      if (now == false && lastday == day.day) {
         return;
      }
      lastday = day.day;
      COrderDataObject *order = orders_first, *next = NULL;
      double profit = 0;
      int bar = 0;
      int rtbars = 0, rtminbars = 0;
      if (ArraySize(rtmin) < 1) {
         ArrayResize(rtmin, 1);
      }
      rtmin[0].time = D'2999.01.01';
      while (CheckPointer(order) != POINTER_INVALID) {
         next = order.next;
         if (order.order_opentimebar < rtmin[0].time) {
            /// BUG: не учитываются разные символы, периоды
            rtbars = CopyRates(order.order_symbol, order.order_period, order.order_opentimebar,
               TimeCurrent(), rt);
            rtminbars = CopyRates(order.order_symbol, PERIOD_M1, order.order_opentimebar,
               TimeCurrent(), rtmin);
         }
         bar = findBar(order, profit, order.order_period, rt, rtbars);
         if (bar > -1) {
            order.order_bars = bar;
            bar = findBar(order, profit, PERIOD_M1, rtmin, rtminbars);
         }
         if (bar > -1) {
            order.order_closeprice = order.order_sell ? order.order_openprice - profit * order.order_point :
                order.order_openprice + profit * order.order_point;
            order.order_closetime = rtmin[bar].time;
            order.order_profit = int(profit);
            if (CheckPointer(order.prev) != POINTER_INVALID) {
               order.prev.next = order.next;
            }
            if (CheckPointer(order.next) != POINTER_INVALID) {
               order.next.prev = order.prev;
            }
            if (order == orders_first) {
               orders_first = order.next;
            }
            if (order == orders_last) {
               orders_last = order.prev;
            }
            if (deleteOrder(order, visual, true)) {
               delete order;
            }
         }
         order = next;
      }
   }

   /**
    * @param[in] order
    * @param[out] profit +take or -stop points
    * @param[in] period
    * @param[in] rates
    * @param[in] bars
    * @return -1 or number of bar in the rates[]
    */
   int findBar(COrderDataObject *order, double &profit, ENUM_TIMEFRAMES period,
      MqlRates &rates[], const int bars)
   {
      ArraySetAsSeries(rates, false);
      const int seconds = PeriodSeconds(period);
      const datetime outtime = order.order_maxbars > 0 ?
         (order.order_opentime + PeriodSeconds(order.order_period) * order.order_maxbars) -
            (order.order_opentime % seconds) : D'2999.01.01';
      int b = 0;
      for (; b < bars; b++) {
         if (rates[b].time >= order.order_opentimebar) {
            break;
         }
      }
      for (; b < bars; b++) {
         if (order.order_sell) {
            if ((order.order_openprice - order.order_takeprofit * order.order_point) > rates[b].low) {
               profit = order.order_takeprofit;
               return b;
            }
            if ((order.order_openprice + order.order_stoploss * order.order_point) < rates[b].high) {
               profit = -1 * order.order_stoploss;
               return b;
            }
            if (rates[b].time >= outtime) {
               profit = (order.order_openprice - rates[b].open) / order.order_point;
               return b;
            }
         } else {
            if ((order.order_openprice + order.order_takeprofit * order.order_point) < rates[b].high) {
               profit = order.order_takeprofit;
               return b;
            }
            if ((order.order_openprice - order.order_stoploss * order.order_point) > rates[b].low) {
               profit = -1 * order.order_stoploss;
               return b;
            }
            if (rates[b].time >= outtime) {
               profit = (rates[b].open - order.order_openprice) / order.order_point;
               return b;
            }
         }
      }
      return -1;
   }
};
