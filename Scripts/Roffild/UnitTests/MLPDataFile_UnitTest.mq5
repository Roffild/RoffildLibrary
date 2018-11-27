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

#include <Roffild/UnitTest.mqh>

#include <Roffild/MLPDataFile.mqh>

class CMLPDataFileTest : public CUnitTest
{
public:
   void run(string name = "")
   {
      CUnitTest::run(name != "" ? name : "MLPDataFile");
   }

protected:
   int filenum, nin, nout;
   string header[35];
   CMatrixDouble data;

   CUnitTest_FUNC(1)
   {
      testName = "Write";
      data.Resize(50, 35);
      double dt[35];
      filenum = INT_MAX;
      nin = 33;
      nout = 2;
      for (int x = 0; x < 35; x++) {
         header[x] = "col" + string(x);
      }
      for (int x = 0; x < 50; x++) {
         for (int y = 0; y < 35; y++) {
            dt[y] = (nin * nout + x * y) / 5.55;
         }
         data[x] = dt;
      }
      CMLPDataFile dfile;
      if (dfile.initWrite(filenum, nin, nout, header) == INVALID_HANDLE) {
         return false;
      }
      dfile.writeAll(data);
      dfile.close();
      dfile.convertToCsv(filenum);
      return true;
   }

   CUnitTest_FUNC(2)
   {
      testName = "Read";
      int _nin, _nout;
      CMatrixDouble _data;
      CMLPDataFile dfile;
      dfile.initRead(filenum, _nin, _nout);
      dfile.readAll(_data);
      if (nin != _nin || nout != _nout) {
         return false;
      }
      for (int x = 0; x < 35; x++) {
         if (header[x] != dfile.header[x]) {
            return false;
         }
      }
      if (data.Size() != _data.Size()) {
         return false;
      }
      for (int x = 0; x < 50; x++) {
         for (int y = 0; y < 35; y++) {
            if (NormalizeDouble(data[x][y] - _data[x][y], 8) != 0) {
               return false;
            }
         }
      }
      return true;
   }

   CUnitTest_FUNC(3)
   {
      testName = "Read (append)";
      int _nin, _nout;
      CMatrixDouble _data;
      const int shift = 15;
      _data.Resize(shift, 50);
      CMLPDataFile dfile;
      dfile.initRead(filenum, _nin, _nout);
      dfile.readAll(_data, true);
      if (nin != _nin || nout != _nout) {
         return false;
      }
      for (int x = 0; x < 35; x++) {
         if (header[x] != dfile.header[x]) {
            return false;
         }
      }
      if (data.Size() != (_data.Size() - shift)) {
         return false;
      }
      for (int x = 0; x < 50; x++) {
         for (int y = 0; y < 35; y++) {
            if (NormalizeDouble(data[x][y] - _data[x + shift][y], 8) != 0) {
               return false;
            }
         }
      }
      return true;
   }

   CUnitTest_FUNC(10)
   {
      testName = "Read from Java";
      filenum = 2147483645;
      string tm;
      return test_2(tm);
   }
};

void OnStart()
{
   CMLPDataFileTest test();
   test.run();
}
