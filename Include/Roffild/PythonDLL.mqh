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
#include "../../Libraries/Roffild/PythonDLL/public.h"

/**
 * Class for PythonDLL.dll
 */
class CPythonDLL
{
protected:
   string bufstr;

public:
   CPythonDLL()
   {
      StringInit(bufstr, 1000111);
   }

   /**
    * Attempt to create a Python environment.
    * If python_home is set incorrectly, the terminal will be destroyed.
    *
    * @param[in] python_home path to the environment of Python.
    * @param[in] console show console window.
    * @return Py_NewInterpreter() != NULL
    */
   bool initialize(const string python_home, const bool console = false)
   {
      const string packages =
           python_home + "/python37.zip;"
         + python_home + "/lib;"
         + python_home + "/lib/site-packages;"
         + python_home + "/DLLs;"
         + python_home + "/;";
      const string dlls =
           python_home + "/;"
         + python_home + "/Library/bin;" // Anaconda
         + python_home + "/DLLs;";
      return pyInitialize(packages, dlls, console);
   }

   /**
    * Check the active environment of Python.
    *
    * @return status.
    */
   bool isInitialized()
   {
      return pyIsInitialized();
   }

   /**
    * It is not necessary to use this function,
    * because it is always called when a test is completed or MetaTrader is closed.
    *
    * WARNING: Do not call this function when using the NumPy library.
    *
    * Bug:
    * https://github.com/numpy/numpy/issues/8097
    * https://bugs.python.org/issue34309
    */
   void finalize()
   {
      pyFinalize();
   }

   /**
    * Compiling and executing code.
    *
    * @param[in] pycode
    * @param[in] override_class when changing the variable __mql__, set to true.
    * @return false if error.
    */
   bool eval(const string pycode, const bool override_class = false)
   {
      if (pyEval(pycode, override_class) == false) {
         Print(getErrorText());
         return false;
      }
      return true;
   }

   /**
    * Checks for errors.
    * To get an error message, use getErrorText().
    *
    * @param[in] clear clears the error.
    * @return true if error.
    */
   bool isError(const bool clear = true)
   {
      return pyIsError(clear);
   }

   /**
    * Checks for errors, gets text and clears the error.
    */
   string getErrorText()
   {
      const int size = pyGetErrorText(bufstr, StringBufferLen(bufstr));
      if (size < 0) {
         return "Error in getErrorText()";
      }
      if (size == 0) {
         return "";
      }
      return bufstr;
   }

   /**
    * Calls the __mql__.getLong() function with the data passed.
    * The error is automatically displayed in the log.
    *
    * @param[in] magic
    * @param[in] value
    * @param[in] inputs
    * @param[out] outputs array size will not change.
    * @param[in] inputs_size
    * @param[in] outputs_size
    * @return the size of the array returned from Python or -1 on a runtime error.
    */
   int getLong(const long magic, const long value, const long &inputs[], long &outputs[],
      const int inputs_size = WHOLE_ARRAY, const int outputs_size = WHOLE_ARRAY)
   {
      const int size = pyMQL_getLong(
         magic, value,
         inputs, (inputs_size < 0 ? ArraySize(inputs) : inputs_size),
         outputs, (outputs_size < 0 ? ArraySize(outputs) : outputs_size)
      );
      if (size < 0) {
         Print(getErrorText());
      }
      return size;
   }

   /**
    * Calls the __mql__.getULong() function with the data passed.
    * The error is automatically displayed in the log.
    *
    * @param[in] magic
    * @param[in] value
    * @param[in] inputs
    * @param[out] outputs array size will not change.
    * @param[in] inputs_size
    * @param[in] outputs_size
    * @return the size of the array returned from Python or -1 on a runtime error.
    */
   int getULong(const long magic, const ulong value, const ulong &inputs[], ulong &outputs[],
      const int inputs_size = WHOLE_ARRAY, const int outputs_size = WHOLE_ARRAY)
   {
      const int size = pyMQL_getULong(
         magic, value,
         inputs, (inputs_size < 0 ? ArraySize(inputs) : inputs_size),
         outputs, (outputs_size < 0 ? ArraySize(outputs) : outputs_size)
      );
      if (size < 0) {
         Print(getErrorText());
      }
      return size;
   }

   /**
    * Calls the __mql__.getDouble() function with the data passed.
    * The error is automatically displayed in the log.
    *
    * @param[in] magic
    * @param[in] value
    * @param[in] inputs
    * @param[out] outputs array size will not change.
    * @param[in] inputs_size
    * @param[in] outputs_size
    * @return the size of the array returned from Python or -1 on a runtime error.
    */
   int getDouble(const long magic, const double value, const double &inputs[], double &outputs[],
      const int inputs_size = WHOLE_ARRAY, const int outputs_size = WHOLE_ARRAY)
   {
      const int size = pyMQL_getDouble(
         magic, value,
         inputs, (inputs_size < 0 ? ArraySize(inputs) : inputs_size),
         outputs, (outputs_size < 0 ? ArraySize(outputs) : outputs_size)
      );
      if (size < 0) {
         Print(getErrorText());
      }
      return size;
   }

   /**
    * Calls the __mql__.getString() function with the data passed.
    * The error is automatically displayed in the log.
    *
    * @param[in] magic
    * @param[in] value
    * @param[in] inputs
    * @param[in] inputs_size
    * @return the string returned from Python or "" on a runtime error.
    */
   string getString(const long magic, const string value, const uchar &inputs[],
      const int inputs_size = WHOLE_ARRAY)
   {
      const int size = pyMQL_getString(
         magic, value,
         inputs, (inputs_size < 0 ? ArraySize(inputs) : inputs_size),
         bufstr, StringBufferLen(bufstr)
      );
      if (size < 0) {
         Print(getErrorText());
         return "";
      }
      return bufstr;
   }

   /**
    * Calls the __mql__.getString() function with the data passed.
    * The error is automatically displayed in the log.
    *
    * @param[in] magic
    * @param[in] value
    * @param[in] inputs
    * @param[out] buffer
    * @param[in] inputs_size
    * @param[in] stringBufferLen use StringBufferLen(buffer)
    * @return the size of the array returned from Python or -1 on a runtime error.
    */
   int getString(const long magic, const string value, const uchar &inputs[], string &buffer,
      const int inputs_size = WHOLE_ARRAY, const int stringBufferLen = WHOLE_ARRAY)
   {
      const int size = pyMQL_getString(
         magic, value,
         inputs, (inputs_size < 0 ? ArraySize(inputs) : inputs_size),
         buffer, (stringBufferLen < 0 ? StringBufferLen(buffer) : stringBufferLen)
      );
      if (size < 0) {
         Print(getErrorText());
      }
      return size;
   }
};
