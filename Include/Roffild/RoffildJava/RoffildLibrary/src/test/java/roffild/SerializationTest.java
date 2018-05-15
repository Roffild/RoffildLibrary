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
package roffild;

import org.junit.Test;

public class SerializationTest
{
   @Test
   public void testWrite() throws Exception
   {
      final String filename = "SerializationJava_UnitTest.serial";
      Serialization serialwrite = new Serialization(filename, true);

      boolean BOOL = true;
      serialwrite.writeNumber(BOOL, Serialization.SERIALIZATION_BOOL);
      int CHAR = -123;
      serialwrite.writeNumber(CHAR, Serialization.SERIALIZATION_CHAR);
      int UCHAR = 245;
      serialwrite.writeNumber(UCHAR, Serialization.SERIALIZATION_UCHAR);
      short SHORT = -32765;
      serialwrite.writeNumber(SHORT, Serialization.SERIALIZATION_SHORT);
      int USHORT = 65533;
      serialwrite.writeNumber(USHORT, Serialization.SERIALIZATION_USHORT);
      int INT = -2147483644;
      serialwrite.writeNumber(INT, Serialization.SERIALIZATION_INT);
      long UINT = 4294967292L;
      serialwrite.writeNumber(UINT, Serialization.SERIALIZATION_UINT);
      long LONG = -9223372036854775805L;
      serialwrite.writeNumber(LONG, Serialization.SERIALIZATION_LONG);
      long ULONG = -4L;
      serialwrite.writeNumber(ULONG, Serialization.SERIALIZATION_ULONG);
      long DATETIME = 1437236635;
      serialwrite.writeNumber(DATETIME, Serialization.SERIALIZATION_DATETIME);
      float FLOAT = 783.842783943f;
      serialwrite.writeDouble(FLOAT, Serialization.SERIALIZATION_FLOAT);
      double DOUBLE = 555.8237327342782983891893;
      serialwrite.writeDouble(DOUBLE, Serialization.SERIALIZATION_DOUBLE);
      /// Лучше не использовать Unicode в Java
      /// @see http://forum.sources.ru/index.php?showtopic=399986
      String STRING = "Русский текст!";
      serialwrite.writeString(STRING);

      stForTest fortest = new stForTest();
      fortest.set(99999, 5344.5634, (char)77, 1437236635L);
      serialwrite.writeStruct(fortest);

      int array[] = {3432, 35477, 2147483645};
      serialwrite.writeArray(array);

      String strarray[] = {"Русский ", "текст с ", "EURUSD!!!"};
      serialwrite.writeStringArray(strarray);

      stForTest fortestarray[] = {new stForTest(), new stForTest(), new stForTest()};
      fortestarray[0].set(456323, 824.4332, (char)34, 743674254);
      fortestarray[1].set(540158, 1387.773, (char)22, 743616494);
      fortestarray[2].set(924547, 428.1148, (char)-74, 457814858);
      serialwrite.writeStructArray(fortestarray);

      serialwrite.close();
   }

   protected class stForTest
   {
      public int v1;
      public double v2;
      public char v3;
      public long v4;

      public void set(int a1, double a2, char a3, long a4)
      {
         v1 = a1;
         v2 = a2;
         v3 = a3;
         v4 = a4;
      }
   }
}
