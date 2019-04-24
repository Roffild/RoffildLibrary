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
#pragma once

#include "stdafx.h"
#include "public.h"

typedef struct _stInterpreter
{
   DWORD id;
   PyThreadState *interp;
   PyObject *main;
   PyObject *mql_stderr;
   PyObject *mql_stderr_truncate;
   PyObject *mql_stderr_getvalue;
   PyObject *mql_getLong;
   PyObject *mql_getULong;
   PyObject *mql_getDouble;
   PyObject *mql_getString;
} stInterpreter;

extern size_t __interps_count;
extern stInterpreter *__interps;
extern SRWLOCK __interps_lock;

stInterpreter* __getInterp();
stInterpreter* __setInterp(PyThreadState *newinterp);
void __clearInterp(stInterpreter *interp);
void __overrideInterp(stInterpreter *interp);

#define _PY_THREAD_START_OR(stinterp, ret) stInterpreter *__interp = stinterp; \
   if (__interp != NULL && __interp->interp != NULL) { \
      if (_PyThreadState_UncheckedGet() != __interp->interp) { \
         PyEval_AcquireThread(__interp->interp); \
      } \
   } else { ret; } do {} while(0)
#define PY_THREAD_START_OR(ret) _PY_THREAD_START_OR(__getInterp(), ret)
#define PY_THREAD_MAIN_START_OR(ret) _PY_THREAD_START_OR(&__interps[0], ret)
#define PY_THREAD_STOP do {PyEval_ReleaseThread(__interp->interp);} while(0)
#define PY_THREAD_MAIN_STOP do {PyThreadState_Swap(__interp->interp); \
   PyEval_ReleaseThread(__interp->interp);} while(0)
#define PY_THREAD_ANY_STOP do {PyEval_ReleaseLock();} while(0)
