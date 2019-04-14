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
#ifdef __MQL__

#import "Roffild/PythonDLL/x64/Release/PythonDLL.dll"

#define mqlchar char
#define mqluchar uchar
#define mqlshort short
#define mqlushort ushort
#define mqlint int
#define mqluint uint
#define mqllong long
#define mqlulong ulong
#define mqlfloat float
#define mqldouble double
#define mqldatetime datetime
#define mqlcolor color
#define mqlbool bool
#define mqlenum enum
#define mqlstring string

#define _DLLSTD(type) type
#define _DLLOUT(name) &name
#define _DLLOUTSTRING(name) &name
#define _DLLOUTARRAY(name) &name[]

#else

#pragma once
/*
using mqlchar = __int8;
using mqluchar = unsigned __int8;
using mqlshort = __int16;
using mqlushort = unsigned __int16;
using mqlint = __int32;
using mqluint = unsigned __int32;
using mqllong = __int64;
using mqlulong = unsigned __int64;
using mqlfloat = float;
using mqldouble = double;
using mqldatetime = mqlulong;
using mqlcolor = mqluint;
using mqlbool = bool;
using mqlenum = mqlint;
using mqlstring = wchar_t*;
*/
typedef __int8 mqlchar;
typedef unsigned __int8 mqluchar;
typedef __int16 mqlshort;
typedef unsigned __int16 mqlushort;
typedef __int32 mqlint;
typedef unsigned __int32 mqluint;
typedef __int64 mqllong;
typedef unsigned __int64 mqlulong;
typedef float mqlfloat;
typedef double mqldouble;
typedef mqlulong mqldatetime;
typedef mqluint mqlcolor;
//typedef bool mqlbool;
typedef __int8 mqlbool;
typedef mqlint mqlenum;
typedef wchar_t* mqlstring;

#ifdef __cplusplus
#define _DLLSTD(type) extern "C" __declspec(dllexport) type __stdcall
#else
#define _DLLSTD(type) extern __declspec(dllexport) type __stdcall
#define false 0
#define true 1
#endif
#define _DLLOUT(name) name
#define _DLLOUTSTRING(name) name
#define _DLLOUTARRAY(name) *name

#endif

_DLLSTD(mqlbool) pyIsInitialized();
_DLLSTD(mqlbool) pyInitialize(const mqlstring paths_to_packages, const mqlstring paths_to_dlls,
   const mqlbool console);
_DLLSTD(void) pyFinalize();
_DLLSTD(mqlbool) pyEval(const mqlstring pycode, const mqlbool override_class);
_DLLSTD(mqlbool) pyIsError(const mqlbool clear);
_DLLSTD(mqlint) pyGetErrorText(mqlstring _DLLOUTSTRING(buffer), const mqlint stringBufferLen);

_DLLSTD(mqlint) pyMQL_getLong(const mqllong magic, const mqllong value,
   const mqllong _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqllong _DLLOUTARRAY(outputs), const mqlint outputs_size);
_DLLSTD(mqlint) pyMQL_getULong(const mqllong magic, const mqlulong value,
   const mqlulong _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqlulong _DLLOUTARRAY(outputs), const mqlint outputs_size);
_DLLSTD(mqlint) pyMQL_getDouble(const mqllong magic, const mqldouble value,
   const mqldouble _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqldouble _DLLOUTARRAY(outputs), const mqlint outputs_size);
_DLLSTD(mqlint) pyMQL_getString(const mqllong magic, const mqlstring value,
   const mqluchar _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqlstring _DLLOUTSTRING(buffer), const mqlint stringBufferLen);

#ifdef __MQL__

#import

#endif
