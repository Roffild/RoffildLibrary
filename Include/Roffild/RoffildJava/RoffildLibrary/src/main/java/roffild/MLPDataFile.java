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
import static roffild.mqlport.MqlLibrary.*;

public class MLPDataFile implements Closeable
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

   /**
    * @return Number of recorded items.
    */
   public long writeAll(final double data[][])
   {
      long count = 0;
      if (handleFile != INVALID_HANDLE) {
         final int size = data.length;
         if (size > 0) {
            if (data[0].length > 0) {
               for (int x = 0; x < size; x++) {
                  count += write(data[x]);
               }
            }
         }
      }
      return count;
   }

   public long read(MqlArray<Double> data, Pointer<Integer> size)
   {
      if (handleFile != INVALID_HANDLE && FileIsEnding(handleFile) == false) {
         size.value = FileReadInteger(handleFile);
         return FileReadArray(handleFile, data, 0, size.value);
      }
      size.value = 0;
      return 0;
   }

   /**
    * @return Number of elements read.
    */
   long readAll(MqlArray<Double[]> data)
   {
      return readAll(data, false);
   }
   long readAll(MqlArray<Double[]> data, final boolean append)
   {
      final int reserve = 50000;
      long count = 0;
      if (handleFile != INVALID_HANDLE) {
         int size1 = 0;
         Pointer<Integer> sz = new Pointer<>(0);
         if (append) {
            size1 = data.size();
         }
         MqlArray<Double> dt = new MqlArray<>();
         ArrayResize(data, size1 + reserve);
         Double to[] = new Double[0];
         while (read(dt, sz) == sz.value && sz.value > 0) {
            size1++;
            if ((size1 % reserve) == 0) {
               ArrayResize(data, size1 + reserve);
            }
            data.set(size1 - 1, dt.toArray(to));
            count += sz.value;
         }
         ArrayResize(data, size1);
      }
      return count;
   }

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
         handleFile = INVALID_HANDLE;
      }
   }

   public static boolean convertToCsv(final int file)
   {
      return convertToCsv(file, false, ";");
   }
   public static boolean convertToCsv(final int file, final boolean validation)
   {
      return convertToCsv(file, validation, ";");
   }
   public static boolean convertToCsv(final int file, final boolean validation, final String delimiter)
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
         MqlArray<Double> data = new MqlArray<>();
         int x;
         Pointer<Integer> size = new Pointer<>(0);
         if ((size.value = ArraySize(mlpfile.header)) > 0) {
            for (x = 0; x < (size.value - 1); x++) {
               FileWriteString(hcsv, mlpfile.header.get(x) + delimiter);
            }
            FileWrite(hcsv, mlpfile.header.get(size.value - 1));
         }
         while (mlpfile.read(data, size) > 0) {
            for (x = 0; x < (size.value - 1); x++) {
               FileWriteString(hcsv, DoubleToString(data.get(x)) + delimiter);
            }
            FileWrite(hcsv, DoubleToString(data.get(size.value - 1)));
         }
         FileClose(hcsv);
         return true;
      }
      return false;
   }

   public static double[] DoublesTodoubles(final Double[] doubles)
   {
      return DoublesTodoubles((Object[])doubles);
   }
   public static double[] DoublesTodoubles(final Object[] doubles)
   {
      double[] result = new double[doubles.length];
      for (int x = doubles.length - 1; x > -1; x--) {
         result[x] = (Double)(doubles[x]);
      }
      return result;
   }

   public static Double[] doublesToDoubles(final double[] doubles)
   {
      Double[] result = new Double[doubles.length];
      for (int x = doubles.length - 1; x > -1; x--) {
         result[x] = doubles[x];
      }
      return result;
   }

   @Override
   protected void finalize() throws Throwable
   {
      close();
      super.finalize();
   }
}
