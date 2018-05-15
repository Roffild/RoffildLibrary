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

//#property script_show_inputs
#define _LOG_PARAM

/// @TODO Сейчас пустые строки с пробелами1!!!

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

/*
// Переопределение параметра в такой последовательности:
#define _LOG_PARAM
#include <Roffild/Log4MQL.mqh>
input LOG_LEVEL loglevel = LOG_WARN; // Log Level
*/
#include <Roffild/Log4MQL.mqh>
//#include <Roffild/Log4MQL_tofile.mqh>

   input LOG_LEVEL Log4MqlLevel = LOG_INFO; // Log Level

int OnInit()
{
   _LOG_CLASS::doPrint = false;
   /// @TODO пример в ман добавить
   return(INIT_SUCCEEDED);
}

class CTest
{
public:
   static int Var;// = -1; // Error: '=' - illegal assignment use
private:
   static long pvar;
};
int CTest::Var = 9;
long CTest::pvar = 8;

#define TOSTR(obj) typename( #obj ), " ", #obj
#define TOSTR2(obj) typename( myv#obj )


//#define lgInfo2v(msg,a1,a2) _lgInfo(msg)._LOG_ARG2(a1,a2).build()
//#define lgInfo3v(msg,a1,a2,a3) _lgInfo(msg)._LOG_ARG3(a1,a2,a3).build()

void OnStart()
{
   //CTest::Var = 5; // Error: unresolved static variable 'CTest::Var'
   //Print("CTest::Var = ", CTest::pvar);  // Error: unresolved static variable 'CTest::Var'
   //_LOG_CLASS::doPrint = false;
   Print("================");
   lgTrace2("1={}, 2={}", "HI", 67);
   lgDebug2("1={}, 2={}", "HI", 67);
   lgInfo2("1={}, 2={}", "HI", 67);
   lgWarn2("1={}, 2={}", "HI", 67);
   lgError2("1={}, 2={}", "HI", 67);

   lgError2("line 1={},\nline 2={}", "HI", 67);
   lgWarn2("{},\\nline 2={}", "HI", 67);
   lgWarn2("{},\{} line 2={}", "HI", 67);

   Print("string = ", lgError2("1={}, 2={}", "HI", 67));

   int myvar = 5;
   int myarray[] = {0,1,2,3,4,5,6,7,8,9};
   //Print("test ", TOSTR(myvar), " = ", lgVar3(myarray[myvar], myvar, 999));
   lgInfo1d("Dddddc {} - var", myarray[3]);
   lgInfo7d("Dddddc {} - var", myarray[3], myarray[3], myarray[3], myarray[3], myarray[3], myarray[3], myarray[3]);
}
