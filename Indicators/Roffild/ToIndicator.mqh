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
#include <Roffild/ToIndicator.mqh>

input string FilePath = "ToIndicator";

const int seconds = PeriodSeconds();
int hfile = INVALID_HANDLE;
int htell = INVALID_HANDLE;

class CToIndicator_Buffers
{
public:
   virtual int getBuffersCount() = 0;
   virtual void setBuffers(const ENUM_DRAW_TYPE type, const ushort plot, const int count,
      const string name, const double empty_value) = 0;
   virtual void set(const SToIndicator_Data &data, const int index) = 0;
};

class CToIndicator_Buffers_1 : public CToIndicator_Buffers
{
public:
   double buffer[];

   int getBuffersCount()
   {
      return 1;
   }

   void setBuffers(const ENUM_DRAW_TYPE type, const ushort plot, const int count,
      const string name, const double empty_value)
   {
      SetIndexBuffer(count, buffer);
      PlotIndexSetInteger(plot, PLOT_DRAW_TYPE, type);
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, empty_value);
      PlotIndexSetString(plot, PLOT_LABEL, name);
   }

   void set(const SToIndicator_Data &data, const int index)
   {
      buffer[index] = data.number;
   }
};

class CToIndicator_Buffers_2 : public CToIndicator_Buffers
{
public:
   double buffer0[];
   double buffer1[];

   int getBuffersCount()
   {
      return 2;
   }

   void setBuffers(const ENUM_DRAW_TYPE type, const ushort plot, const int count,
      const string name, const double empty_value)
   {
      SetIndexBuffer(count + 0, buffer0);
      SetIndexBuffer(count + 1, buffer1);
      PlotIndexSetInteger(plot, PLOT_DRAW_TYPE, type);
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, empty_value);
      PlotIndexSetString(plot, PLOT_LABEL, name+"_1;"+name+"_2");
   }

   void set(const SToIndicator_Data &data, const int index)
   {
      if (data.buffer > -1) {
         if (data.buffer == 0) {
            buffer0[index] = data.number;
         } else if (data.buffer == 1) {
            buffer1[index] = data.number;
         }
         return;
      }
      if (buffer0[index] == 0) {
         buffer0[index] = data.number;
         buffer1[index] = data.number;
      }
      buffer1[index] = data.number;
   }
};

class CToIndicator_Buffers_4 : public CToIndicator_Buffers
{
public:
   double open[];
   double high[];
   double low[];
   double close[];

   int getBuffersCount()
   {
      return 4;
   }

   void setBuffers(const ENUM_DRAW_TYPE type, const ushort plot, const int count,
      const string name, const double empty_value)
   {
      SetIndexBuffer(count + 0, open);
      SetIndexBuffer(count + 1, high);
      SetIndexBuffer(count + 2, low);
      SetIndexBuffer(count + 3, close);
      PlotIndexSetInteger(plot, PLOT_DRAW_TYPE, type);
      PlotIndexSetDouble(plot, PLOT_EMPTY_VALUE, empty_value);
      PlotIndexSetString(plot, PLOT_LABEL, name+"_Open;"+name+"_High;"+name+"_Low;"+name+"_Close");
   }

   void set(const SToIndicator_Data &data, const int index)
   {
      if (data.buffer > -1) {
         if (data.buffer == 0) {
            open[index] = data.number;
         } else if (data.buffer == 1) {
            high[index] = data.number;
         } else if (data.buffer == 2) {
            low[index] = data.number;
         } else if (data.buffer == 3) {
            close[index] = data.number;
         }
         return;
      }
      if (open[index] == 0) {
         open[index] = data.number;
         high[index] = data.number;
         low[index] = data.number;
      }
      if (high[index] < data.number) {
         high[index] = data.number;
      }
      if (low[index] > data.number) {
         low[index] = data.number;
      }
      close[index] = data.number;
   }
};

template<typename Class>
class CToIndicator_Color : public Class
{
public:
   double colors[];

   int getBuffersCount()
   {
      return Class::getBuffersCount() + 1;
   }

   void setBuffers(const ENUM_DRAW_TYPE type, const ushort plot, const int count,
      const string name, const double empty_value)
   {
      Class::setBuffers(type, plot, count, name, empty_value);
      SetIndexBuffer(count + Class::getBuffersCount(), colors, INDICATOR_COLOR_INDEX);
      PlotIndexSetInteger(plot, PLOT_DRAW_TYPE, type);
   }

   void set(const SToIndicator_Data &data, const int index)
   {
      if (data.buffer < 0 || data.buffer == Class::getBuffersCount()) {
         colors[index] = data.color_index;
      }
      Class::set(data, index);
   }
};

CToIndicator_Buffers *plots[];

