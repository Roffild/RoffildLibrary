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

#include <Roffild/UnitTest.mqh>

#include <Roffild/Serialization.mqh>

struct stForTest
{
   int v1;
   double v2;
   char v3;
   datetime v4;

   void set(int a1, double a2, char a3, datetime a4)
   {
      v1 = a1;
      v2 = a2;
      v3 = a3;
      v4 = a4;
   }
};

class CForTestRead : public CSerializationRead
{
public:
   stForTest fortest[];

   virtual void setStruct(const int serialHandle, int arraySize = -1)
   {
      if (arraySize > -1) {
         FileReadArray(serialHandle, fortest, 0, arraySize);
      } else {
         ArrayResize(fortest, 1);
         FileReadStruct(serialHandle, fortest[0]);
      }
   }
};

class CSerializationTest : public CUnitTest
{
public:
   void run(string name = "")
   {
      CUnitTest::run(name != "" ? name : "Serialization");
   }

protected:
   CUnitTest_FUNC(1)
   {
      testName = "getSerialType()";
      bool BOOL;
      if (CSerialization::getSerialType(typename(BOOL)) != SERIALIZATION_BOOL) {
         return false;
      }
      char CHAR;
      if (CSerialization::getSerialType(typename(CHAR)) != SERIALIZATION_CHAR) {
         return false;
      }
      uchar UCHAR;
      if (CSerialization::getSerialType(typename(UCHAR)) != SERIALIZATION_UCHAR) {
         return false;
      }
      short SHORT;
      if (CSerialization::getSerialType(typename(SHORT)) != SERIALIZATION_SHORT) {
         return false;
      }
      ushort USHORT;
      if (CSerialization::getSerialType(typename(USHORT)) != SERIALIZATION_USHORT) {
         return false;
      }
      int INT;
      if (CSerialization::getSerialType(typename(INT)) != SERIALIZATION_INT) {
         return false;
      }
      uint UINT;
      if (CSerialization::getSerialType(typename(UINT)) != SERIALIZATION_UINT) {
         return false;
      }
      color COLOR;
      if (CSerialization::getSerialType(typename(COLOR)) != SERIALIZATION_COLOR) {
         return false;
      }
      long LONG;
      if (CSerialization::getSerialType(typename(LONG)) != SERIALIZATION_LONG) {
         return false;
      }
      ulong ULONG;
      if (CSerialization::getSerialType(typename(ULONG)) != SERIALIZATION_ULONG) {
         return false;
      }
      datetime DATETIME;
      if (CSerialization::getSerialType(typename(DATETIME)) != SERIALIZATION_DATETIME) {
         return false;
      }
      float FLOAT;
      if (CSerialization::getSerialType(typename(FLOAT)) != SERIALIZATION_FLOAT) {
         return false;
      }
      double DOUBLE;
      if (CSerialization::getSerialType(typename(DOUBLE)) != SERIALIZATION_DOUBLE) {
         return false;
      }
      string STRING;
      if (CSerialization::getSerialType(typename(STRING)) != SERIALIZATION_STRING) {
         return false;
      }
      /*
      int array[] = {1, 2};
      Print(typename(array));
      ENUM_SERIALIZATION_TYPE enumtype;
      Print("enum ", typename(enumtype));
      CSerialization serl();
      CSerializationRead stserl;
      Print("class ", typename(CSerialization));
      Print("struct ", typename(stserl));
      */
      return true;
   }

