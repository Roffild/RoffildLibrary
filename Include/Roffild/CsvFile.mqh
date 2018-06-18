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
#include "SqlFile.mqh"

/**
 * Write data to a file format CSV.
 * TODO inherit from CSqlFile.
 */
class CCsvFile
{
protected:
   int hcsv;
   string table;
   string schema;
   string filename;

private:
   void classInit()
   {
      hcsv = INVALID_HANDLE;
      table = "";
      schema = "forex";
      filename = "";
   }

public:
   int getHandle()
   {
      return hcsv;
   }

   string getFileName()
   {
      return filename;
   }

   string getTable()
   {
      return table;
   }
   void setTable(string _table)
   {
      table = _table;
   }

   string getSchema()
   {
      return schema;
   }
   void setSchema(string _schema)
   {
      schema = _schema;
   }

public:
   CCsvFile()
   {
      classInit();
   }

   CCsvFile(string _table, bool _append, string _schema = "forex", string _filesuffix = "")
   {
      classInit();
      createFile(_table, _append, _schema, _filesuffix);
   }

   bool createFile(string _table, bool _append, string _schema = "forex", string _filesuffix = "")
   {
      table = MQLInfoString(MQL_PROGRAM_NAME) + "_" + _table;
      StringReplace(table, " ", "_");
      schema = _schema;
      filename = schema + "_" + table + _filesuffix + ".csv";
      int flags = FILE_TXT|FILE_WRITE|FILE_ANSI|FILE_SHARE_READ|FILE_COMMON;
      if (_append) {
         flags |= FILE_READ;
      }
      hcsv = FileOpen("SQL/" + filename, flags);
      if (_append) {
         FileSeek(hcsv, 0, SEEK_END);
      }
      return hcsv != INVALID_HANDLE;
   }

   ~CCsvFile()
   {
      close();
   }

   void close()
   {
      if (hcsv != INVALID_HANDLE) {
         FileClose(hcsv);
         hcsv = INVALID_HANDLE;
      }
   }

   bool createTable(CSqlObject &sqlobject)
   {
      if (hcsv == INVALID_HANDLE) {
         return false;
      }
      string types[][2];
      string primaryKeys[];
      if (sqlobject.toSqlTable(types, primaryKeys) == false) {
         return false;
      }
      string record = types[0][0];
      for (int x = 1, xc = ArrayRange(types, 0); x < xc; x++) {
         record += ";" + types[x][0];
      }
      FileWrite(hcsv, record);
      return true;
   }

   bool insert(CSqlObject &sqlobject)
   {
      if (hcsv == INVALID_HANDLE) {
         return false;
      }
      string list[][2];
      if (sqlobject.toSqlRecord(list) == false) {
         return false;
      }
      string record = list[0][1];
      for (int x = 1, xc = ArrayRange(list, 0); x < xc; x++) {
         record += ";" + list[x][1];
      }
      FileWrite(hcsv, record);
      return true;
   }
};
