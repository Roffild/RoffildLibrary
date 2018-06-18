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

/**
 * Record optimization results in SQL and CSV format files.
 *
 * If the functions OnTesterDeinit() and OnTester() are not defined,
 * then to use it is enough to include this file in the code.
 */
class CTesterSql : CSqlObject
{
protected:
   ulong tester_pass;
   string tester_name;
   long tester_id;
   double tester_value;
   double tester_result[];

   bool frameNext()
   {
      return FrameNext(tester_pass, tester_name, tester_id, tester_value, tester_result);
   }

   virtual bool toSqlTable(string &types[][2], string &primaryKeys[])
   {
      string testerdb[][2] = {
         {"tester_pass", "int"},
         {"tester_name", "text"},
         {"tester_id", "bigint"},
         {"tester_value", "decimal(64,8)"}
      };
      ArrayResize(primaryKeys, 1);
      primaryKeys[0] = "tester_pass";
      string paramsdb[][2];
      string params[];
      uint paramscount;
      FrameInputs(tester_pass, params, paramscount);
      ArrayResize(paramsdb, paramscount);
      for (uint x = 0; x < paramscount; x++) {
         string name1[];
         StringSplit(params[x], '=', name1);
         paramsdb[x][0] = name1[0];
         paramsdb[x][1] = "decimal(64,8)";
         bool enable;
         double value1, start, step, stop;
         if (ParameterGetRange(name1[0], enable, value1, start, step, stop) == false) {
            paramsdb[x][1] = "text";
         }
      }
      string statsdb[][2];
      for (int x = 0, xc = ArrayResize(statsdb, ArrayRange(stats, 0)); x < xc; x++) {
         statsdb[x][0] = EnumToString(stats[x]);
         statsdb[x][1] = "decimal(64,8)";
      }
      ArrayResize(types, ArrayRange(testerdb, 0) + ArrayRange(paramsdb, 0) + ArrayRange(statsdb, 0));
      ArrayCopy(types, testerdb);
      ArrayCopy(types, paramsdb, ArraySize(testerdb));
      ArrayCopy(types, statsdb, ArraySize(testerdb) + ArraySize(paramsdb));
      return true;
   }

   virtual bool toSqlRecord(string &list[][2])
   {
      string testerdb[][2] = {
         {"tester_pass", ""},
         {"tester_name", ""},
         {"tester_id", ""},
         {"tester_value", ""}
      };
      testerdb[0][1] = IntegerToString(tester_pass);
      testerdb[1][1] = tester_name;
      testerdb[2][1] = IntegerToString(tester_id);
      testerdb[3][1] = DoubleToString(tester_value);
      string paramsdb[][2];
      string params[];
      uint paramscount;
      FrameInputs(tester_pass, params, paramscount);
      ArrayResize(paramsdb, paramscount);
      for (uint x = 0; x < paramscount; x++) {
         string name1[];
         StringSplit(params[x], '=', name1);
         paramsdb[x][0] = name1[0];
         paramsdb[x][1] = name1[1];
      }
      string statsdb[][2];
      for (int x = 0, xc = ArrayResize(statsdb, ArrayRange(stats, 0)); x < xc; x++) {
         statsdb[x][0] = EnumToString(stats[x]);
         statsdb[x][1] = DoubleToString(tester_result[x]);
      }
      ArrayResize(list, ArrayRange(testerdb, 0) + ArrayRange(paramsdb, 0) + ArrayRange(statsdb, 0));
      ArrayCopy(list, testerdb);
      ArrayCopy(list, paramsdb, ArraySize(testerdb));
      ArrayCopy(list, statsdb, ArraySize(testerdb) + ArraySize(paramsdb));
      return true;
   }

public:
   static const ENUM_STATISTICS stats[];

   double tester()
   {
      double result[];
      int size = ArrayResize(result, ArraySize(stats));
      for (int x = 0; x < size; x++) {
         result[x] = TesterStatistics(stats[x]);
      }
      FrameAdd("tester", 0, 0, result);
      return 1.0;
   }

