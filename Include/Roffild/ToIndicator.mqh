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

struct SToIndicator_Data
{
   double number;
   datetime time;
   ushort plot;
   uchar color_index;
   char buffer;
};

struct SToIndicator_Parameter
{
   double double_value;
   int index;
   int property;
   int int_value;
   int modifier;
   ushort text[256];
};

enum ENUM_TOINDICATOR
{
   TOINDICATOR_DATA = 55,
   TOINDICATOR_PARAMETER_MIN,
   TOINDICATOR_PLOT_ADD,
   TOINDICATOR_PLOT_INTEGER,
   TOINDICATOR_PLOT_INTEGER_MOD,
   TOINDICATOR_PLOT_DOUBLE,
   TOINDICATOR_PLOT_STRING,
   TOINDICATOR_INDIC_INTEGER,
   TOINDICATOR_INDIC_INTEGER_MOD,
   TOINDICATOR_INDIC_DOUBLE,
   TOINDICATOR_INDIC_DOUBLE_MOD,
   TOINDICATOR_INDIC_STRING,
   TOINDICATOR_INDIC_STRING_MOD,
   TOINDICATOR_PARAMETER_MAX
};

/**
 * Displaying data from Expert or Script using functions for indicators.
 *
 * Example:
 * https://github.com/Roffild/RoffildLibrary/blob/master/Experts/Roffild/Examples/ToIndicator_Example.mq5
 */
class CToIndicator
{
public:
   string id;
   bool window;
   int handleFile, handleIndicator;

   CToIndicator() : handleFile(INVALID_HANDLE), handleIndicator(INVALID_HANDLE)
   {}

   ~CToIndicator()
   {
      close();
   }

   /**
    * (First) Creating an indicator file.
    */
   int init(const string _id, const bool _window = false, const bool ignore_visual = false)
   {
      id = _id;
      if (MQLInfoInteger(MQL_TESTER) == 0 || (ignore_visual || MQLInfoInteger(MQL_VISUAL_MODE))) {
         handleFile = FileOpen("ToIndicator/" + id, FILE_BIN|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
         window = _window;
         return handleFile;
      }
      return INVALID_HANDLE;
   }

   /**
    * Show the indicator on the graph.
    * It is recommended to call at the end of testing, but you can not use it in OnDeinit().
    */
   int show()
   {
      if (handleFile != INVALID_HANDLE && handleIndicator == INVALID_HANDLE) {
         flush();
         handleIndicator = iCustom(Symbol(), Period(), "Roffild/ToIndicator" + (window ? "_window" : ""), id);
      }
      return handleIndicator;
   }

   /**
    * (Second) Add plot to indicator.
    */
   bool addPlot(ENUM_DRAW_TYPE type, string name, double empty_value = 0)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_PLOT_ADD, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.property = type;
         param.double_value = empty_value;
         StringToShortArray(name, param.text);
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }

   /**
    * Assigning a value to the indicator's buffer.
    * @param value
    * @param plot index of plot
    * @param color_index index of color
    * @param buffer index of buffer (-1 = the rules for assigning values depend on the type of the plot)
    * @param time
    */
   void buffer(double value, ushort plot, uchar color_index = 0, char buffer = -1, datetime time = 0)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_DATA, CHAR_VALUE);
         SToIndicator_Data data = {0};
         data.number = value;
         data.color_index = color_index;
         data.plot = plot;
         data.buffer = buffer;
         data.time = time > 0 ? time : TimeCurrent();
         FileWriteStruct(handleFile, data);
      }
      return;
   }

   void flush()
   {
      if (handleFile != INVALID_HANDLE) {
         FileFlush(handleFile);
      }
   }

   void close()
   {
      if (handleFile != INVALID_HANDLE) {
         FileClose(handleFile);
      }
   }

   bool plotIndexSetInteger(int plot_index, ENUM_PLOT_PROPERTY_INTEGER prop_id,
      int prop_modifier, int prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_PLOT_INTEGER_MOD, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.index = plot_index;
         param.property = prop_id;
         param.modifier = prop_modifier;
         param.int_value = prop_value;
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }
   bool plotIndexSetInteger(int plot_index, ENUM_PLOT_PROPERTY_INTEGER prop_id, int prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_PLOT_INTEGER, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.index = plot_index;
         param.property = prop_id;
         param.int_value = prop_value;
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }

   bool plotIndexSetDouble(int plot_index, ENUM_PLOT_PROPERTY_DOUBLE prop_id, double prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_PLOT_DOUBLE, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.index = plot_index;
         param.property = prop_id;
         param.double_value = prop_value;
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }

   bool plotIndexSetString(int plot_index, ENUM_PLOT_PROPERTY_STRING prop_id, string prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_PLOT_STRING, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.index = plot_index;
         param.property = prop_id;
         StringToShortArray(prop_value, param.text);
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }

   bool indicatorSetInteger(ENUM_CUSTOMIND_PROPERTY_INTEGER prop_id, int prop_modifier, int prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_INDIC_INTEGER_MOD, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.property = prop_id;
         param.modifier = prop_modifier;
         param.int_value = prop_value;
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }
   bool indicatorSetInteger(ENUM_CUSTOMIND_PROPERTY_INTEGER prop_id, int prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_INDIC_INTEGER, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.property = prop_id;
         param.int_value = prop_value;
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }

   bool indicatorSetDouble(ENUM_CUSTOMIND_PROPERTY_DOUBLE prop_id, int prop_modifier, double prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_INDIC_DOUBLE_MOD, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.property = prop_id;
         param.modifier = prop_modifier;
         param.double_value = prop_value;
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }
   bool indicatorSetDouble(ENUM_CUSTOMIND_PROPERTY_DOUBLE prop_id, double prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_INDIC_DOUBLE, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.property = prop_id;
         param.double_value = prop_value;
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }

   bool indicatorSetString(ENUM_CUSTOMIND_PROPERTY_STRING prop_id, int prop_modifier, string prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_INDIC_STRING_MOD, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.property = prop_id;
         param.modifier = prop_modifier;
         StringToShortArray(prop_value, param.text);
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }
   bool indicatorSetString(ENUM_CUSTOMIND_PROPERTY_STRING prop_id, string prop_value)
   {
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, TOINDICATOR_INDIC_STRING, CHAR_VALUE);
         SToIndicator_Parameter param = {0};
         param.property = prop_id;
         StringToShortArray(prop_value, param.text);
         FileWriteStruct(handleFile, param);
         return true;
      }
      return false;
   }
};
