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
#include "stdafx.h"
#include "private.h"

size_t __interps_count = 0;
stInterpreter **__interps = NULL;
SRWLOCK __interps_lock;

stInterpreter* __getInterp()
{
   AcquireSRWLockShared(&__interps_lock);
   const DWORD id = GetCurrentThreadId();
   stInterpreter *ret = NULL;
   for (size_t x = 0; x < __interps_count; x++) {
      if (__interps[x]->id == id) {
         ret = __interps[x];
      }
   }
   ReleaseSRWLockShared(&__interps_lock);
   return ret;
}

stInterpreter* __setInterp(PyThreadState *newinterp)
{
   AcquireSRWLockShared(&__interps_lock);
   const DWORD id = GetCurrentThreadId();
   stInterpreter *ret = NULL;
   for (size_t x = 0; x < __interps_count; x++) {
      if (__interps[x]->id == id) {
         __interps[x]->interp = newinterp;
         ret = __interps[x];
      }
   }
   ReleaseSRWLockShared(&__interps_lock);
   return ret;
}

void __clearInterp(stInterpreter *interp)
{
   if (interp->interp != NULL) {
      //Py_CLEAR(interp->main); // This is not must be clear!
      Py_CLEAR(interp->mql_stderr);
      Py_CLEAR(interp->mql_stderr_truncate);
      Py_CLEAR(interp->mql_stderr_getvalue);
      Py_CLEAR(interp->mql_getLong);
      Py_CLEAR(interp->mql_getULong);
      Py_CLEAR(interp->mql_getDouble);
      Py_CLEAR(interp->mql_getString);
   }
   else {
      interp->main = NULL;
      interp->mql_stderr = NULL;
      interp->mql_stderr_truncate = NULL;
      interp->mql_stderr_getvalue = NULL;
      interp->mql_getLong = NULL;
      interp->mql_getULong = NULL;
      interp->mql_getDouble = NULL;
      interp->mql_getString = NULL;
   }
}

void __overrideInterp(stInterpreter *interp)
{
   __clearInterp(interp);
   interp->mql_stderr = PyObject_GetAttrString(interp->main, "__mql_stderr__");
   if (interp->mql_stderr != NULL) {
      interp->mql_stderr_truncate = PyObject_GetAttrString(interp->mql_stderr, "truncate_fix");
      interp->mql_stderr_getvalue = PyObject_GetAttrString(interp->mql_stderr, "getvalue");
   }
   PyObject *mql = PyObject_GetAttrString(interp->main, "__mql__");
   if (mql != NULL) {
      interp->mql_getLong = PyObject_GetAttrString(mql, "getLong");
      interp->mql_getULong = PyObject_GetAttrString(mql, "getULong");
      interp->mql_getDouble = PyObject_GetAttrString(mql, "getDouble");
      interp->mql_getString = PyObject_GetAttrString(mql, "getString");
      Py_DECREF(mql);
   }
}
