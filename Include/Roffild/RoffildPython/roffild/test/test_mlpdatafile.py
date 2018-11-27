# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# https://github.com/Roffild/RoffildLibrary
# ==============================================================================

import unittest
from roffild.mlpdatafile import MLPDataFile


class MLPDataFileTest(unittest.TestCase):
    filenum = 2147483646
    nin = 33
    nout = 2
    header = ["col" + str(x) for x in range(35)]
    data = []

    def test01_Write(self):
        for x in range(50):
            self.data += [[(self.nin * self.nout + x * y) / 5.55 for y in range(35)]]
        with MLPDataFile() as dfile:
            self.assertFalse(dfile.initWrite(self.filenum, self.nin, self.nout, self.header) == -1)
            dfile.writeAll(self.data)
        MLPDataFile.convertToCsv(self.filenum)

    def test02_Read(self):
        _nin = [0]
        _nout = [0]
        _data = []
        dfile = MLPDataFile()
        dfile.initRead(self.filenum, _nin, _nout)
        dfile.readAll(_data)
        self.assertFalse(self.nin != _nin[0] or self.nout != _nout[0])
        self.assertSequenceEqual(self.header, dfile.header)
        self.assertFalse(len(self.data) != len(_data))
        for x in range(50):
            for y in range(35):
                self.assertAlmostEqual(self.data[x][y], _data[x][y])

    def test03_ReadAppend(self):
        _nin = [0]
        _nout = [0]
        shift = 15
        _data = [[999] for x in range(shift)]
        dfile = MLPDataFile()
        dfile.initRead(self.filenum, _nin, _nout)
        dfile.readAll(_data, True)
        self.assertFalse(self.nin != _nin[0] or self.nout != _nout[0])
        self.assertSequenceEqual(self.header, dfile.header)
        self.assertFalse(len(self.data) != (len(_data) - shift))
        for x in range(50):
            for y in range(35):
                self.assertAlmostEqual(self.data[x][y], _data[x + shift][y])


if __name__ == "__main__":
    unittest.main()
