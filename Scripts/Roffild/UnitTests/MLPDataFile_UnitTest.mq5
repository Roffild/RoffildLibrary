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
   CMatrixDouble data;

   CUnitTest_FUNC(1)
   {
      testName = "Write";
      data.Resize(50, 35);
      double dt[35];
      MathSrand(uint(GetMicrosecondCount()));
      filenum = INT_MAX;
      nin = MathRand();
      nout = MathRand();
      for (int x = 0; x < 50; x++) {
         for (int y = 0; y < 35; y++) {
            dt[y] = MathRand();
         }
         data[x] = dt;
      }
      CMLPDataFile dfile;
      dfile.initWrite(filenum, nin, nout);
      dfile.write(data);
      return true;
   }

   CUnitTest_FUNC(2)
   {
      testName = "Read";
      int _nin, _nout;
      CMatrixDouble _data;
      CMLPDataFile dfile;
      dfile.initRead(filenum, _nin, _nout);
      dfile.read(_data);
      if (nin != _nin || nout != _nout) {
         return false;
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
      int shift = 15;
      _data.Resize(shift, 50);
      CMLPDataFile dfile;
      dfile.initRead(filenum, _nin, _nout);
      dfile.read(_data, true);
      if (nin != _nin || nout != _nout) {
         return false;
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
};

void OnStart()
{
   CMLPDataFileTest test();
   test.run();
}
