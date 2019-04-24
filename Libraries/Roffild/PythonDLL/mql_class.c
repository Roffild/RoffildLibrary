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

_DLLSTD(mqlint) pyMQL_getLong(const mqllong magic, const mqllong value,
   const mqllong _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqllong _DLLOUTARRAY(outputs), const mqlint outputs_size)
{
   PyObject *arg1 = NULL;
   PyObject *arg2 = NULL;
   PyObject *arg3 = NULL;
   PyObject *result = NULL;
   PyObject *seq = NULL;

   PyObject **items = NULL;
   Py_ssize_t x, size;
   mqlint ret = -1;
   int overflow;

   PY_THREAD_START_OR(return ret);
   PyErr_Clear();
   arg1 = PyLong_FromLongLong(magic);
   arg2 = PyLong_FromLongLong(value);
   arg3 = PyTuple_New(inputs_size);
   if (arg1 != NULL && arg2 != NULL && arg3 != NULL) {
      items = PySequence_Fast_ITEMS(arg3);
      for (x = 0; x < inputs_size; x++) {
         items[x] = PyLong_FromLongLong(inputs[x]);
      }
      result = PyObject_CallFunctionObjArgs(__interp->mql_getLong, arg1, arg2, arg3, NULL);
      if (result != NULL) {
         if (result == Py_None) {
            ret = 0;
         }
         else {
            seq = PySequence_Fast(result, "This is not PySequence.");
            if (seq != NULL) {
               size = PySequence_Fast_GET_SIZE(seq);
               ret = (mqlint)size;
               if (size > outputs_size) {
                  size = outputs_size;
               }
               items = PySequence_Fast_ITEMS(seq);
               for (x = 0; x < size; x++) {
                  outputs[x] = PyLong_AsLongLongAndOverflow(items[x], &overflow);
               }
            }
         }
      }
   }
   Py_XDECREF(arg1);
   Py_XDECREF(arg2);
   Py_XDECREF(arg3);
   Py_XDECREF(result);
   Py_XDECREF(seq);
   PY_THREAD_STOP;
   return ret;
}

_DLLSTD(mqlint) pyMQL_getULong(const mqllong magic, const mqlulong value,
   const mqlulong _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqlulong _DLLOUTARRAY(outputs), const mqlint outputs_size)
{
   PyObject *arg1 = NULL;
   PyObject *arg2 = NULL;
   PyObject *arg3 = NULL;
   PyObject *result = NULL;
   PyObject *seq = NULL;

   PyObject **items = NULL;
   Py_ssize_t x, size;
   mqlint ret = -1;

   PY_THREAD_START_OR(return ret);
   PyErr_Clear();
   arg1 = PyLong_FromLongLong(magic);
   arg2 = PyLong_FromUnsignedLongLong(value);
   arg3 = PyTuple_New(inputs_size);
   if (arg1 != NULL && arg2 != NULL && arg3 != NULL) {
      items = PySequence_Fast_ITEMS(arg3);
      for (x = 0; x < inputs_size; x++) {
         items[x] = PyLong_FromUnsignedLongLong(inputs[x]);
      }
      result = PyObject_CallFunctionObjArgs(__interp->mql_getULong, arg1, arg2, arg3, NULL);
      if (result != NULL) {
         if (result == Py_None) {
            ret = 0;
         }
         else {
            seq = PySequence_Fast(result, "This is not PySequence.");
            if (seq != NULL) {
               size = PySequence_Fast_GET_SIZE(seq);
               ret = (mqlint)size;
               if (size > outputs_size) {
                  size = outputs_size;
               }
               items = PySequence_Fast_ITEMS(seq);
               for (x = 0; x < size; x++) {
                  outputs[x] = PyLong_AsUnsignedLongLong(items[x]);
               }
            }
         }
      }
   }
   Py_XDECREF(arg1);
   Py_XDECREF(arg2);
   Py_XDECREF(arg3);
   Py_XDECREF(result);
   Py_XDECREF(seq);
   PY_THREAD_STOP;
   return ret;
}

_DLLSTD(mqlint) pyMQL_getDouble(const mqllong magic, const mqldouble value,
   const mqldouble _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqldouble _DLLOUTARRAY(outputs), const mqlint outputs_size)
{
   PyObject *arg1 = NULL;
   PyObject *arg2 = NULL;
   PyObject *arg3 = NULL;
   PyObject *result = NULL;
   PyObject *seq = NULL;

   PyObject **items = NULL;
   Py_ssize_t x, size;
   mqlint ret = -1;

   PY_THREAD_START_OR(return ret);
   PyErr_Clear();
   arg1 = PyLong_FromLongLong(magic);
   arg2 = PyFloat_FromDouble(value);
   arg3 = PyTuple_New(inputs_size);
   if (arg1 != NULL && arg2 != NULL && arg3 != NULL) {
      items = PySequence_Fast_ITEMS(arg3);
      for (x = 0; x < inputs_size; x++) {
         items[x] = PyFloat_FromDouble(inputs[x]);
      }
      result = PyObject_CallFunctionObjArgs(__interp->mql_getDouble, arg1, arg2, arg3, NULL);
      if (result != NULL) {
         if (result == Py_None) {
            ret = 0;
         }
         else {
            seq = PySequence_Fast(result, "This is not PySequence.");
            if (seq != NULL) {
               size = PySequence_Fast_GET_SIZE(seq);
               ret = (mqlint)size;
               if (size > outputs_size) {
                  size = outputs_size;
               }
               items = PySequence_Fast_ITEMS(seq);
               for (x = 0; x < size; x++) {
                  outputs[x] = PyFloat_AsDouble(items[x]);
               }
            }
         }
      }
   }
   Py_XDECREF(arg1);
   Py_XDECREF(arg2);
   Py_XDECREF(arg3);
   Py_XDECREF(result);
   Py_XDECREF(seq);
   PY_THREAD_STOP;
   return ret;
}

_DLLSTD(mqlint) pyMQL_getString(const mqllong magic, const mqlstring value,
   const mqluchar _DLLOUTARRAY(inputs), const mqlint inputs_size,
   mqlstring _DLLOUTSTRING(buffer), const mqlint stringBufferLen)
{
   PyObject *arg1 = NULL;
   PyObject *arg2 = NULL;
   PyObject *arg3 = NULL;
   PyObject *result = NULL;

   Py_ssize_t size;
   mqlstring str;
   mqlint ret = -1;

   PY_THREAD_START_OR(return ret);
   PyErr_Clear();
   arg1 = PyLong_FromLongLong(magic);
   arg2 = PyUnicode_FromWideChar(value, -1);
   arg3 = PyBytes_FromStringAndSize((const char *)inputs, inputs_size);
   if (arg1 != NULL && arg2 != NULL && arg3 != NULL) {
      result = PyObject_CallFunctionObjArgs(__interp->mql_getString, arg1, arg2, arg3, NULL);
      if (result != NULL) {
         Py_DECREF(arg1);
         arg1 = PyObject_Str(result);
         str = PyUnicode_AsUnicodeAndSize(arg1, &size);
         ret = (mqlint)size;
         if (size > stringBufferLen) {
            size = stringBufferLen;
         }
         wmemcpy(buffer, str, size);
         buffer[size] = 0;
      }
   }
   Py_XDECREF(arg1);
   Py_XDECREF(arg2);
   Py_XDECREF(arg3);
   Py_XDECREF(result);
   PY_THREAD_STOP;
   return ret;
}
