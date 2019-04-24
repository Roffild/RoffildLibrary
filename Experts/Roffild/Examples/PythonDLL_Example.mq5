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

input string PythonHome = "";

#include <Roffild/PythonDLL.mqh>
#include <Roffild/ToIndicator.mqh>

#resource "PythonDLL_Example.py" as string _PyCode_
CPythonDLL python;

CToIndicator indicMedian;

int OnInit()
{
   if (PythonHome == "") {
      Print("ERROR: PythonHome == \"\"");
      return INIT_FAILED;
   }
   if (python.initialize(PythonHome) == false) {
      Print("ERROR: Py_NewInterpreter() is not created.");
      return INIT_FAILED;
   }
   const string errinit = python.getErrorText();
   if (errinit != "") {
      Print(errinit);
      return INIT_FAILED;
   }
   if (python.eval(_PyCode_, true) == false) {
      return INIT_FAILED;
   }
   uchar array[];
   StringToCharArray("Version_info: ", array);
   Print(python.getString(1, "Version: ", array));
   Print(python.getString(2, "", array));
   Print(python.getString(3, "", array));
   Print("Error in Python:");
   python.getString(99, "", array);

   if (indicMedian.init("indicMedian") == INVALID_HANDLE) {
      Print("ERROR: indicMedian.init");
      return INIT_FAILED;
   }
   indicMedian.addPlot(DRAW_COLOR_LINE, "Median");
   indicMedian.plotIndexSetInteger(0, PLOT_LINE_WIDTH, 5);
   indicMedian.plotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
   indicMedian.plotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrAquamarine);
   indicMedian.plotIndexSetInteger(0, PLOT_LINE_COLOR, 1, clrPink);

   indicMedian.show();
   return INIT_SUCCEEDED;
}

void OnTick()
{
   MqlRates rt[];
   CopyRates(Symbol(), Period(), 0, 2, rt);
   ArraySetAsSeries(rt, true);
   double pack[4];
   pack[0] = rt[0].open;
   pack[1] = rt[0].high;
   pack[2] = rt[0].low;
   pack[3] = rt[0].close;
   double result[100];
   python.getDouble(0, 0, pack, result);

   const double median = result[0];
   const double median1 = (rt[1].high + rt[1].low) / 2.0;
   indicMedian.buffer(median, 0, (uchar)(median > median1));
   indicMedian.flush();
}
