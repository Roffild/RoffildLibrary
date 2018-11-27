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

import java.io.Closeable;

import static roffild.mqlport.MqlLibrary.*;

public class Serialization implements Closeable
{
   public static final int SERIALIZATION_ERROR = 0;

   public static final int SERIALIZATION_BOOL = 1;
   public static final int SERIALIZATION_CHAR = 2;
   public static final int SERIALIZATION_UCHAR = 3;
   public static final int SERIALIZATION_SHORT = 4;
   public static final int SERIALIZATION_USHORT = 5;
   public static final int SERIALIZATION_INT = 6;
   public static final int SERIALIZATION_UINT = 7;
   public static final int SERIALIZATION_COLOR = SERIALIZATION_INT;
   public static final int SERIALIZATION_INTEGER = SERIALIZATION_INT;
   public static final int SERIALIZATION_UINTEGER = SERIALIZATION_UINT;
   public static final int SERIALIZATION_LONG = 8;
   public static final int SERIALIZATION_ULONG = 9;
   public static final int SERIALIZATION_DATETIME = 10;

   public static final int SERIALIZATION_FLOAT = 11;
   public static final int SERIALIZATION_DOUBLE = 12;
   public static final int SERIALIZATION_STRING = 13;
   public static final int SERIALIZATION_STRUCT = 14;

   public static final int SERIALIZATION_ARRAY = (1 << 6);

   public int SerialHandle = INVALID_HANDLE;

   public Serialization()
   {
   }

   public Serialization(String path)
   {
      init(false, path);
   }
   public Serialization(String path, boolean write)
   {
      init(write, path);
   }
   public Serialization(String path, boolean write, boolean common)
   {
      init(write, path, common);
   }

   @Override
   protected void finalize() throws Throwable
   {
      close();
      super.finalize();
   }

   @Override
   public void close()
   {
      if (SerialHandle != INVALID_HANDLE) {
         FileClose(SerialHandle);
         SerialHandle = INVALID_HANDLE;
      }
   }

   public int init()
   {
      return init(false, "", true);
   }
   public int init(boolean write)
   {
      return init(write, "", true);
   }
   public int init(boolean write, String path)
   {
      return init(write, path, true);
   }
   public int init(boolean write, String path, boolean common)
   {
      if (SerialHandle == INVALID_HANDLE) {
         if (path != null && !path.isEmpty()) {
            int flags = FILE_BIN | FILE_UNICODE | (write ? FILE_WRITE : FILE_READ);
            if (common) {
               flags |= FILE_COMMON;
            }
            SerialHandle = FileOpen(path, flags);
            return init(write);
         }
         return INVALID_HANDLE;
      }
      long seek = FileTell(SerialHandle);
      if (seek == 0) {
         final int ver = 1;
         if (write) {
            int res = FileWriteInteger(SerialHandle, 0x524553 | (ver << 24)) > 0 ? SerialHandle : INVALID_HANDLE;
            FileFlush(SerialHandle);
            return res;
         } else if (FileReadInteger(SerialHandle) != (0x524553 | (ver << 24))) {
            close();
         }
      }
      return SerialHandle;
   }

   public long writeType(int type)
   {
      if (SerialHandle == INVALID_HANDLE) {
         return SERIALIZATION_ERROR;
      }
      return FileWriteInteger(SerialHandle, type, CHAR_VALUE);
   }

   public long writeNumber(long number)
   {
      return writeNumber(number, SERIALIZATION_INT);
   }

   public long writeNumber(boolean number, int type)
   {
      return writeNumber(number ? 1 : 0, type);
   }

   public long writeNumber(long number, int type)
   {
      if (type >= SERIALIZATION_FLOAT || writeType(type) == SERIALIZATION_ERROR) {
         return 0;
      }
      switch (type) {
         case SERIALIZATION_BOOL:
         case SERIALIZATION_CHAR:
         case SERIALIZATION_UCHAR:
            return FileWriteInteger(SerialHandle, (int)(number), CHAR_VALUE);
         case SERIALIZATION_SHORT:
         case SERIALIZATION_USHORT:
            return FileWriteInteger(SerialHandle, (int)(number), SHORT_VALUE);
         case SERIALIZATION_INT:
         case SERIALIZATION_UINT:
            return FileWriteInteger(SerialHandle, (int)(number), INT_VALUE);
         case SERIALIZATION_LONG:
         case SERIALIZATION_ULONG:
         case SERIALIZATION_DATETIME:
            return FileWriteLong(SerialHandle, number);
      }
      return 0;
   }

   public long writeDouble(double number)
   {
      return writeDouble(number, SERIALIZATION_DOUBLE);
   }

