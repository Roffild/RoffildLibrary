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

enum ENUM_SERIALIZATION_TYPE
{
// Для совместимости с Java лучше задать значения
   SERIALIZATION_ERROR = 0,

   SERIALIZATION_BOOL = 1,
   SERIALIZATION_CHAR = 2,
   SERIALIZATION_UCHAR = 3,
   SERIALIZATION_SHORT = 4,
   SERIALIZATION_USHORT = 5,
   SERIALIZATION_INT = 6,
   SERIALIZATION_UINT = 7,
   SERIALIZATION_COLOR = SERIALIZATION_INT,
   SERIALIZATION_INTEGER = SERIALIZATION_INT,
   SERIALIZATION_UINTEGER = SERIALIZATION_UINT,
   SERIALIZATION_LONG = 8,
   SERIALIZATION_ULONG = 9,
   SERIALIZATION_DATETIME = 10,

   SERIALIZATION_FLOAT = 11,
   SERIALIZATION_DOUBLE = 12,
   SERIALIZATION_STRING = 13,
   SERIALIZATION_STRUCT = 14,

   SERIALIZATION_ARRAY = (1 << 6),
};

class CSerializationRead
{
public:
   bool BOOL;
   bool BOOL_ARRAY[];
   char CHAR;
   char CHAR_ARRAY[];
   uchar UCHAR;
   uchar UCHAR_ARRAY[];
   short SHORT;
   short SHORT_ARRAY[];
   ushort USHORT;
   ushort USHORT_ARRAY[];
   int INT;
   int INT_ARRAY[];
   uint UINT;
   uint UINT_ARRAY[];
   long LONG;
   long LONG_ARRAY[];
   ulong ULONG;
   ulong ULONG_ARRAY[];
   datetime DATETIME;
   datetime DATETIME_ARRAY[];
   float FLOAT;
   float FLOAT_ARRAY[];
   double DOUBLE;
   double DOUBLE_ARRAY[];
   string STRING;
   string STRING_ARRAY[];

   virtual void setStruct(const int serialHandle, int arraySize = -1)
   {
   }
};

class CSerialization
{
public:
   int SerialHandle;

   CSerialization() : SerialHandle(INVALID_HANDLE)
   {
   }

   CSerialization(string path, bool write = false, bool common = true) : SerialHandle(INVALID_HANDLE)
   {
      init(write, path, common);
   }

   ~CSerialization()
   {
      close();
   }

   void close()
   {
      if (SerialHandle != INVALID_HANDLE) {
         FileClose(SerialHandle);
         SerialHandle = INVALID_HANDLE;
      }
   }

   int init(bool write = false, string path = "", bool common = true)
   {
      if (SerialHandle == INVALID_HANDLE) {
         if (path != "") {
            int flags = FILE_BIN | FILE_UNICODE | (write ? FILE_WRITE : FILE_READ);
            if (common) {
               flags |= FILE_COMMON;
            }
            SerialHandle = FileOpen(path, flags);
            return init(write);
         }
         return INVALID_HANDLE;
      }
      ulong seek = FileTell(SerialHandle);
      if (seek == 0) {
         const uint ver = 1;
         if (write) {
            int res = FileWriteInteger(SerialHandle, 0x524553|(ver<<24)) > 0 ? SerialHandle : INVALID_HANDLE;
            FileFlush(SerialHandle);
            return res;
         } else if (FileReadInteger(SerialHandle) != (0x524553|(ver<<24))) {
            close();
         }
      }
      return SerialHandle;
   }

   int readType()
   {
      if (SerialHandle == INVALID_HANDLE) {
         return SERIALIZATION_ERROR;
      }
      return FileReadInteger(SerialHandle, CHAR_VALUE);
   }

   int read(CSerializationRead &out)
   {
      int arraysize = -1;
      int type = readType();
      if ((type & SERIALIZATION_ARRAY) != 0) {
         arraysize = FileReadInteger(SerialHandle);
         type ^= SERIALIZATION_ARRAY;
      }
      switch (type) {
         case SERIALIZATION_BOOL:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.BOOL_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.BOOL = bool(FileReadInteger(SerialHandle, CHAR_VALUE));
            return type;
         case SERIALIZATION_CHAR:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.CHAR_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.CHAR = char(FileReadInteger(SerialHandle, CHAR_VALUE));
            return type;
         case SERIALIZATION_UCHAR:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.UCHAR_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.UCHAR = uchar(FileReadInteger(SerialHandle, CHAR_VALUE));
            return type;
         case SERIALIZATION_SHORT:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.SHORT_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.SHORT = short(FileReadInteger(SerialHandle, SHORT_VALUE));
            return type;
         case SERIALIZATION_USHORT:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.USHORT_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.USHORT = ushort(FileReadInteger(SerialHandle, SHORT_VALUE));
            return type;
         case SERIALIZATION_INT:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.INT_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.INT = FileReadInteger(SerialHandle, INT_VALUE);
            return type;
         case SERIALIZATION_UINT:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.UINT_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.UINT = uint(FileReadInteger(SerialHandle, INT_VALUE));
            return type;
         case SERIALIZATION_LONG:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.LONG_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.LONG = FileReadLong(SerialHandle);
            return type;
         case SERIALIZATION_ULONG:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.ULONG_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.ULONG = ulong(FileReadLong(SerialHandle));
            return type;
         case SERIALIZATION_DATETIME:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.DATETIME_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.DATETIME = datetime(FileReadLong(SerialHandle));
            return type;
         case SERIALIZATION_FLOAT:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.FLOAT_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.FLOAT = FileReadFloat(SerialHandle);
            return type;
         case SERIALIZATION_DOUBLE:
            if (arraysize > -1) {
               FileReadArray(SerialHandle, out.DOUBLE_ARRAY, 0, arraysize);
               return type | SERIALIZATION_ARRAY;
            }
            out.DOUBLE = FileReadDouble(SerialHandle);
            return type;
         case SERIALIZATION_STRING:
            if (arraysize > -1) {
               ArrayResize(out.STRING_ARRAY, arraysize);
               for (int s = 0; s < arraysize; s++) {
                  int length = FileReadInteger(SerialHandle);
                  out.STRING_ARRAY[s] = FileReadString(SerialHandle, length);
               }
               return type | SERIALIZATION_ARRAY;
            } else {
               int length = FileReadInteger(SerialHandle);
               out.STRING = FileReadString(SerialHandle, length);
            }
            return type;
         case SERIALIZATION_STRUCT:
            out.setStruct(SerialHandle, arraysize);
            return type;
      }
      return SERIALIZATION_ERROR;
   }