   CUnitTest_FUNC(2)
   {
      testName = "write and read";
      const string filename = "Serialization_UnitTest.serial";
      CSerialization serialwrite(filename, true);

      bool BOOL = true;
      serialwrite.writeNumber(BOOL, SERIALIZATION_BOOL);
      char CHAR = -123;
      serialwrite.writeNumber(CHAR, SERIALIZATION_CHAR);
      uchar UCHAR = 245;
      serialwrite.writeNumber(UCHAR, SERIALIZATION_UCHAR);
      short SHORT = -32765;
      serialwrite.writeNumber(SHORT, SERIALIZATION_SHORT);
      ushort USHORT = 65533;
      serialwrite.writeNumber(USHORT, SERIALIZATION_USHORT);
      int INT = -2147483644;
      serialwrite.writeNumber(INT, SERIALIZATION_INT);
      uint UINT = 4294967292;
      serialwrite.writeNumber(UINT, SERIALIZATION_UINT);
      long LONG = -9223372036854775805;
      serialwrite.writeNumber(LONG, SERIALIZATION_LONG);
      ulong ULONG = 18446744073709551612;
      serialwrite.writeNumber(ULONG, SERIALIZATION_ULONG);
      datetime DATETIME = 1437236635;
      serialwrite.writeNumber(DATETIME, SERIALIZATION_DATETIME);
      float FLOAT = 783.842783943f;
      serialwrite.writeDouble(FLOAT, SERIALIZATION_FLOAT);
      double DOUBLE = 555.8237327342782983891893;
      serialwrite.writeDouble(DOUBLE, SERIALIZATION_DOUBLE);
      string STRING = "Русский текст!";
      serialwrite.writeString(STRING);

      stForTest fortest;
      fortest.set(99999, 5344.5634, 77, 1437236635);
      serialwrite.writeStruct(fortest);

      int array[] = {3432, 35477, 2147483645};
      serialwrite.writeArray(array);

      string strarray[] = {"Русский ", "текст с ", "EURUSD!!!"};
      serialwrite.writeStringArray(strarray);

      stForTest fortestarray[3];
      fortestarray[0].set(456323, 824.4332, 34, 743674254);
      fortestarray[1].set(540158, 1387.773, 22, 743616494);
      fortestarray[2].set(924547, 428.1148, -74, 457814858);
      serialwrite.writeStructArray(fortestarray);

      serialwrite.close();

      CSerialization serialread(filename);
      CForTestRead out;

      if (serialread.read(out) != SERIALIZATION_BOOL || out.BOOL != BOOL) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_CHAR || out.CHAR != CHAR) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_UCHAR || out.UCHAR != UCHAR) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_SHORT || out.SHORT != SHORT) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_USHORT || out.USHORT != USHORT) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_INT || out.INT != INT) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_UINT || out.UINT != UINT) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_LONG || out.LONG != LONG) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_ULONG || out.ULONG != ULONG) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_DATETIME || out.DATETIME != DATETIME) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_FLOAT || NormalizeDouble(out.FLOAT - FLOAT, 3) != 0) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_DOUBLE || NormalizeDouble(out.DOUBLE - DOUBLE, 5) != 0) {
         return false;
      }
      if (serialread.read(out) != SERIALIZATION_STRING || out.STRING != STRING) {
         return false;
      }

      if (serialread.read(out) != SERIALIZATION_STRUCT ||
         out.fortest[0].v1 != fortest.v1 ||
         NormalizeDouble(out.fortest[0].v2 != fortest.v2, 5) != 0 ||
         out.fortest[0].v3 != fortest.v3 ||
         out.fortest[0].v4 != fortest.v4) {
         return false;
      }

      if (serialread.read(out) != (SERIALIZATION_INT|SERIALIZATION_ARRAY) ||
         ArraySize(array) != ArraySize(out.INT_ARRAY)) {
         return false;
      }
      for (int x = ArraySize(array)-1; x > -1; x--) {
         if (array[x] != out.INT_ARRAY[x]) {
            return false;
         }
      }

      if (serialread.read(out) != (SERIALIZATION_STRING|SERIALIZATION_ARRAY) ||
         ArraySize(strarray) != ArraySize(out.STRING_ARRAY)) {
         return false;
      }
      for (int x = ArraySize(strarray)-1; x > -1; x--) {
         if (strarray[x] != out.STRING_ARRAY[x]) {
            return false;
         }
      }

      if (serialread.read(out) != SERIALIZATION_STRUCT ||
         ArraySize(fortestarray) != ArraySize(out.fortest)) {
         return false;
      }
      for (int x = ArraySize(fortestarray)-1; x > -1; x--) {
         if (out.fortest[x].v1 != fortestarray[x].v1 ||
            NormalizeDouble(out.fortest[x].v2 != fortestarray[x].v2, 5) != 0 ||
            out.fortest[x].v3 != fortestarray[x].v3 ||
            out.fortest[x].v4 != fortestarray[x].v4) {
            return false;
         }
      }

      return true;
   }
};

void OnStart()
{
   CSerializationTest test();
   test.run();
}
