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

import org.junit.Assert;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import roffild.mqlport.MqlArray;
import roffild.mqlport.Pointer;

import static roffild.mqlport.MqlLibrary.INVALID_HANDLE;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class MLPDataFileTest
{
   final int filenum = 2147483645;
   final int nin = 33;
   final int nout = 2;
   static String header[] = new String[35];
   static double data[][] = new double[50][35];

   @Test
   public void test01_Write()
   {
      for (int x = 0; x < 35; x++) {
         header[x] = "col" + Integer.toString(x);
      }
      for (int x = 0; x < 50; x++) {
         for (int y = 0; y < 35; y++) {
            data[x][y] = (nin * nout + x * y) / 5.55;
         }
      }
      try (MLPDataFile dfile = new MLPDataFile()) {
         Assert.assertFalse(dfile.initWrite(filenum, nin, nout, header) == INVALID_HANDLE);
         dfile.writeAll(data);
      }
      MLPDataFile.convertToCsv(filenum);
   }

   @Test
   public void test02_Read()
   {
      Pointer<Integer> _nin = new Pointer<>(0);
      Pointer<Integer> _nout = new Pointer<>(0);
      MqlArray<Double[]> _data = new MqlArray<>();
      MLPDataFile dfile = new MLPDataFile();
      dfile.initRead(filenum, _nin, _nout);
      dfile.readAll(_data);
      Assert.assertFalse(nin != _nin.value || nout != _nout.value);
      Assert.assertArrayEquals(header, dfile.header.toArray(new String[0]));
      Assert.assertFalse(data.length != _data.size());
      for (int x = 0; x < 50; x++) {
         for (int y = 0; y < 35; y++) {
            Assert.assertEquals(data[x][y], _data.get(x)[y], 1e-8);
         }
      }
   }

   @Test
   public void test03_ReadAppend()
   {
      Pointer<Integer> _nin = new Pointer<>(0);
      Pointer<Integer> _nout = new Pointer<>(0);
      MqlArray<Double[]> _data = new MqlArray<>();
      final int shift = 15;
      _data.resize(shift, 0);
      MLPDataFile dfile = new MLPDataFile();
      dfile.initRead(filenum, _nin, _nout);
      dfile.readAll(_data, true);
      Assert.assertFalse(nin != _nin.value || nout != _nout.value);
      Assert.assertArrayEquals(header, dfile.header.toArray(new String[0]));
      Assert.assertFalse(data.length != (_data.size() - shift));
      for (int x = 0; x < 50; x++) {
         for (int y = 0; y < 35; y++) {
            Assert.assertEquals(data[x][y], _data.get(x + shift)[y], 1e-8);
         }
      }
   }
}
