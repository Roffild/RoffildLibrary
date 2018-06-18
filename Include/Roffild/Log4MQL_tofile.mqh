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

#ifndef _LOG_CLASS
   #define _LOG_CLASS CLog4MqlFile
#endif

class CLog4MqlFile;
#include "Log4MQL.mqh"

class CLog4MqlFile : public CLog4Mql
{
protected:
   static int hlog;

   ~CLog4MqlFile()
   {
   }

public:
   /// Due to inheritance restriction, this class constructor had to be made public,
   /// but it is not recommended to use it.
   CLog4MqlFile(LOG_LEVEL lvl, const string text) : CLog4Mql(lvl, text)
   {
      if (hlog == INVALID_HANDLE) {
         setFile();
      }
   }

   static int setFile(string filename = "", bool file_common = false)
   {
      string fname = filename;
      if (filename == "") {
         fname = TimeToString(TimeLocal(), TIME_DATE);
         StringReplace(fname, ".", "");
         fname = MQLInfoString(MQL_PROGRAM_NAME) + "_" + fname + ".log";
      }
      int flags = FILE_READ | FILE_WRITE | FILE_SHARE_READ;
      if (file_common || MQL5InfoInteger(MQL5_TESTER) || MQL5InfoInteger(MQL5_OPTIMIZATION) ||
          MQL5InfoInteger(MQL5_VISUAL_MODE)) {
         flags |= FILE_COMMON;
      }
      FileClose(hlog);
      hlog = FileOpen(fname, flags);
      FileSeek(hlog, 0, SEEK_END);
      return hlog;
   }

   static int getFileHandle()
   {
      return hlog;
   }

   /// Compile and display a message
   /// @see http://www.slf4j.org/apidocs/org/slf4j/helpers/MessageFormatter.html
   virtual string build()
   {
      if (lglvl < Log4MqlLevel) {
         delete GetPointer(this);
         return "";
      }

      string msg = getMessage();

      string time = "--\t0\t" + (string)TimeCurrent() + "\t" + MQLInfoString(MQL_PROGRAM_NAME) +
                    " (" + Symbol() + "," + StringSubstr(EnumToString(Period()), 7) + ")\t";
      string tolog = msg;
      StringReplace(tolog, "\t", " ");
      StringReplace(tolog, "\n", "\n" + time);

      FileWrite(hlog, time + tolog);
      FileFlush(hlog);

      if (doPrint) {
         Print(msg);
      }
      delete GetPointer(this);
      return msg;
   }
};

int CLog4MqlFile::hlog = INVALID_HANDLE;
