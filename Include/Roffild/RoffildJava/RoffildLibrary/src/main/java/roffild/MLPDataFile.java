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
package roffild;

import roffild.mqlport.MqlArray;
import roffild.mqlport.MqlLibrary;
import roffild.mqlport.Pointer;

import java.io.Closeable;

public class MLPDataFile extends MqlLibrary implements Closeable
{
   public int initWrite0(final String file, final int nin, final int nout, final String _header[])
   {
      path = file;
      handleFile = FileOpen(path, FILE_BIN|FILE_WRITE|FILE_COMMON);
      if (handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, nin);
         FileWriteInteger(handleFile, nout);
         final int size = ArraySize(_header);
         FileWriteInteger(handleFile, size);
         for (int x = 0; x < size; x++) {
            FileWriteInteger(handleFile, StringLen(_header[x]));
            FileWriteString(handleFile, _header[x]);
         }
      }
      return handleFile;
   }

   public int initRead0(final String file, Pointer<Integer> nin, Pointer<Integer> nout)
   {
      path = file;
      handleFile = FileOpen(path, FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_COMMON);
      if (handleFile != INVALID_HANDLE) {
         nin.value = FileReadInteger(handleFile);
         nout.value = FileReadInteger(handleFile);
         final int size = FileReadInteger(handleFile);
         ArrayResize(header, size);
         for (int x = 0; x < size; x++) {
            header.set(x, FileReadString(handleFile, FileReadInteger(handleFile)));
         }
      }
      return handleFile;
   }

   public int handleFile = INVALID_HANDLE;
   public String path = "";
   public MqlArray<String> header = new MqlArray<>();

   public int initWrite(final int file, final int nin, final int nout)
   {
      ArrayResize(header, 0);
      return initWrite0("MLPData/mlp_" + Integer.toString(file) + ".bin", nin, nout, new String[0]);
   }

   public int initWrite(final int file, final int nin, final int nout, final String _header[])
   {
      return initWrite0("MLPData/mlp_" + Integer.toString(file) + ".bin", nin, nout, _header);
   }

   public int initWriteValidation(final int file, final int nin, final int nout)
   {
      ArrayResize(header, 0);
      return initWrite0("MLPData/mlp_" + Integer.toString(file) + "_validation.bin", nin, nout, new String[0]);
   }

   public int initWriteValidation(final int file, final int nin, final int nout, final String _header[])
   {
      return initWrite0("MLPData/mlp_" + Integer.toString(file) + "_validation.bin", nin, nout, _header);
   }

   public int initRead(final int file, Pointer<Integer> nin, Pointer<Integer> nout)
   {
      return initRead0("MLPData/mlp_" + Integer.toString(file) + ".bin", nin, nout);
   }

   public int initReadValidation(final int file, Pointer<Integer> nin, Pointer<Integer> nout)
   {
      return initRead0("MLPData/mlp_" + Integer.toString(file) + "_validation.bin", nin, nout);
   }

   public long write(final double data[])
   {
      final int size = data.length;
      if (size > 0 && handleFile != INVALID_HANDLE) {
         FileWriteInteger(handleFile, size);
         return FileWriteArray(handleFile, data);
      }
      return 0;
   }

   /*long write(final CRowDouble &data)
   {
      long count = 0;
      if (handleFile != INVALID_HANDLE) {
         double array[];
         convert(data, array);
         count += write(array);
      }
      return count;
   }

   long write(final CMatrixDouble &data)
   {
      long count = 0;
      if (handleFile != INVALID_HANDLE) {
         final int size = data.Size();
         if (size > 0) {
            if (data[0].Size() > 0) {
               for (int x = 0; x < size; x++) {
                  count += write(data[x]);
               }
            }
         }
      }
      return count;
   }*/

   public long read(MqlArray<Double> data, Pointer<Integer> size)
   {
      if (handleFile != INVALID_HANDLE && FileIsEnding(handleFile) == false) {
         size.value = FileReadInteger(handleFile);
         return FileReadArray(handleFile, data, 0, size.value);
      }
      size.value = 0;
      return 0;
   }

   /*long read(CMatrixDouble &data, final bool append = false)
   {
      final int reserve = 50000;
      long count = 0;
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

   static void convert(final CRowDouble &data, double &array[])
   {
      final int size = data.Size();
      ArrayResize(array, size);
      if (size > 0) {
         for (int y = 0; y < size; y++) {
            array[y] = data[y];
         }
      }
   }*/

   public void flush()
   {
      if (handleFile != INVALID_HANDLE) {
         FileFlush(handleFile);
      }
   }

   @Override
   public void close()
   {
      if (handleFile != INVALID_HANDLE) {
         FileClose(handleFile);
      }
   }

   /*public boolean convertToCsv(final int file)
   {
      return convertToCsv(file, false, ";");
   }
   public boolean convertToCsv(final int file, final boolean validation)
   {
      return convertToCsv(file, validation, ";");
   }
   public boolean convertToCsv(final int file, final boolean validation, final String delimiter)
   {
      MLPDataFile mlpfile = new MLPDataFile();
      Pointer<Integer> nin = new Pointer<>(0);
      Pointer<Integer> nout = new Pointer<>(0);
      if (validation) {
         mlpfile.initReadValidation(file, nin, nout);
      } else {
         mlpfile.initRead(file, nin, nout);
      }
      if (mlpfile.handleFile == INVALID_HANDLE) {
         return false;
      }
      String pcsv = mlpfile.path;
      pcsv = pcsv.replace(".bin", ".csv");
      int hcsv = FileOpen(pcsv, FILE_CSV|FILE_ANSI|FILE_WRITE|FILE_COMMON, delimiter);
      if (hcsv != INVALID_HANDLE) {
         /// @BUG FileWriteArray not support CSV
         double data[];
         int x, size;
         if ((size = ArraySize(mlpfile.header)) > 0) {
            for (x = 0; x < (size - 1); x++) {
               FileWriteString(hcsv, mlpfile.header.get(x) + delimiter);
            }
            FileWrite(hcsv, mlpfile.header[size - 1]);
         }
         while (mlpfile.read(data, size) > 0) {
            for (x = 0; x < (size - 1); x++) {
               FileWriteString(hcsv, Double.toString(data[x]) + delimiter);
            }
            FileWrite(hcsv, Double.toString(data[size - 1]));
         }
         FileClose(hcsv);
         return true;
      }
      return false;
   }*/

   @Override
   protected void finalize() throws Throwable
   {
      close();
      super.finalize();
   }
}
