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

#include <Roffild/ToIndicator.mqh>

CToIndicator indicBars, indicMedian;

int OnInit()
{
   if (indicBars.init("indicBars", true) == INVALID_HANDLE) {
      Print("ERROR: indicBars.init");
      return INIT_FAILED;
   }
   indicBars.indicatorSetString(INDICATOR_SHORTNAME, "Bars");
   indicBars.addPlot(DRAW_BARS, "Bar");
   indicBars.plotIndexSetInteger(0, PLOT_LINE_COLOR, clrSkyBlue);
   indicBars.addPlot(DRAW_COLOR_LINE, "Median");
   indicBars.plotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   indicBars.plotIndexSetInteger(1, PLOT_COLOR_INDEXES, 2);
   indicBars.plotIndexSetInteger(1, PLOT_LINE_COLOR, 0, clrKhaki);
   indicBars.plotIndexSetInteger(1, PLOT_LINE_COLOR, 1, clrGreen);

   if (indicMedian.init("indicMedian") == INVALID_HANDLE) {
      Print("ERROR: indicMedian.init");
      return INIT_FAILED;
   }
   indicMedian.addPlot(DRAW_COLOR_LINE, "Median");
   indicMedian.plotIndexSetInteger(0, PLOT_LINE_WIDTH, 5);
   indicMedian.plotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
   indicMedian.plotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrAquamarine);
   indicMedian.plotIndexSetInteger(0, PLOT_LINE_COLOR, 1, clrPink);

   indicBars.show();
   indicMedian.show();
   return INIT_SUCCEEDED;
}

void OnTick()
{
   MqlRates rt[];
   CopyRates(Symbol(), Period(), 0, 2, rt);
   ArraySetAsSeries(rt, true);
   const double median = (rt[0].high + rt[0].low) / 2.0;
   const double median1 = (rt[1].high + rt[1].low) / 2.0;

   indicBars.buffer(rt[0].close, 0);
   // or
   /*indicBars.buffer(rt[0].open, 0, 0, 0);
   indicBars.buffer(rt[0].high, 0, 0, 1);
   indicBars.buffer(rt[0].low, 0, 0, 2);
   indicBars.buffer(rt[0].close, 0, 0, 3);*/

   indicBars.buffer(median, 1, (uchar)(median > median1));

   indicMedian.buffer(median, 0, (uchar)(median > median1));

   indicBars.flush();
   indicMedian.flush();
}
