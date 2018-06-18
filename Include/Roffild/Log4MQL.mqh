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

enum LOG_LEVEL
{
   LOG_TRACE,  // Trace
   LOG_DEBUG,  // Debug
   LOG_INFO,   // Information
   LOG_WARN,   // Warning
   LOG_ERROR,  // Error
   LOG_NOTHING // Nothing
};
#ifndef _LOG_PARAM
   input LOG_LEVEL Log4MqlLevel = LOG_INFO; // Log Level
#endif

#ifndef _LOG_CLASS
   #define _LOG_CLASS CLog4Mql
#endif

/// @see http://www.slf4j.org/apidocs/org/slf4j/Logger.html
class CLog4Mql
{
protected:
   string message;
   string args[];
   LOG_LEVEL lglvl;

   CLog4Mql(LOG_LEVEL lvl, const string text) : lglvl(lvl), message(text)
   {
   }

   ~CLog4Mql()
   {
   }

   /// @see http://www.slf4j.org/apidocs/org/slf4j/helpers/MessageFormatter.html
   string buildMessage()
   {
      string msg = "";
      int ag = 0;
      int countargs = ArraySize(args);
      int pos = StringFind(message, "{}"), lastpos = 0;
      if (pos > -1) {
         if (pos == 0) {
            msg += args[ag];
            ag++;
            lastpos = 2;
            pos = StringFind(message, "{}", pos+1);
         }
         bool escape = false;
         for (; pos > -1 && ag < countargs; pos = StringFind(message, "{}", pos+1)) {
            if (StringGetCharacter(message, pos-1) == '\\') {
               escape = true;
               continue;
            }
            string temp = StringSubstr(message, lastpos, pos-lastpos);
            if (escape) {
               StringReplace(temp, "\\{}", "{}");
               escape = false;
            }
            msg += temp + args[ag];
            ag++;
            lastpos = pos+2;
         }
         if (lastpos < StringLen(message)) {
            string temp = StringSubstr(message, lastpos);
            StringReplace(temp, "\\{}", "{}");
            msg += temp;
         }
      } else {
         msg = message;
      }

      if (ag < countargs) {
         msg += " // " + args[ag];
         ag++;
         for (; ag < countargs; ag++) {
            msg += "," + args[ag];
         }
      }

      return msg;
   }

   virtual string getLevel()
   {
      switch (lglvl) {
      case LOG_TRACE: return "TRACE: ";
      case LOG_DEBUG: return "DEBUG: ";
      case LOG_INFO: return "INFO: ";
      case LOG_WARN: return "WARN: ";
      case LOG_ERROR: return "ERROR: ";
      default: return "";
      }
   }

   virtual string getMessage()
   {
      string lvl = getLevel();

      string msg = buildMessage();
      StringReplace(msg, "\n", "\n" + lvl);

      return lvl + msg;
   }

public:
   /// Adds the value of the variable to the message
   _LOG_CLASS* a(const string value)
   {
      if (lglvl < Log4MqlLevel) {
         return GetPointer(this);
      }

      int count = ArrayResize(args, ArraySize(args)+1, 50);
      if (count == -1) {
         Print("WARN: No memory!");
         return GetPointer(this);
      }
      args[count-1] = value;
      return GetPointer(this);
   }
   /// Adds the value of the variable to the message
   _LOG_CLASS* add(const string value)
   {
      return a(value);
   }

   /// Use Print() ?
   static bool doPrint;

   /// Compile and display a message
   /// @see http://www.slf4j.org/apidocs/org/slf4j/helpers/MessageFormatter.html
   virtual string build()
   {
      if (lglvl < Log4MqlLevel) {
         delete GetPointer(this);
         return "";
      }

      string msg = getMessage();
      if (doPrint) {
         Print(msg);
      }
      delete GetPointer(this);
      return msg;
   }

   static _LOG_CLASS* trace(const string text)
   {
      _LOG_CLASS* clog = new _LOG_CLASS(LOG_TRACE, text);
      return clog;
   }

   static _LOG_CLASS* debug(const string text)
   {
      _LOG_CLASS* clog = new _LOG_CLASS(LOG_DEBUG, text);
      return clog;
   }

