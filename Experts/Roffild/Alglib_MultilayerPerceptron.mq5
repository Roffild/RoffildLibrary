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

enum ENUM_VALIDATION {
   VALIDATION_FILE, // File
   VALIDATION_KFOLD, // K-fold
   VALIDATION_KFOLD_NO_RANDOM // K-fold without Random
};

enum ENUM_MLPCREATE {
   MLPCREATE_N, // Normal (-INF, +INF)
   MLPCREATE_B, // B = (B, +INF) if D>=0 or (-INF, B) if D<0
   MLPCREATE_R, // R = [A, B]
   MLPCREATE_C  // C = classifier network [0..NOut-1] NOut>=2
};

enum ENUM_ACTIV_D {
   ACTIV_D_PLUS = 1, // D >= 0
   ACTIV_D_MINUS = -1 // D < 0
};

input int File_Num = 0;
input ENUM_VALIDATION Validation_Type = VALIDATION_KFOLD;
input ENUM_MLPCREATE MLPCreate = MLPCREATE_N; // ===== MLP Create =====
input uint Hidden_1 = 0;
input uint Hidden_2 = 0;
input double Activ_A = 0; // Activ_A for MLPCreateR
input double Activ_B = 0; // Activ_B for MLPCreateB or MLPCreateR
input ENUM_ACTIV_D Activ_D = ACTIV_D_PLUS; // Activ_D for MLPCreateB
input double Decay = 0.001;
input double Decay_Pow = 1;
input uint Restarts = 1;
input bool LBFGS = true; // ===== L-BFGS =====
input double WStep = 0.01;
input double WStep_Pow = 1;
input uint MaxIts = 5;
input uint FoldsCount = 2; // ===== FoldsCount =====
sinput ENUM_NOTHING z___; // ===== Else =====
input bool Random_Index_Inputs = false;
sinput int Tester_Repeat = 3;
sinput double Tester_Result_Multi = 100;
sinput bool Tester_Report = true;
sinput bool Tester_Show_Incorrect = false;

#include "MLPValidation.mqh"
#include <Roffild/MLPDataFile.mqh>
#include <Roffild/SqlFile.mqh>
#include <Roffild/CsvFile.mqh>

