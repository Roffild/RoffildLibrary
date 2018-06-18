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

/**
 * A base class for generating data as an array.
 */
class CSqlObject
{
public:
   /**
    * Create a table.
    * @param[out] types [x][0] = name, [x][1] = type
    * @param[out] primaryKeys https://en.wikipedia.org/wiki/Primary_key
    * @return True if the data is formed, and otherwise False.
    */
   virtual bool toSqlTable(string &types[][2], string &primaryKeys[])
   {
      return false;
   }

   /**
    * Forming data for writing to a table.
    * @param[out] list [x][0] = name, [x][1] = data
    * @return True if the data is formed, and otherwise False.
    */
   virtual bool toSqlRecord(string &list[][2])
   {
      return false;
   }
};

/**
 * This class stores the result of the class inherited from CSqlObject into the array.
 * Since the formation of data is done using functions,
 * the moment of data formation can be much later than expected.
 */
class CSqlObjectSnapShot : CSqlObject
{
protected:
   string snap_types[][2];
   string snap_primaryKeys[];
   bool snap_table;
   string snap_list[][2];
   bool snap_record;

public:
   CSqlObjectSnapShot(CSqlObject &sqlobject)
   {
      snap_table = sqlobject.toSqlTable(snap_types, snap_primaryKeys);
      snap_record = sqlobject.toSqlRecord(snap_list);
   }

   virtual bool toSqlTable(string &types[][2], string &primaryKeys[])
   {
      ArrayResize(types, ArrayRange(snap_types, 0));
      ArrayResize(primaryKeys, ArrayRange(snap_primaryKeys, 0));
      ArrayCopy(types, snap_types);
      ArrayCopy(primaryKeys, snap_primaryKeys);
      return snap_table;
   }

   virtual bool toSqlRecord(string &list[][2])
   {
      ArrayResize(list, ArrayRange(snap_list, 0));
      ArrayCopy(list, snap_list);
      return snap_record;
   }
};

/**
 * Write data to a file format MySQL.
 */
class CSqlFile
{
protected:
   int hsql;
   string table;
   string schema;
   string filename;
   uint transaction_count;

private:
   void classInit()
   {
      hsql = INVALID_HANDLE;
      table = "";
      schema = "forex";
      filename = "";
      transaction_count = 0;
   }

public:
   int getHandle()
   {
      return hsql;
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
   CSqlFile()
   {
      classInit();
   }

   CSqlFile(string _table, bool _append, string _schema = "forex", string _filesuffix = "")
   {
      classInit();
      createFile(_table, _append, _schema, _filesuffix);
   }

   bool createFile(string _table, bool _append, string _schema = "forex", string _filesuffix = "")
   {
      table = MQLInfoString(MQL_PROGRAM_NAME) + "_" + _table;
      StringReplace(table, " ", "_");
      schema = _schema;
      filename = schema + "_" + table + _filesuffix + ".sql";
      int flags = FILE_TXT|FILE_WRITE|FILE_ANSI|FILE_SHARE_READ|FILE_COMMON;
      if (_append) {
         flags |= FILE_READ;
      }
      hsql = FileOpen("SQL/" + filename, flags);
      if (_append) {
         FileSeek(hsql, 0, SEEK_END);
      }
      return hsql != INVALID_HANDLE;
   }

   ~CSqlFile()
   {
      close();
   }

   void close()
   {
      if (hsql != INVALID_HANDLE) {
         transaction(true);
         FileClose(hsql);
         hsql = INVALID_HANDLE;
      }
   }

   bool createTable(CSqlObject &sqlobject, bool drop = true)
   {
      if (hsql == INVALID_HANDLE) {
         return false;
      }
      string types[][2];
      string primaryKeys[];
      if (sqlobject.toSqlTable(types, primaryKeys) == false) {
         return false;
      }
      if (drop) {
         FileWrite(hsql, "DROP TABLE IF EXISTS `", schema, "`.`", table, "`;");
      }
      FileWrite(hsql, "CREATE TABLE IF NOT EXISTS `", schema, "`.`", table, "` (");
      const int typeslast = ArrayRange(types, 0) - 1;
      for (int x = 0; x < typeslast; x++) {
         FileWrite(hsql, "  `", types[x][0], "` ", types[x][1], ",");
      }
      FileWrite(hsql, "  `", types[typeslast][0], "` ", types[typeslast][1]);
      for (int x = 0, xc = ArrayRange(primaryKeys, 0); x < xc; x++) {
         FileWrite(hsql, "  ,PRIMARY KEY (`", primaryKeys[x], "`)");
      }
      FileWrite(hsql, ") DEFAULT CHARSET=utf8;");
      return true;
   }

   bool insert(CSqlObject &sqlobject)
   {
      if (hsql == INVALID_HANDLE) {
         return false;
      }
      transaction();
      string list[][2];
      if (sqlobject.toSqlRecord(list) == false) {
         return false;
      }
      string type = "`" + list[0][0] + "`";
      for (int x = 1, xc = ArrayRange(list, 0); x < xc; x++) {
         type += ",`" + list[x][0] + "`";
      }
      string record = "'" + getString(list[0][1]) + "'";
      for (int x = 1, xc = ArrayRange(list, 0); x < xc; x++) {
         record += ",'" + getString(list[x][1]) + "'";
      }
      FileWrite(hsql, "INSERT INTO `", schema, "`.`", table, "`");
      FileWrite(hsql, "  (", type, ")");
      FileWrite(hsql, "  VALUES(", record, ");");
      return true;
   }

   string getString(string rec)
   {
      if (rec == "false") {
         return "0";
      }
      if (rec == "true") {
         return "1";
      }
      return rec;
   }

   void transaction(bool commit = false)
   {
      if (hsql == INVALID_HANDLE) {
         return;
      }
      if (transaction_count == 0) {
         FileWrite(hsql, "START TRANSACTION;");
      }
      transaction_count++;
      if (transaction_count > 500 || commit) {
         FileWrite(hsql, "COMMIT;");
         transaction_count = 0;
         if (commit == false) {
            FileWrite(hsql, "START TRANSACTION;");
            transaction_count++;
         }
      }
   }
};
