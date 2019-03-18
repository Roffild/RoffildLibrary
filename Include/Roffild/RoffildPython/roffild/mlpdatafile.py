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

"""/**
 * MLPDataFile = CSV in a binary format
 *
 * The byte order is Little-Endian.
 *
 * Format:
 * @code
 * - NIn (only for Alglib_MultilayerPerceptron and Alglib_RandomForest)
 * - NOut (only for Alglib_MultilayerPerceptron and Alglib_RandomForest)
 * - header size
 *    if header size > 0:
 *       - length of string
 *       byte[] - UTF-16LE
 *       ...
 *    }
 * - data size
 * double[data size] - data array
 * ...
 * @endcode
 */
"""

from .mqlport import *


class MLPDataFile():
    """/**
     * @param file path of file
     * @param[in] nin NIn
     * @param[in] nout NOut
     * @param[in] _header
     * @return self.handleFile
     */"""

    def initWrite0(self, file: str, nin: int, nout: int, _header: list) -> int:
        self.path = file;
        self.handleFile = FileOpen(self.path, FILE_BIN | FILE_WRITE | FILE_COMMON);
        if self.handleFile != INVALID_HANDLE:
            FileWriteInteger(self.handleFile, nin);
            FileWriteInteger(self.handleFile, nout);
            size = ArraySize(_header);
            FileWriteInteger(self.handleFile, size);
            for x in range(0, size):
                FileWriteInteger(self.handleFile, StringLen(_header[x]));
                FileWriteString(self.handleFile, _header[x]);
        return self.handleFile;

    """/**
     * @param file path of file
     * @param[out] nin NIn
     * @param[out] nout NOut
     * @return self.handleFile
     */"""

    def initRead0(self, file: str, nin: list, nout: list) -> int:
        self.path = file;
        self.handleFile = FileOpen(self.path, FILE_BIN | FILE_READ | FILE_SHARE_READ | FILE_COMMON);
        if self.handleFile != INVALID_HANDLE:
            nin[0] = FileReadInteger(self.handleFile);
            nout[0] = FileReadInteger(self.handleFile);
            size = FileReadInteger(self.handleFile);
            ArrayResize(self.header, size);
            for x in range(size):
                self.header[x] = FileReadString(self.handleFile, FileReadInteger(self.handleFile));
        return self.handleFile;

    handleFile = INVALID_HANDLE;
    path = "";
    header = [];

    def __del__(self):
        self.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def __iter__(self):
        return self

    def __next__(self):
        if self.handleFile != INVALID_HANDLE:
            sz = [0]
            dt = []
            if self.read(dt, sz) == sz[0] and sz[0] > 0:
                return dt
        raise StopIteration

    """/**
     * @param file number of file
     * @param[in] nin NIn
     * @param[in] nout NOut
     * @return self.handleFile
     */"""

    def initWrite(self, file: int, nin: int, nout: int) -> int:
        ArrayResize(self.header, 0);
        return self.initWrite0("MLPData/mlp_" + str(file) + ".bin", nin, nout, self.header);

    """/**
     * @param file number of file
     * @param[in] nin NIn
     * @param[in] nout NOut
     * @param[in] _header
     * @return self.handleFile
     */"""

    def initWrite(self, file: int, nin: int, nout: int, _header: list) -> int:
        return self.initWrite0("MLPData/mlp_" + str(file) + ".bin", nin, nout, _header);

    """/**
     * @param file number of file
     * @param[in] nin NIn
     * @param[in] nout NOut
     * @return self.handleFile
     */"""

    def initWriteValidation(self, file: int, nin: int, nout: int) -> int:
        ArrayResize(self.header, 0);
        return self.initWrite0("MLPData/mlp_" + str(file) + "_validation.bin", nin, nout, self.header);

    """/**
     * @param file number of file
     * @param[in] nin NIn
     * @param[in] nout NOut
     * @param[in] _header
     * @return self.handleFile
     */"""

    def initWriteValidation(self, file: int, nin: int, nout: int, _header: list) -> int:
        return self.initWrite0("MLPData/mlp_" + str(file) + "_validation.bin", nin, nout, _header);

    """/**
     * @param file number of file
     * @param[out] nin NIn
     * @param[out] nout NOut
     * @return self.handleFile
     */"""

    def initRead(self, file: int, nin: list, nout: list) -> int:
        return self.initRead0("MLPData/mlp_" + str(file) + ".bin", nin, nout);

    """/**
     * @param file number of file
     * @param[out] nin NIn
     * @param[out] nout NOut
     * @return self.handleFile
     */"""

    def initReadValidation(self, file: int, nin: list, nout: list) -> int:
        return self.initRead0("MLPData/mlp_" + str(file) + "_validation.bin", nin, nout);

    """/**
     * @return Number of recorded items.
     */"""

    def write(self, data: list) -> int:
        size = ArraySize(data);
        if size > 0 and self.handleFile != INVALID_HANDLE:
            FileWriteInteger(self.handleFile, size);
            return FileWriteArray(self.handleFile, data, "double");
        return 0;

    """/**
     * @return Number of recorded items.
     */

    def write(self, data):
        count = 0;
        if self.handleFile != INVALID_HANDLE:
            array: float = [];
            self.convert(data, array);
            count += self.write(array);
        return count;"""

    """/**
     * @return Number of recorded items.
     */"""

    def writeAll(self, data: [[]]) -> int:
        count = 0;
        if self.handleFile != INVALID_HANDLE:
            size = len(data);
            if size > 0:
                if len(data[0]) > 0:
                    for x in range(0, size):
                        count += self.write(data[x]);
        return count;

    """/**
     * @return Number of elements read.
     */"""

    def read(self, data: list, size: list) -> int:
        if self.handleFile != INVALID_HANDLE and FileIsEnding(self.handleFile) == False:
            size[0] = FileReadInteger(self.handleFile);
            return FileReadArray(self.handleFile, data, "double", 0, size[0]);
        size[0] = 0;
        return 0;

    """/**
     * @return Number of elements read.
     */"""

    def readAll(self, data: [[]], append: bool = False) -> int:
        count = 0
        if self.handleFile != INVALID_HANDLE:
            sz = [0]
            if append == False:
                data.clear()
            dt = []
            while self.read(dt, sz) == sz[0] and sz[0] > 0:
                data += [dt]
                count += sz[0]
                dt = []
        return count

    """
    @staticmethod
    def convert(data, array):
        size = data.Size();
        ArrayResize(array, size);
        if size > 0:
            for y in range(0, size - 1):
                array[y] = data[y];
    """

    def flush(self) -> None:
        if self.handleFile != INVALID_HANDLE:
            FileFlush(self.handleFile);

    def close(self) -> None:
        if self.handleFile != INVALID_HANDLE:
            FileClose(self.handleFile);
            self.handleFile = INVALID_HANDLE;

    @staticmethod
    def convertToCsv(file: int, validation: bool = False, delimiter: str = ";") -> bool:
        mlpfile = MLPDataFile();
        nin = [0];
        nout = [0];
        if validation:
            mlpfile.initReadValidation(file, nin, nout);
        else:
            mlpfile.initRead(file, nin, nout);
        if mlpfile.handleFile == INVALID_HANDLE:
            return False;
        pcsv = mlpfile.path.replace(".bin", ".csv");
        hcsv = FileOpen(pcsv, FILE_CSV | FILE_ANSI | FILE_WRITE | FILE_COMMON, delimiter);
        if hcsv != INVALID_HANDLE:
            # BUG FileWriteArray not support CSV
            data = [];
            size = [ArraySize(mlpfile.header)];
            if size[0] > 0:
                for x in range(size[0] - 1):
                    FileWriteString(hcsv, mlpfile.header[x] + delimiter);
                FileWrite(hcsv, mlpfile.header[size[0] - 1]);
            while mlpfile.read(data, size) > 0:
                for x in range(size[0] - 1):
                    FileWriteString(hcsv, DoubleToString(data[x]) + delimiter);
                FileWrite(hcsv, DoubleToString(data[size[0] - 1]));
            FileClose(hcsv);
            return True;
        return False;

    @staticmethod
    def getPathFiles() -> str:
        return getPathFiles()

    @staticmethod
    def setPathFiles(pathFiles: str) -> None:
        setPathFiles(pathFiles)

    @staticmethod
    def getPathFilesCommon() -> str:
        return getPathFilesCommon()

    @staticmethod
    def setPathFilesCommon(pathFilesCommon: str) -> None:
        setPathFilesCommon(pathFilesCommon)