class CMLPTest : CSqlObject
{
protected:
   int nin, nout;
   double decay, wstep;
   CMatrixDouble ntdata;
   CMLPValidation valid;

public:
   int init()
   {
      if (Hidden_1 < 1 && Hidden_2 > 0) {
         Print("ERROR: Init Hidden_1 < 1 && Hidden_2 > 0");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      if (Decay_Pow == 0) {
         Print("ERROR: Init Decay_Pow == 0");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      if (WStep_Pow == 0) {
         Print("ERROR: Init WStep_Pow == 0");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      decay = MathPow(Decay, Decay_Pow);
      wstep = MathPow(WStep, WStep_Pow);
      if (decay < CMLPTrain::m_mindecay) {
         Print("ERROR: Init decay(", decay, ") < ", CMLPTrain::m_mindecay);
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      if (wstep < 0) {
         Print("ERROR: Init wstep(", wstep, ") < 0");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      CMLPDataFile dfile();
      if (dfile.initRead(File_Num, nin, nout) == INVALID_HANDLE) {
         Print("ERROR: Init File not found!");
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      // тут должна быть проверка на выполнение в облаке только с параметром LBFG = true
      ntdata.Resize(0, 0);
      const uint read = dfile.readAll(ntdata);
      const int size = ntdata.Size();
      if (FoldsCount < 2 || int(FoldsCount) > size) {
         Print("ERROR: Init FoldsCount < 2 || FoldsCount > ", size);
         return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
      }
      if (Random_Index_Inputs && size > 0 && ntdata[0].Size() > nin) {
         CRowDouble *row = NULL;
         int rnd = 0;
         double temp = 0;
         for (int x = 0; x < size; x++) {
            row = ntdata[x];
            for (int y = 0; y < nin; y++) {
               MathSrand(int(GetMicrosecondCount()));
               rnd = MathRand() % nin;
               temp = row[y];
               row.Set(y, row[rnd]);
               row.Set(rnd, temp);
            }
            row = NULL;
         }
      }
      CMLPDataFile validfile();
      int valnin, valnout;
      if (Validation_Type == VALIDATION_FILE) {
         if (validfile.initReadValidation(File_Num, valnin, valnout) != INVALID_HANDLE) {
            if (nin != valnin && nout != valnout) {
               Print("ERROR: Validation, NIn or NOut incorrect");
               return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
            }
            valid.Validation = size;
            validfile.readAll(ntdata, true);
         } else {
            Print("ERROR: Init Validation File not found!");
            return Tester_Show_Incorrect ? INIT_PARAMETERS_INCORRECT : INIT_FAILED;
         }
      }
      if (Validation_Type != VALIDATION_KFOLD) {
         valid.Random = false;
      }
      Print("Init OK, read = ", read, " inputs = ", nin, " outputs = ", nout, " size = ", size,
         " validation = ", ntdata.Size() - valid.Validation, " random = ", Random_Index_Inputs);
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
      CMultilayerPerceptron mlp;
      if (Hidden_2 > 0) {
         switch (MLPCreate) {
            case MLPCREATE_N:
               CMLPBase::MLPCreate2(nin, Hidden_1, Hidden_2, nout, mlp); break;
            case MLPCREATE_B:
               CMLPBase::MLPCreateB2(nin, Hidden_1, Hidden_2, nout, Activ_B, double(Activ_D), mlp); break;
            case MLPCREATE_R:
               CMLPBase::MLPCreateR2(nin, Hidden_1, Hidden_2, nout, Activ_A, Activ_B, mlp); break;
            case MLPCREATE_C:
               CMLPBase::MLPCreateC2(nin, Hidden_1, Hidden_2, nout, mlp); break;
         }
      } else if (Hidden_1 > 0) {
         switch (MLPCreate) {
            case MLPCREATE_N:
               CMLPBase::MLPCreate1(nin, Hidden_1, nout, mlp); break;
            case MLPCREATE_B:
               CMLPBase::MLPCreateB1(nin, Hidden_1, nout, Activ_B, double(Activ_D), mlp); break;
            case MLPCREATE_R:
               CMLPBase::MLPCreateR1(nin, Hidden_1, nout, Activ_A, Activ_B, mlp); break;
            case MLPCREATE_C:
               CMLPBase::MLPCreateC1(nin, Hidden_1, nout, mlp); break;
         }
      } else {
         switch (MLPCreate) {
            case MLPCREATE_N:
               CMLPBase::MLPCreate0(nin, nout, mlp); break;
            case MLPCREATE_B:
               CMLPBase::MLPCreateB0(nin, nout, Activ_B, double(Activ_D), mlp); break;
            case MLPCREATE_R:
               CMLPBase::MLPCreateR0(nin, nout, Activ_A, Activ_B, mlp); break;
            case MLPCREATE_C:
               CMLPBase::MLPCreateC0(nin, nout, mlp); break;
         }
      }
      int info = 0, _info = 0;
      CMLPReport rep, _rep;
      CMLPCVReport cvrep, _cvrep;
      if (MQLInfoInteger(MQL_OPTIMIZATION) == false) {
         if (LBFGS) {
            CMLPTrain::MLPTrainLBFGS(mlp, ntdata, ntdata.Size(), decay, Restarts, wstep, MaxIts,
               info, rep);
         } else {
            CMLPTrain::MLPTrainLM(mlp, ntdata, ntdata.Size(), decay, Restarts, info, rep);
         }
         if (info < 0) {
            Print("ERROR: Train info = ", info);
         } else {
            CSerializer ser;
            ser.Alloc_Start();
            CMLPBase::MLPAlloc(ser, mlp);
            ser.SStart_Str();
            CMLPBase::MLPSerialize(ser, mlp);
            ser.Stop();
            string filename = "MLPData/mlp_" + string(File_Num) + "_Serialize.txt";
            int hfile = FileOpen(filename, FILE_TXT|FILE_WRITE|FILE_COMMON);
            FileWrite(hfile, ser.Get_String());
            FileClose(hfile);
            Print(TerminalInfoString(TERMINAL_COMMONDATA_PATH), "/", filename);
            double ra[];
            int rlen;
            CMLPBase::MLPSerializeOld(mlp, ra, rlen);
            filename = "MLPData/mlp_" + string(File_Num) + "_SerializeOld.bin";
            hfile = FileOpen(filename, FILE_BIN|FILE_WRITE|FILE_COMMON);
            FileWriteArray(hfile, ra);
            FileClose(hfile);
            Print(TerminalInfoString(TERMINAL_COMMONDATA_PATH), "/", filename);
            /*filename = "MLPData/mlp_" + string(File_Num) + "_Corrected_story";
            CMLPTestDataFile2 dfile;
            if (MLPCreate == MLPCREATE_R && dfile.initWrite(filename, nin, nout, ";") != INVALID_HANDLE) {
               Print("Correction of story...");
               double inp[], outp[];
               for (int x = 0, size = ntdata.Size(); x < size; x++) {
                  dfile.convert(ntdata[x], inp);
                  CMLPBase::MLPProcess(mlp, inp, outp);
                  for (int y = 0; y < nout; y++) {
                     inp[nin + y] = (inp[nin + y] + outp[y]) / 2.0;
                  }
                  dfile.write(inp);
               }
               dfile.close();
               Print(TerminalInfoString(TERMINAL_COMMONDATA_PATH), "/", filename + ".bin");
            }*/
         }
      }
      for (int repeat = Tester_Repeat; repeat > 0; repeat--) {
         if (LBFGS) {
            valid.MLPKFoldCVLBFGS(mlp, ntdata, ntdata.Size(), decay, Restarts, wstep, MaxIts, FoldsCount,
               _info, _rep, _cvrep);
         } else {
            valid.MLPKFoldCVLM(mlp, ntdata, ntdata.Size(), decay, Restarts, FoldsCount, _info, _rep, _cvrep);
         }
         if (_info > 0 && _cvrep.m_avgerror > cvrep.m_avgerror) {
            info = _info;
            rep.Copy(_rep);
            cvrep.Copy(_cvrep);
         }
      }
      double result[];
      ArrayResize(result, 50);
      int col = 0;
      result[col] = nin;
      col++;
      result[col] = Hidden_1;
      col++;
      result[col] = Hidden_2;
      col++;
      result[col] = nout;
      col++;
      result[col] = info;
      col++;
      result[col] = rep.m_ncholesky;
      col++;
      result[col] = rep.m_ngrad;
      col++;
      result[col] = rep.m_nhess;
      col++;
      result[col] = cvrep.m_avgce;
      col++;
      result[col] = cvrep.m_avgerror;
      col++;
      result[col] = cvrep.m_avgrelerror;
      col++;
      result[col] = cvrep.m_relclserror;
      col++;
      result[col] = cvrep.m_rmserror;
      ArrayResize(result, col + 1);
      FrameAdd("MLPTest", 0, 0, result);
      Print("Tester Finish");
      return cvrep.m_avgerror * Tester_Result_Multi;
   }

   void testerDeinit()
   {
      if (Tester_Report == false) {
         return;
      }
      if (FrameFirst() == false) {
         return;
      }
      Print("MLPTest: Dump Start");
      const string objname = "MLPTest";
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
      Print("MLPTest: Append = ", append);
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
      Print("MLPTest: Dump Finish");
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
         {"layer1", "int"},
         {"layer2", "int"},
         {"layer3", "int"},
         {"layer4", "int"},
         {"info", "int"},
         {"ncholesky", "int"},
         {"ngrad", "int"},
         {"nhess", "int"},
         {"avgce", "decimal(64,8)"},
         {"avgerror", "decimal(64,8)"},
         {"avgrelerror", "decimal(64,8)"},
         {"relclserror", "decimal(64,8)"},
         {"rmserror", "decimal(64,8)"},
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
         {"layer1", "int"},
         {"layer2", "int"},
         {"layer3", "int"},
         {"layer4", "int"},
         {"info", "int"},
         {"ncholesky", "int"},
         {"ngrad", "int"},
         {"nhess", "int"},
         {"avgce", "decimal(64,8)"},
         {"avgerror", "decimal(64,8)"},
         {"avgrelerror", "decimal(64,8)"},
         {"relclserror", "decimal(64,8)"},
         {"rmserror", "decimal(64,8)"},
      };
      const int sizelst = ArrayRange(lst, 0);
      int x = 0;
      for (; x < 8; x++) {
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

CMLPTest mlptest();

int OnInit()
{
   return mlptest.init();
}

void OnDeinit(const int reason)
{
   mlptest.deinit(reason);
}

void OnTick()
{
   mlptest.tick();
}

void OnTesterDeinit()
{
   mlptest.testerDeinit();
}

double OnTester()
{
   return mlptest.tester();
}