   uint writeType(int type)
   {
      if (SerialHandle == INVALID_HANDLE) {
         return SERIALIZATION_ERROR;
      }
      return FileWriteInteger(SerialHandle, type, CHAR_VALUE);
   }

   uint writeNumber(long number, ENUM_SERIALIZATION_TYPE type = SERIALIZATION_INT)
   {
      if (type >= SERIALIZATION_FLOAT || writeType(type) == SERIALIZATION_ERROR) {
         return 0;
      }
      switch (type) {
         case SERIALIZATION_BOOL:
         case SERIALIZATION_CHAR:
         case SERIALIZATION_UCHAR:
            return FileWriteInteger(SerialHandle, int(number), CHAR_VALUE);
         case SERIALIZATION_SHORT:
         case SERIALIZATION_USHORT:
            return FileWriteInteger(SerialHandle, int(number), SHORT_VALUE);
         case SERIALIZATION_INT:
         case SERIALIZATION_UINT:
            return FileWriteInteger(SerialHandle, int(number), INT_VALUE);
         case SERIALIZATION_LONG:
         case SERIALIZATION_ULONG:
         case SERIALIZATION_DATETIME:
            return FileWriteLong(SerialHandle, number);
      }
      return 0;
   }

   uint writeDouble(double number, ENUM_SERIALIZATION_TYPE type = SERIALIZATION_DOUBLE)
   {
      if ((type != SERIALIZATION_FLOAT && type != SERIALIZATION_DOUBLE) ||
         writeType(type) == SERIALIZATION_ERROR) {
         return 0;
      }
      if (type == SERIALIZATION_FLOAT) {
         return FileWriteFloat(SerialHandle, float(number));
      }
      return FileWriteDouble(SerialHandle, number);
   }

   template<typename T>
   uint writeArray(const T &array[])
   {
      ENUM_SERIALIZATION_TYPE type = getSerialType(typename(T));
      int count = ArraySize(array);
      if (count == 0 || writeType(type | SERIALIZATION_ARRAY) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, count);
      return FileWriteArray(SerialHandle, array);
   }

   uint writeString(string str)
   {
      if (writeType(SERIALIZATION_STRING) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, StringLen(str));
      return FileWriteString(SerialHandle, str);
   }

   uint writeStringArray(const string &array[])
   {
      int count = ArraySize(array);
      if (count == 0 || writeType(SERIALIZATION_STRING | SERIALIZATION_ARRAY) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, count);
      uint bytes = 0;
      for (int x = 0; x < count; x++) {
         FileWriteInteger(SerialHandle, StringLen(array[x]));
         bytes += FileWriteString(SerialHandle, array[x]);
      }
      return bytes;
   }

   template<typename T>
   uint writeStruct(const T &Struct)
   {
      if (writeType(SERIALIZATION_STRUCT) == SERIALIZATION_ERROR) {
         return 0;
      }
      return FileWriteStruct(SerialHandle, Struct);
   }

   template<typename T>
   uint writeStructArray(const T &array[])
   {
      int count = ArraySize(array);
      if (count == 0 || writeType(SERIALIZATION_STRUCT | SERIALIZATION_ARRAY) == SERIALIZATION_ERROR) {
         return 0;
      }
      FileWriteInteger(SerialHandle, count);
      uint bytes = 0;
      for (int x = 0; x < count; x++) {
         bytes += FileWriteStruct(SerialHandle, array[x]);
      }
      return bytes;
   }

   /// typename() не возвращает "array", "class", "struct", "enum"
   static ENUM_SERIALIZATION_TYPE getSerialType(string nametype)
   {
      if (nametype == "bool") {
         return SERIALIZATION_BOOL;
      }
      if (nametype == "char") {
         return SERIALIZATION_CHAR;
      }
      if (nametype == "uchar") {
         return SERIALIZATION_UCHAR;
      }
      if (nametype == "short") {
         return SERIALIZATION_SHORT;
      }
      if (nametype == "ushort") {
         return SERIALIZATION_USHORT;
      }
      if (nametype == "int") {
         return SERIALIZATION_INT;
      }
      if (nametype == "uint") {
         return SERIALIZATION_UINT;
      }
      if (nametype == "color") {
         return SERIALIZATION_COLOR;
      }
      if (nametype == "long") {
         return SERIALIZATION_LONG;
      }
      if (nametype == "ulong") {
         return SERIALIZATION_ULONG;
      }
      if (nametype == "datetime") {
         return SERIALIZATION_DATETIME;
      }

      if (nametype == "float") {
         return SERIALIZATION_FLOAT;
      }
      if (nametype == "double") {
         return SERIALIZATION_DOUBLE;
      }
      if (nametype == "string") {
         return SERIALIZATION_STRING;
      }
      return SERIALIZATION_ERROR;
   }
};