   static _LOG_CLASS* info(const string text)
   {
      _LOG_CLASS* clog = new _LOG_CLASS(LOG_INFO, text);
      return clog;
   }

   static _LOG_CLASS* warn(const string text)
   {
      _LOG_CLASS* clog = new _LOG_CLASS(LOG_WARN, text);
      return clog;
   }

   static _LOG_CLASS* error(const string text)
   {
      _LOG_CLASS* clog = new _LOG_CLASS(LOG_ERROR, text);
      return clog;
   }

   static bool isTraceEnabled()
   {
      return Log4MqlLevel <= LOG_TRACE;
   }

   static bool isDebugEnabled()
   {
      return Log4MqlLevel <= LOG_DEBUG;
   }

   static bool isInfoEnabled()
   {
      return Log4MqlLevel <= LOG_INFO;
   }

   static bool isWarnEnabled()
   {
      return Log4MqlLevel <= LOG_WARN;
   }

   static bool isErrorEnabled()
   {
      return Log4MqlLevel <= LOG_ERROR;
   }
};

bool CLog4Mql::doPrint = true;

#ifndef _LOG_ARG1
   #define _LOG_ARG1(arg) a(string(arg))
#endif

#ifndef lgDump
   #define lgDump(var) string(#var + "=" + string(var))
#endif

#define _LOG_ARG2(a1,a2) _LOG_ARG1(a1)._LOG_ARG1(a2)
#define _LOG_ARG3(a1,a2,a3) _LOG_ARG2(a1,a2)._LOG_ARG1(a3)
#define _LOG_ARG4(a1,a2,a3,a4) _LOG_ARG3(a1,a2,a3)._LOG_ARG1(a4)
#define _LOG_ARG5(a1,a2,a3,a4,a5) _LOG_ARG4(a1,a2,a3,a4)._LOG_ARG1(a5)
#define _LOG_ARG6(a1,a2,a3,a4,a5,a6) _LOG_ARG5(a1,a2,a3,a4,a5)._LOG_ARG1(a6)
#define _LOG_ARG7(a1,a2,a3,a4,a5,a6,a7) _LOG_ARG6(a1,a2,a3,a4,a5,a6)._LOG_ARG1(a7)
#define _LOG_ARG8(a1,a2,a3,a4,a5,a6,a7,a8) _LOG_ARG7(a1,a2,a3,a4,a5,a6,a7)._LOG_ARG1(a8)

#define _lgTrace(msg) _LOG_CLASS::trace(msg)
#define lgTrace0(msg) _lgTrace(msg).build()
#define lgTrace1(msg,a1) _lgTrace(msg)._LOG_ARG1(a1).build()
#define lgTrace2(msg,a1,a2) _lgTrace(msg)._LOG_ARG2(a1,a2).build()
#define lgTrace3(msg,a1,a2,a3) _lgTrace(msg)._LOG_ARG3(a1,a2,a3).build()
#define lgTrace4(msg,a1,a2,a3,a4) _lgTrace(msg)._LOG_ARG4(a1,a2,a3,a4).build()
#define lgTrace5(msg,a1,a2,a3,a4,a5) _lgTrace(msg)._LOG_ARG5(a1,a2,a3,a4,a5).build()
#define lgTrace6(msg,a1,a2,a3,a4,a5,a6) _lgTrace(msg)._LOG_ARG6(a1,a2,a3,a4,a5,a6).build()
#define lgTrace7(msg,a1,a2,a3,a4,a5,a6,a7) _lgTrace(msg)._LOG_ARG7(a1,a2,a3,a4,a5,a6,a7).build()

