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
#property copyright "Roffild"
#property link      "https://github.com/Roffild/RoffildLibrary"

enum ENUM_NOTHING {
   NOTHING // ===== ===== =====
};

input int File_Num = 1;
input bool File_Validation = true;
input int Trees = 100;
input int Random_Vars = 10;
input double R = 0.66;
input bool Regression = false;
sinput ENUM_NOTHING z___; // ===== Else =====
sinput double Tester_Result_Multi = 100;
sinput bool Tester_Report = true;
sinput bool Tester_Show_Incorrect = false;

#include <Roffild/ForestSerializer.mqh>
#include <Roffild/MLPDataFile.mqh>
#include <Roffild/SqlFile.mqh>
#include <Roffild/CsvFile.mqh>

class CRandomForestTest : CSqlObject
{
protected:
   int vars, classes;
   CMatrixDouble ntdata, validdata;

public:
   int init()
   {
      if (Trees < 1) {
         Print("ERROR: Init Trees < 1");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      if (Random_Vars < 1) {
         Print("ERROR: Init Random_Vars < 1");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      if (R < 0.1 || R > 1.0) {
         Print("ERROR: Init R < 0.1 || R > 1.0");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      CMLPDataFile dfile();
      if (dfile.initRead(File_Num, vars, classes) == INVALID_HANDLE) {
         Print("ERROR: Init File not found!");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      if (Regression) {
         classes = 1;
      }
      ntdata.Resize(0, 0);
      const uint read = dfile.readAll(ntdata);
      const int size = ntdata.Size();
      Print("Init OK, read = ", read, " vars = ", vars, " classes = ", classes, " size = ", size);
      CMLPDataFile validfile();
      int valnin, valnout;
      if (File_Validation) {
         if (validfile.initReadValidation(File_Num, valnin, valnout) != INVALID_HANDLE) {
            if (vars != valnin && classes != valnout) {
               Print("ERROR: Validation, NIn or NOut incorrect");
               return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
            }
            validfile.readAll(validdata);
         } else {
            Print("ERROR: Init Validation File not found!");
            return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
         }
         Print("Validation = ", validdata.Size());
      }
      if (MQLInfoInteger(MQL_TESTER) == false) {
         tester();
      }
      return INIT_SUCCEEDED;
   }

   void deinit(const int reason)
   {
   }

   virtual bool tick(const int copy = 0, const int shift = 0, const bool tradingTime = true)
   {
      ExpertRemove();
      return true;
   }

   double tester()
   {
      Print("Tester Start");
      CDecisionForest forest;
      int info = 0;
      CDFReport rep;
      CDForest::DFBuildRandomDecisionForestX1(ntdata, ntdata.Size(), vars, classes, Trees, Random_Vars, R,
         info, forest, rep);
      if (MQLInfoInteger(MQL_OPTIMIZATION) == false) {
         if (info < 0) {
            Print("ERROR: Train info = ", info);
         } else {
            string filename = "MLPData/mlp_" + string(File_Num) + "_Forest_Serialize";
            CForestSerializer::toBinary(forest, filename + ".bin");
            Print(TerminalInfoString(TERMINAL_COMMONDATA_PATH), "/", filename + ".bin");
            // текстовой формат слишком медленный
            //CForestSerializer::toText(forest, filename + ".txt");
            //Print(TerminalInfoString(TERMINAL_COMMONDATA_PATH), "/", filename + ".txt");
         }
      }
      double result[];
      ArrayResize(result, 50);
      double retresult = rep.m_avgerror;
      int col = 0;
      result[col] = vars;
      col++;
      result[col] = classes;
      col++;
      result[col] = info;
      col++;
      result[col] = rep.m_avgce;
      col++;
      result[col] = rep.m_rmserror;
      col++;
      result[col] = rep.m_avgerror;
      col++;
      result[col] = rep.m_avgrelerror;
      col++;
      result[col] = rep.m_relclserror;
      col++;
      result[col] = rep.m_oobavgce;
      col++;
      result[col] = rep.m_oobrmserror;
      col++;
      result[col] = rep.m_oobavgerror;
      col++;
      result[col] = rep.m_oobavgrelerror;
      col++;
      result[col] = rep.m_oobrelclserror;
      if (File_Validation) {
         rep.m_relclserror = CDForest::DFRelClsError(forest, validdata, validdata.Size());
         rep.m_avgce = CDForest::DFAvgCE(forest, validdata, validdata.Size());
         rep.m_rmserror = CDForest::DFRMSError(forest, validdata, validdata.Size());
         rep.m_avgerror = CDForest::DFAvgError(forest, validdata, validdata.Size());
         rep.m_avgrelerror = CDForest::DFAvgRelError(forest, validdata, validdata.Size());
         retresult = rep.m_avgerror;
      } else {
         rep.m_relclserror = 0;
         rep.m_avgce = 0;
         rep.m_rmserror = 0;
         rep.m_avgerror = 0;
         rep.m_avgrelerror = 0;
      }
      col++;
      result[col] = rep.m_avgce;
      col++;
      result[col] = rep.m_rmserror;
      col++;
      result[col] = rep.m_avgerror;
      col++;
      result[col] = rep.m_avgrelerror;
      col++;
      result[col] = rep.m_relclserror;
      ArrayResize(result, col + 1);
      FrameAdd("ForestTest", 0, 0, result);
      Print("Tester Finish");
      return retresult * Tester_Result_Multi;
   }

   void testerDeinit()
   {
      if (Tester_Report == false) {
         return;
      }
      if (FrameFirst() == false) {
         return;
      }
      Print("ForestTest: Dump Start");
      const string objname = "ForestTest";
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
      Print("ForestTest: Append = ", append);
      CSqlFile sqlfile("Tester", append);
      CCsvFile csvfile("Tester", append);
      if (append == false) {
         sqlfile.createTable(this);
         csvfile.createTable(this);
      }
      FrameFirst();
      while (frameNext()) {
         sqlfile.insert(this);
         csvfile.insert(this);
      }
      ObjectDelete(0, objname);
      ChartRedraw();
      Print("ForestTest: Dump Finish");
   }

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
         {"tester_pass", "int"}
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
      string tp[][2] = {
         {"vars", "int"},
         {"classes", "int"},
         {"info", "int"},
         {"avgce", "decimal(64,8)"},
         {"rmserror", "decimal(64,8)"},
         {"avgerror", "decimal(64,8)"},
         {"avgrelerror", "decimal(64,8)"},
         {"relclserror", "decimal(64,8)"},
         {"oobavgce", "decimal(64,8)"},
         {"oobrmserror", "decimal(64,8)"},
         {"oobavgerror", "decimal(64,8)"},
         {"oobavgrelerror", "decimal(64,8)"},
         {"oobrelclserror", "decimal(64,8)"},
         {"valid_avgce", "decimal(64,8)"},
         {"valid_rmserror", "decimal(64,8)"},
         {"valid_avgerror", "decimal(64,8)"},
         {"valid_avgrelerror", "decimal(64,8)"},
         {"valid_relclserror", "decimal(64,8)"},
      };
      ArrayResize(types, ArrayRange(testerdb, 0) + ArrayRange(paramsdb, 0) + ArrayRange(tp, 0));
      ArrayCopy(types, testerdb);
      ArrayCopy(types, paramsdb, ArraySize(testerdb));
      ArrayCopy(types, tp, ArraySize(testerdb) + ArraySize(paramsdb));
      return true;
   }

   virtual bool toSqlRecord(string &list[][2])
   {
      string testerdb[][2] = {
         {"tester_pass", ""},
      };
      testerdb[0][1] = IntegerToString(tester_pass);
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
      string lst[][2] = {
         {"vars", "int"},
         {"classes", "int"},
         {"info", "int"},
         {"avgce", "decimal(64,8)"},
         {"rmserror", "decimal(64,8)"},
         {"avgerror", "decimal(64,8)"},
         {"avgrelerror", "decimal(64,8)"},
         {"relclserror", "decimal(64,8)"},
         {"oobavgce", "decimal(64,8)"},
         {"oobrmserror", "decimal(64,8)"},
         {"oobavgerror", "decimal(64,8)"},
         {"oobavgrelerror", "decimal(64,8)"},
         {"oobrelclserror", "decimal(64,8)"},
         {"valid_avgce", "decimal(64,8)"},
         {"valid_rmserror", "decimal(64,8)"},
         {"valid_avgerror", "decimal(64,8)"},
         {"valid_avgrelerror", "decimal(64,8)"},
         {"valid_relclserror", "decimal(64,8)"},
      };
      const int sizelst = ArrayRange(lst, 0);
      int x = 0;
      for (; x < 3; x++) {
         lst[x][1] = IntegerToString(long(tester_result[x]));
      }
      for (; x < sizelst; x++) {
         lst[x][1] = DoubleToString(tester_result[x]);
      }
      ArrayResize(list, ArrayRange(testerdb, 0) + ArrayRange(paramsdb, 0) + sizelst);
      ArrayCopy(list, testerdb);
      ArrayCopy(list, paramsdb, ArraySize(testerdb));
      ArrayCopy(list, lst, ArraySize(testerdb) + ArraySize(paramsdb));
      return true;
   }
};

CRandomForestTest foresttest();

int OnInit()
{
   return foresttest.init();
}

void OnDeinit(const int reason)
{
   foresttest.deinit(reason);
}

void OnTick()
{
   foresttest.tick();
}

void OnTesterDeinit()
{
   foresttest.testerDeinit();
}

double OnTester()
{
   return foresttest.tester();
}