   void testerDeinit()
   {
      if (FrameFirst() == false) {
         return;
      }
      Print("TesterSQL: Dump Start");
      const string objname = "TesterSQL";
      if (ObjectCreate(0, objname, OBJ_LABEL, 0, 0, 0)) {
         ObjectSetString(0, objname, OBJPROP_TEXT, objname + " Dump...");
         ObjectSetInteger(0, objname, OBJPROP_COLOR, clrAquamarine);
         ObjectSetInteger(0, objname, OBJPROP_XDISTANCE, 25);
         ObjectSetInteger(0, objname, OBJPROP_YDISTANCE, 25);
         ObjectSetInteger(0, objname, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, objname, OBJPROP_FONTSIZE, 20);
         ObjectSetInteger(0, objname, OBJPROP_BACK, false);
         ObjectSetInteger(0, objname, OBJPROP_SELECTABLE, true);
         ObjectSetInteger(0, objname, OBJPROP_SELECTED, false);
         ObjectSetInteger(0, objname, OBJPROP_HIDDEN, false);
         ObjectSetInteger(0, objname, OBJPROP_ZORDER, 100);
         ChartRedraw();
      }
      /*bool append = true;
      while (frameNext()) {
         if (tester_pass == 0) {
            append = false;
            break;
         }
      }*/
      bool append = false;
      Print("TesterSQL: Append = ", append);
      CSqlFile sqlfile("Tester", append);
      if (append == false) {
         sqlfile.createTable(this);
      }
      FrameFirst();
      while (frameNext()) {
         sqlfile.insert(this);
      }
      ObjectDelete(0, objname);
      ChartRedraw();
      Print("TesterSQL: Dump Finish");
   }
};
static const ENUM_STATISTICS CTesterSql::stats[] = {
   STAT_INITIAL_DEPOSIT,
   STAT_WITHDRAWAL,
   STAT_PROFIT,
   STAT_GROSS_PROFIT,
   STAT_GROSS_LOSS,
   STAT_MAX_PROFITTRADE,
   STAT_MAX_LOSSTRADE,
   STAT_CONPROFITMAX,
   STAT_CONPROFITMAX_TRADES,
   STAT_MAX_CONWINS,
   STAT_MAX_CONPROFIT_TRADES,
   STAT_CONLOSSMAX,
   STAT_CONLOSSMAX_TRADES,
   STAT_MAX_CONLOSSES,
   STAT_MAX_CONLOSS_TRADES,
   STAT_BALANCEMIN,
   STAT_BALANCE_DD,
   STAT_BALANCEDD_PERCENT,
   STAT_BALANCE_DDREL_PERCENT,
   STAT_BALANCE_DD_RELATIVE,
   STAT_EQUITYMIN,
   STAT_EQUITY_DD,
   STAT_EQUITYDD_PERCENT,
   STAT_EQUITY_DDREL_PERCENT,
   STAT_EQUITY_DD_RELATIVE,
   STAT_EXPECTED_PAYOFF,
   STAT_PROFIT_FACTOR,
   STAT_RECOVERY_FACTOR,
   STAT_SHARPE_RATIO,
   STAT_MIN_MARGINLEVEL,
   STAT_CUSTOM_ONTESTER,
   STAT_DEALS,
   STAT_TRADES,
   STAT_PROFIT_TRADES,
   STAT_LOSS_TRADES,
   STAT_SHORT_TRADES,
   STAT_LONG_TRADES,
   STAT_PROFIT_SHORTTRADES,
   STAT_PROFIT_LONGTRADES,
   STAT_PROFITTRADES_AVGCON,
   STAT_LOSSTRADES_AVGCON
};

#ifndef TESTER
sinput ENUM_STATISTICS TesterResult = STAT_PROFIT;

CTesterSql testersql();

void OnTesterDeinit()
{
   testersql.testerDeinit();
}

double OnTester()
{
   testersql.tester();
   return TesterStatistics(TesterResult);
}
#endif