#define _lgDebug(msg) _LOG_CLASS::debug(msg)
#define lgDebug0(msg) _lgDebug(msg).build()
#define lgDebug1(msg,a1) _lgDebug(msg)._LOG_ARG1(a1).build()
#define lgDebug2(msg,a1,a2) _lgDebug(msg)._LOG_ARG2(a1,a2).build()
#define lgDebug3(msg,a1,a2,a3) _lgDebug(msg)._LOG_ARG3(a1,a2,a3).build()
#define lgDebug4(msg,a1,a2,a3,a4) _lgDebug(msg)._LOG_ARG4(a1,a2,a3,a4).build()
#define lgDebug5(msg,a1,a2,a3,a4,a5) _lgDebug(msg)._LOG_ARG5(a1,a2,a3,a4,a5).build()
#define lgDebug6(msg,a1,a2,a3,a4,a5,a6) _lgDebug(msg)._LOG_ARG6(a1,a2,a3,a4,a5,a6).build()
#define lgDebug7(msg,a1,a2,a3,a4,a5,a6,a7) _lgDebug(msg)._LOG_ARG7(a1,a2,a3,a4,a5,a6,a7).build()

#define _lgInfo(msg) _LOG_CLASS::info(msg)
#define lgInfo0(msg) _lgInfo(msg).build()
#define lgInfo1(msg,a1) _lgInfo(msg)._LOG_ARG1(a1).build()
#define lgInfo2(msg,a1,a2) _lgInfo(msg)._LOG_ARG2(a1,a2).build()
#define lgInfo3(msg,a1,a2,a3) _lgInfo(msg)._LOG_ARG3(a1,a2,a3).build()
#define lgInfo4(msg,a1,a2,a3,a4) _lgInfo(msg)._LOG_ARG4(a1,a2,a3,a4).build()
#define lgInfo5(msg,a1,a2,a3,a4,a5) _lgInfo(msg)._LOG_ARG5(a1,a2,a3,a4,a5).build()
#define lgInfo6(msg,a1,a2,a3,a4,a5,a6) _lgInfo(msg)._LOG_ARG6(a1,a2,a3,a4,a5,a6).build()
#define lgInfo7(msg,a1,a2,a3,a4,a5,a6,a7) _lgInfo(msg)._LOG_ARG7(a1,a2,a3,a4,a5,a6,a7).build()

#define _lgWarn(msg) _LOG_CLASS::warn(msg)
#define lgWarn0(msg) _lgWarn(msg).build()
#define lgWarn1(msg,a1) _lgWarn(msg)._LOG_ARG1(a1).build()
#define lgWarn2(msg,a1,a2) _lgWarn(msg)._LOG_ARG2(a1,a2).build()
#define lgWarn3(msg,a1,a2,a3) _lgWarn(msg)._LOG_ARG3(a1,a2,a3).build()
#define lgWarn4(msg,a1,a2,a3,a4) _lgWarn(msg)._LOG_ARG4(a1,a2,a3,a4).build()
#define lgWarn5(msg,a1,a2,a3,a4,a5) _lgWarn(msg)._LOG_ARG5(a1,a2,a3,a4,a5).build()
#define lgWarn6(msg,a1,a2,a3,a4,a5,a6) _lgWarn(msg)._LOG_ARG6(a1,a2,a3,a4,a5,a6).build()
#define lgWarn7(msg,a1,a2,a3,a4,a5,a6,a7) _lgWarn(msg)._LOG_ARG7(a1,a2,a3,a4,a5,a6,a7).build()

#define _lgError(msg) _LOG_CLASS::error(msg)
#define lgError0(msg) _lgError(msg).build()
#define lgError1(msg,a1) _lgError(msg)._LOG_ARG1(a1).build()
#define lgError2(msg,a1,a2) _lgError(msg)._LOG_ARG2(a1,a2).build()
#define lgError3(msg,a1,a2,a3) _lgError(msg)._LOG_ARG3(a1,a2,a3).build()
#define lgError4(msg,a1,a2,a3,a4) _lgError(msg)._LOG_ARG4(a1,a2,a3,a4).build()
#define lgError5(msg,a1,a2,a3,a4,a5) _lgError(msg)._LOG_ARG5(a1,a2,a3,a4,a5).build()
#define lgError6(msg,a1,a2,a3,a4,a5,a6) _lgError(msg)._LOG_ARG6(a1,a2,a3,a4,a5,a6).build()
#define lgError7(msg,a1,a2,a3,a4,a5,a6,a7) _lgError(msg)._LOG_ARG7(a1,a2,a3,a4,a5,a6,a7).build()

///////////////////////////

