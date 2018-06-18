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
#include "SqlFile.mqh"
#include "OrderData.mqh"

class COrderSqlObject : public COrderDataObject
{
protected:
   bool obj_delete;

public:
   CSqlObject *order_sqlobject;

   COrderSqlObject(string symbol, ENUM_TIMEFRAMES period,
      int variant, bool sell, double openprice, datetime opentime,
      int takeprofit, int stoploss, int maxbars, CSqlObject *sqlobject, bool sqlobject_delete)
      : COrderDataObject(symbol, period, variant, sell, openprice, opentime,
         takeprofit, stoploss, maxbars)
   {
      order_sqlobject = sqlobject;
      obj_delete = sqlobject_delete;
   }

   ~COrderSqlObject()
   {
      if (obj_delete) {
         delete order_sqlobject;
      }
   }
};

class COrderSqlObjectCast : public CSqlObject
{
public:
   COrderSqlObject *object;

   COrderSqlObjectCast(COrderSqlObject *_object)
   {
      object = _object;
   }

   virtual bool toSqlTable(string &types[][2], string &primaryKeys[])
   {
      string tp[][2] = {
         //{"order_id", "int UNSIGNED NOT NULL AUTO_INCREMENT"},
         {"order_symbol", "text"},
         {"order_point", "decimal(64,8)"},
         {"order_period", "text"},
         {"order_variant", "int"},
         {"order_sell", "bool"},
         {"order_openprice", "decimal(64,8)"},
         {"order_opentime", "datetime"},
         {"order_opentimebar", "datetime"},
         {"order_closeprice", "decimal(64,8)"},
         {"order_closetime", "datetime"},
         {"order_takeprofit", "int"},
         {"order_stoploss", "int"},
         {"order_profit", "int"},
         {"order_bars", "int"},
         {"order_maxbars", "int"},
         {"order_count", "int"}
      };
      ArrayResize(primaryKeys, 0);
      string tp2[][2], pk[];
      object.order_sqlobject.toSqlTable(tp2, pk);
      ArrayResize(types, ArrayRange(tp, 0) + ArrayRange(tp2, 0));
      ArrayCopy(types, tp);
      ArrayCopy(types, tp2, ArraySize(tp));
      return true;
   }

   virtual bool toSqlRecord(string &list[][2])
   {
      string lst[][2];
      ArrayResize(lst, 25);
      int col = 0;
      lst[col][0] = "order_symbol";
      lst[col][1] = object.order_symbol;
      col++;
      lst[col][0] = "order_point";
      lst[col][1] = DoubleToString(object.order_point);
      col++;
      lst[col][0] = "order_period";
      lst[col][1] = EnumToString(object.order_period == PERIOD_CURRENT ? Period() : object.order_period);
      col++;
      lst[col][0] = "order_variant";
      lst[col][1] = string(object.order_variant);
      col++;
      lst[col][0] = "order_sell";
      lst[col][1] = string(object.order_sell);
      col++;
      lst[col][0] = "order_openprice";
      lst[col][1] = DoubleToString(object.order_openprice);
      col++;
      lst[col][0] = "order_opentime";
      lst[col][1] = string(object.order_opentime);
      col++;
      lst[col][0] = "order_opentimebar";
      lst[col][1] = string(object.order_opentimebar);
      col++;
      lst[col][0] = "order_closeprice";
      lst[col][1] = DoubleToString(object.order_closeprice);
      col++;
      lst[col][0] = "order_closetime";
      lst[col][1] = string(object.order_closetime);
      col++;
      lst[col][0] = "order_takeprofit";
      lst[col][1] = string(object.order_takeprofit);
      col++;
      lst[col][0] = "order_stoploss";
      lst[col][1] = string(object.order_stoploss);
      col++;
      lst[col][0] = "order_profit";
      lst[col][1] = string(object.order_profit);
      col++;
      lst[col][0] = "order_bars";
      lst[col][1] = string(object.order_bars);
      col++;
      lst[col][0] = "order_maxbars";
      lst[col][1] = string(object.order_maxbars);
      col++;
      lst[col][0] = "order_count";
      lst[col][1] = string(object.order_count);
      ArrayResize(lst, col + 1);
      string lst2[][2];
      object.order_sqlobject.toSqlRecord(lst2);
      ArrayResize(list, ArrayRange(lst, 0) + ArrayRange(lst2, 0));
      ArrayCopy(list, lst);
      ArrayCopy(list, lst2, ArraySize(lst));
      return true;
   }
};

/**
 * Record data of simulated orders (COrderData) in a file format MySQL.
 */
class COrderSql : public COrderData
{
protected:
   bool firstrecord;

   virtual bool deleteOrder(COrderDataObject *order, const bool show, const bool stats)
   {
      COrderData::deleteOrder(order, show, stats);
      COrderSqlObjectCast cast(order);
      sqlfile.insert(cast);
      return true;
   }

public:
   CSqlFile sqlfile;

   COrderSql() : COrderData()
   {
      ZeroMemory(firstrecord);
      statistic.name = "OrderSQL";
   }

   ~COrderSql()
   {
      tick(true);
   }

   /**
    * Adds a processing order.
    * For best performance, you need to use one copy of the class for one pair (Symbol + Period).
    * @param snapshot use the CSqlObjectSnapShot to save current data
    */
   bool order(string symbol, ENUM_TIMEFRAMES period,
      int variant, bool sell, double openprice, datetime opentime,
      int takeprofit, int stoploss, CSqlObject *sqlobject, int maxbars = 0,
      bool snapshot = true, int deviation = 5)
   {
      if (enable == false) {
         return true;
      }
      CSqlObject *object = snapshot ? (CSqlObject*) new CSqlObjectSnapShot(sqlobject) : sqlobject;
      COrderSqlObject *order = new COrderSqlObject(symbol, period, variant, sell, openprice, opentime,
         takeprofit, stoploss, maxbars, object, snapshot);
      const bool result = COrderData::order(symbol, period, variant, sell, openprice, opentime,
         takeprofit, stoploss, maxbars, deviation, order);
      if (CheckPointer(order) == POINTER_INVALID) {
         return result;
      }
      if (firstrecord == false && CheckPointer(orders_first) != POINTER_INVALID) {
         string filename = "_" + Symbol() + "_" + StringSubstr(EnumToString(Period()), 7);
         filename += "_" + order.order_symbol + "_" + StringSubstr(EnumToString(order.order_period), 7);
         sqlfile.createFile("Orders", false, "forex", filename);
         COrderSqlObjectCast cast(order);
         sqlfile.createTable(cast);
         firstrecord = true;
      }
      return true;
   }

private:
   bool order(string symbol, ENUM_TIMEFRAMES period,
      int variant, bool sell, double openprice, datetime opentime,
      int takeprofit, int stoploss, int maxbars = 0, int deviation = 5, COrderDataObject *order = NULL)
   {
      if (CheckPointer(order) != POINTER_INVALID) {
         delete order;
      }
      return true;
   }
};