   public long writeDouble(double number, int type)
   {
      if ((type != SERIALIZATION_FLOAT && type != SERIALIZATION_DOUBLE) ||
              writeType(type) == SERIALIZATION_ERROR)
      {
         return 0;
      }
      if (type == SERIALIZATION_FLOAT) {
         return FileWriteFloat(SerialHandle, (float)number);
      }
      return FileWriteDouble(SerialHandle, number);
   }

   public long writeArray(final Object array[])
   {
      int type = getSerialType(typename(array.getClass()));
      int count = ArraySize(array);
      if (count == 0 || writeType(type | SERIALIZATION_ARRAY) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, count);
      return FileWriteArray(SerialHandle, array);
   }

   public long writeString(String str)
   {
      if (writeType(SERIALIZATION_STRING) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, StringLen(str));
      return FileWriteString(SerialHandle, str);
   }

   public long writeStringArray(final String array[])
   {
      int count = ArraySize(array);
      if (count == 0 || writeType(SERIALIZATION_STRING | SERIALIZATION_ARRAY) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, count);
      long bytes = 0;
      for (int x = 0; x < count; x++) {
         FileWriteInteger(SerialHandle, StringLen(array[x]));
         bytes += FileWriteString(SerialHandle, array[x]);
      }
      return bytes;
   }

   public long writeStruct(final Object Struct)
   {
      if (writeType(SERIALIZATION_STRUCT) == SERIALIZATION_ERROR) {
         return 0;
      }
      return FileWriteStruct(SerialHandle, Struct);
   }

   public long writeStructArray(final Object array[])
   {
      int count = ArraySize(array);
      if (count == 0 || writeType(SERIALIZATION_STRUCT | SERIALIZATION_ARRAY) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, count);
      long bytes = 0;
      for (int x = 0; x < count; x++) {
         bytes += FileWriteStruct(SerialHandle, array[x]);
      }
      return bytes;
   }

   /// typename() не возвращает "array", "class", "struct", "enum"
   public static int getSerialType(String nametype)
   {
      if (nametype.equals("bool")) {
         return SERIALIZATION_BOOL;
      }
      if (nametype.equals("char")) {
         return SERIALIZATION_CHAR;
      }
      if (nametype.equals("uchar")) {
         return SERIALIZATION_UCHAR;
      }
      if (nametype.equals("short")) {
         return SERIALIZATION_SHORT;
      }
      if (nametype.equals("ushort")) {
         return SERIALIZATION_USHORT;
      }
      if (nametype.equals("int")) {
         return SERIALIZATION_INT;
      }
      if (nametype.equals("uint")) {
         return SERIALIZATION_UINT;
      }
      if (nametype.equals("color")) {
         return SERIALIZATION_COLOR;
      }
      if (nametype.equals("long")) {
         return SERIALIZATION_LONG;
      }
      if (nametype.equals("ulong")) {
         return SERIALIZATION_ULONG;
      }
      if (nametype.equals("datetime")) {
         return SERIALIZATION_DATETIME;
      }

      if (nametype.equals("float")) {
         return SERIALIZATION_FLOAT;
      }
      if (nametype.equals("double")) {
         return SERIALIZATION_DOUBLE;
      }
      if (nametype.equals("string")) {
         return SERIALIZATION_STRING;
      }

      System.out.println(nametype + " is unknown type.");
      return SERIALIZATION_ERROR;
   }

   public long writeArray(final boolean array[])
   {
      Boolean[] booleans = new Boolean[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         booleans[x] = array[x];
      }
      return writeArray(booleans);
   }

   public long writeArray(final byte array[])
   {
      Byte[] bytes = new Byte[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         bytes[x] = array[x];
      }
      return writeArray(bytes);
   }

   public long writeArray(final char array[])
   {
      Character[] characters = new Character[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         characters[x] = array[x];
      }
      return writeArray(characters);
   }

   public long writeArray(final short array[])
   {
      Short[] shorts = new Short[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         shorts[x] = array[x];
      }
      return writeArray(shorts);
   }

   public long writeArray(final int array[])
   {
      Integer[] ints = new Integer[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         ints[x] = array[x];
      }
      return writeArray(ints);
   }

   public long writeArray(final long array[])
   {
      Long[] longs = new Long[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         longs[x] = array[x];
      }
      return writeArray(longs);
   }

   public long writeArray(final float array[])
   {
      Float[] floats = new Float[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         floats[x] = array[x];
      }
      return writeArray(floats);
   }

   public long writeArray(final double array[])
   {
      Double[] doubles = new Double[array.length];
      for (int x = array.length - 1; x > -1; x--) {
         doubles[x] = array[x];
      }
      return writeArray(doubles);
   }
}