#define lgTrace0d(msg) lgTrace0(msg)
#define lgTrace1d(msg,a1) lgTrace1(msg,lgDump(a1))
#define lgTrace2d(msg,a1,a2) lgTrace2(msg,lgDump(a1),lgDump(a2))
#define lgTrace3d(msg,a1,a2,a3) lgTrace3(msg,lgDump(a1),lgDump(a2),lgDump(a3))
#define lgTrace4d(msg,a1,a2,a3,a4) lgTrace4(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4))
#define lgTrace5d(msg,a1,a2,a3,a4,a5) lgTrace5(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5))
#define lgTrace6d(msg,a1,a2,a3,a4,a5,a6) lgTrace6(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6))
#define lgTrace7d(msg,a1,a2,a3,a4,a5,a6,a7) lgTrace7(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6),lgDump(a7))

#define lgDebug0d(msg) lgDebug0(msg)
#define lgDebug1d(msg,a1) lgDebug1(msg,lgDump(a1))
#define lgDebug2d(msg,a1,a2) lgDebug2(msg,lgDump(a1),lgDump(a2))
#define lgDebug3d(msg,a1,a2,a3) lgDebug3(msg,lgDump(a1),lgDump(a2),lgDump(a3))
#define lgDebug4d(msg,a1,a2,a3,a4) lgDebug4(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4))
#define lgDebug5d(msg,a1,a2,a3,a4,a5) lgDebug5(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5))
#define lgDebug6d(msg,a1,a2,a3,a4,a5,a6) lgDebug6(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6))
#define lgDebug7d(msg,a1,a2,a3,a4,a5,a6,a7) lgDebug7(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6),lgDump(a7))

#define lgInfo0d(msg) lgInfo0(msg)
#define lgInfo1d(msg,a1) lgInfo1(msg,lgDump(a1))
#define lgInfo2d(msg,a1,a2) lgInfo2(msg,lgDump(a1),lgDump(a2))
#define lgInfo3d(msg,a1,a2,a3) lgInfo3(msg,lgDump(a1),lgDump(a2),lgDump(a3))
#define lgInfo4d(msg,a1,a2,a3,a4) lgInfo4(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4))
#define lgInfo5d(msg,a1,a2,a3,a4,a5) lgInfo5(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5))
#define lgInfo6d(msg,a1,a2,a3,a4,a5,a6) lgInfo6(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6))
#define lgInfo7d(msg,a1,a2,a3,a4,a5,a6,a7) lgInfo7(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6),lgDump(a7))

#define lgWarn0d(msg) lgWarn0(msg)
#define lgWarn1d(msg,a1) lgWarn1(msg,lgDump(a1))
#define lgWarn2d(msg,a1,a2) lgWarn2(msg,lgDump(a1),lgDump(a2))
#define lgWarn3d(msg,a1,a2,a3) lgWarn3(msg,lgDump(a1),lgDump(a2),lgDump(a3))
#define lgWarn4d(msg,a1,a2,a3,a4) lgWarn4(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4))
#define lgWarn5d(msg,a1,a2,a3,a4,a5) lgWarn5(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5))
#define lgWarn6d(msg,a1,a2,a3,a4,a5,a6) lgWarn6(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6))
#define lgWarn7d(msg,a1,a2,a3,a4,a5,a6,a7) lgWarn7(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6),lgDump(a7))

#define lgError0d(msg) lgError0(msg)
#define lgError1d(msg,a1) lgError1(msg,lgDump(a1))
#define lgError2d(msg,a1,a2) lgError2(msg,lgDump(a1),lgDump(a2))
#define lgError3d(msg,a1,a2,a3) lgError3(msg,lgDump(a1),lgDump(a2),lgDump(a3))
#define lgError4d(msg,a1,a2,a3,a4) lgError4(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4))
#define lgError5d(msg,a1,a2,a3,a4,a5) lgError5(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5))
#define lgError6d(msg,a1,a2,a3,a4,a5,a6) lgError6(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6))
#define lgError7d(msg,a1,a2,a3,a4,a5,a6,a7) lgError7(msg,lgDump(a1),lgDump(a2),lgDump(a3),lgDump(a4),lgDump(a5),lgDump(a6),lgDump(a7))