void OnDeinit(const int reason)
{
   if (hfile != INVALID_HANDLE) {
      FileClose(hfile);
      FileClose(htell);
   }
   for (int x = ArraySize(plots) - 1; x > -1; x--) {
      delete(plots[x]);
   }
   ArrayResize(plots, 0);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (hfile == INVALID_HANDLE) {
      hfile = FileOpen("ToIndicator/" + FilePath, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
      htell = FileOpen("ToIndicator/" + FilePath, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   }
   if (FileReadInteger(htell) == 0) {
      return rates_total;
   }
   ArraySetAsSeries(time, false);
   const datetime future = time[rates_total - 1] - (time[rates_total - 1] % seconds) + seconds;
   bool setbuffer = false;
   while (true) {
      const ulong tell = FileTell(hfile);
      const int type = FileReadInteger(hfile, CHAR_VALUE);
      if (type == TOINDICATOR_DATA && setbuffer == false) {
         SToIndicator_Data data;
         if (FileReadStruct(hfile, data) == sizeof(data)) {
            const int index = ArrayBsearch(time, data.time - (data.time % seconds));
            if (index < (rates_total - 1) || data.time < future) {
               plots[data.plot].set(data, index);
               continue;
            }
         }
      } else if (TOINDICATOR_PARAMETER_MIN < type && type < TOINDICATOR_PARAMETER_MAX) {
         SToIndicator_Parameter param;
         if (FileReadStruct(hfile, param) == sizeof(param)) {
            ResetLastError();
            if (type == TOINDICATOR_PLOT_ADD) {
               const int index = ArrayResize(plots, ArraySize(plots) + 1) - 1;
               int count = 0;
               for (int x = 0; x < index; x++) {
                  count += plots[x].getBuffersCount();
               }
               const ENUM_DRAW_TYPE draw_type = (ENUM_DRAW_TYPE)(param.property);
               switch (draw_type) {
                  case DRAW_NONE: plots[index] = new CToIndicator_Buffers_1(); break;
                  case DRAW_LINE: plots[index] = new CToIndicator_Buffers_1(); break;
                  case DRAW_SECTION: plots[index] = new CToIndicator_Buffers_1(); break;
                  case DRAW_HISTOGRAM: plots[index] = new CToIndicator_Buffers_1(); break;
                  case DRAW_HISTOGRAM2: plots[index] = new CToIndicator_Buffers_2(); break;
                  case DRAW_ARROW: plots[index] = new CToIndicator_Buffers_1(); break;
                  case DRAW_ZIGZAG: plots[index] = new CToIndicator_Buffers_2(); break;
                  case DRAW_FILLING: plots[index] = new CToIndicator_Buffers_2(); break;
                  case DRAW_BARS: plots[index] = new CToIndicator_Buffers_4(); break;
                  case DRAW_CANDLES: plots[index] = new CToIndicator_Buffers_4(); break;
                  case DRAW_COLOR_LINE:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_1>(); break;
                  case DRAW_COLOR_SECTION:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_1>(); break;
                  case DRAW_COLOR_HISTOGRAM:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_1>(); break;
                  case DRAW_COLOR_HISTOGRAM2:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_2>(); break;
                  case DRAW_COLOR_ARROW:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_1>(); break;
                  case DRAW_COLOR_ZIGZAG:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_2>(); break;
                  case DRAW_COLOR_BARS:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_4>(); break;
                  case DRAW_COLOR_CANDLES:
                     plots[index] = new CToIndicator_Color<CToIndicator_Buffers_4>(); break;
                  default: Print(EnumToString(draw_type), " is not support"); break;
               }
               plots[index].setBuffers(draw_type, (ushort)(index), count,
                  ShortArrayToString(param.text), param.double_value);
               setbuffer = true;
            } else if (type == TOINDICATOR_PLOT_INTEGER_MOD) {
               PlotIndexSetInteger(param.index, (ENUM_PLOT_PROPERTY_INTEGER)(param.property),
                  param.modifier, param.int_value);
            } else if (type == TOINDICATOR_PLOT_INTEGER) {
               PlotIndexSetInteger(param.index, (ENUM_PLOT_PROPERTY_INTEGER)(param.property),
                  param.int_value);
            } else if (type == TOINDICATOR_PLOT_DOUBLE) {
               PlotIndexSetDouble(param.index, (ENUM_PLOT_PROPERTY_DOUBLE)(param.property),
                  param.double_value);
            } else if (type == TOINDICATOR_PLOT_STRING) {
               PlotIndexSetString(param.index, (ENUM_PLOT_PROPERTY_STRING)(param.property),
                  ShortArrayToString(param.text));
            } else if (type == TOINDICATOR_INDIC_INTEGER_MOD) {
               IndicatorSetInteger((ENUM_CUSTOMIND_PROPERTY_INTEGER)(param.property),
                  param.modifier, param.int_value);
            } else if (type == TOINDICATOR_INDIC_INTEGER) {
               IndicatorSetInteger((ENUM_CUSTOMIND_PROPERTY_INTEGER)(param.property),
                  param.int_value);
            } else if (type == TOINDICATOR_INDIC_DOUBLE_MOD) {
               IndicatorSetDouble((ENUM_CUSTOMIND_PROPERTY_DOUBLE)(param.property),
                  param.modifier, param.double_value);
            } else if (type == TOINDICATOR_INDIC_DOUBLE) {
               IndicatorSetDouble((ENUM_CUSTOMIND_PROPERTY_DOUBLE)(param.property),
                  param.double_value);
            } else if (type == TOINDICATOR_INDIC_STRING_MOD) {
               IndicatorSetString((ENUM_CUSTOMIND_PROPERTY_STRING)(param.property),
                  param.modifier, ShortArrayToString(param.text));
            } else if (type == TOINDICATOR_INDIC_STRING) {
               IndicatorSetString((ENUM_CUSTOMIND_PROPERTY_STRING)(param.property),
                  ShortArrayToString(param.text));
            }
            const int error = GetLastError();
            if (error != 0) {
               Print("ToIndicator ERROR = ", error, " in ", EnumToString((ENUM_TOINDICATOR)(type)));
            }
            continue;
         }
      }
      const ulong tellnow = FileTell(hfile);
      FileSeek(hfile, tell - tellnow, SEEK_CUR);
      FileSeek(htell, tellnow - FileTell(htell), SEEK_CUR);
      break;
   }
   return rates_total;
}
