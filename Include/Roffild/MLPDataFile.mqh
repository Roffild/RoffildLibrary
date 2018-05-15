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
#include <Math/Alglib/matrix.mqh>

class CMLPDataFile
{
protected:
   int initWrite0(const string file, const int nin, const int nout, const string &_header[])
   {
      path = file;
      handleFile = FileOpen(path, FILE_BIN|FILE_WRITE|FILE_COMMON);
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, nin);
         FileWriteInteger(handleFile, nout);
         const int size = ArraySize(_header);
         FileWriteInteger(handleFile, size);
         for (int x = 0; x < size; x++) {
            FileWriteInteger(handleFile, StringLen(_header[x]));
            FileWriteString(handleFile, _header[x]);
         }
      }
      return handleFile;
   }

   int initRead0(const string file, int &nin, int &nout)
   {
      path = file;
      handleFile = FileOpen(path, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_COMMON);
      if (handleFile != INVALID_HANDLE) {
         nin = FileReadInteger(handleFile);
         nout = FileReadInteger(handleFile);
         const int size = FileReadInteger(handleFile);
         ArrayResize(header, size);
         for (int x = 0; x < size; x++) {
            header[x] = FileReadString(handleFile, FileReadInteger(handleFile));
         }
      }
      return handleFile;
   }

public:
   int handleFile;
   string path;
   string header[];

   CMLPDataFile() : handleFile(INVALID_HANDLE)
   {}

   ~CMLPDataFile()
   {
      close();
   }

   int initWrite(const int file, const int nin, const int nout)
   {
      ArrayResize(header, 0);
      return initWrite0("MLPData/mlp_" + (string)(file) + ".bin", nin, nout, header);
   }

   int initWrite(const int file, const int nin, const int nout, const string &_header[])
   {
      return initWrite0("MLPData/mlp_" + (string)(file) + ".bin", nin, nout, _header);
   }

   int initWriteValidation(const int file, const int nin, const int nout)
   {
      ArrayResize(header, 0);
      return initWrite0("MLPData/mlp_" + (string)(file) + "_validation.bin", nin, nout, header);
   }

   int initWriteValidation(const int file, const int nin, const int nout, const string &_header[])
   {
      return initWrite0("MLPData/mlp_" + (string)(file) + "_validation.bin", nin, nout, _header);
   }

   int initRead(const int file, int &nin, int &nout)
   {
      return initRead0("MLPData/mlp_" + (string)(file) + ".bin", nin, nout);
   }

   int initReadValidation(const int file, int &nin, int &nout)
   {
      return initRead0("MLPData/mlp_" + (string)(file) + "_validation.bin", nin, nout);
   }

   uint write(const double &data[])
   {
      const int size = ArraySize(data);
      if (size > 0 && handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, size);
         return FileWriteArray(handleFile, data);
      }
      return 0;
   }

   uint write(const CRowDouble &data)
   {
      uint count = 0;
      if (handleFile != INVALID_HANDLE) {
         double array[];
         convert(data, array);
         count += write(array);
      }
      return count;
   }

   uint write(const CMatrixDouble &data)
   {
      uint count = 0;
      if (handleFile != INVALID_HANDLE) {
         const int size = data.Size();
         if (size > 0) {
            if (data[0].Size() > 0) {
               for (int x = 0; x < size; x++) {
                  count += write(data[x]);
               }
            }
         }
      }
      return count;
   }

   uint read(double &data[], int &size)
   {
      if (handleFile != INVALID_HANDLE && FileIsEnding(handleFile) == false) {
         size = FileReadInteger(handleFile);
         return FileReadArray(handleFile, data, 0, size);
      }
      size = 0;
      return 0;
   }

   uint read(CMatrixDouble &data, const bool append = false)
   {
      const int reserve = 50000;
      uint count = 0;
      if (handleFile != INVALID_HANDLE) {
         int size1 = 0;
         int size2 = 0, sz = 0;
         if (append) {
            size1 = data.Size();
            if (size1 > 0) {
               size2 = data[0].Size();
            }
         }
         double dt[];
         data.Resize(size1 + reserve, size2);
         while (read(dt, sz) == sz && sz > 0) {
            size1++;
            if (sz > size2) {
               size2 = sz;
            }
            if ((size1 % reserve) == 0) {
               data.Resize(size1 + reserve, size2);
            }
            data[size1 - 1] = dt;
            count += sz;
         }
         data.Resize(size1, size2);
      }
      return count;
   }

   static void convert(const CRowDouble &data, double &array[])
   {
      const int size = data.Size();
      ArrayResize(array, size);
      if (size > 0) {
         for (int y = 0; y < size; y++) {
            array[y] = data[y];
         }
      }
   }

   void flush()
   {
      if (handleFile != INVALID_HANDLE) {
         FileFlush(handleFile);
      }
   }

   void close()
   {
      if (handleFile != INVALID_HANDLE) {
         FileClose(handleFile);
      }
   }

   static bool convertToCsv(const int file, const bool validation = false, const string delimiter = ";")
   {
      CMLPDataFile mlpfile();
      int nin, nout;
      if (validation) {
         mlpfile.initReadValidation(file, nin, nout);
      } else {
         mlpfile.initRead(file, nin, nout);
      }
      if (mlpfile.handleFile == INVALID_HANDLE) {
         return false;
      }
      string pcsv = mlpfile.path;
      StringReplace(pcsv, ".bin", ".csv");
      int hcsv = FileOpen(pcsv, FILE_CSV|FILE_ANSI|FILE_WRITE|FILE_COMMON, delimiter);
      if (hcsv != INVALID_HANDLE) {
         /// @BUG FileWriteArray not support CSV
         double data[];
         int x, size;
         if ((size = ArraySize(mlpfile.header)) > 0) {
            for (x = 0; x < (size - 1); x++) {
               FileWriteString(hcsv, mlpfile.header[x] + delimiter);
            }
            FileWrite(hcsv, mlpfile.header[size - 1]);
         }
         while (mlpfile.read(data, size) > 0) {
            for (x = 0; x < (size - 1); x++) {
               FileWriteString(hcsv, DoubleToString(data[x]) + delimiter);
            }
            FileWrite(hcsv, DoubleToString(data[size - 1]));
         }
         FileClose(hcsv);
         return true;
      }
      return false;
   }
};
