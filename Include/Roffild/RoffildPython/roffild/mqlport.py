# Licensed under the Apache License, Version 2.0 (the "License")
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

import io
import os
import pathlib
import struct

INVALID_HANDLE = -1

CHAR_VALUE = 1
SHORT_VALUE = 2
INT_VALUE = 4

FILE_READ = 1
FILE_WRITE = 2
FILE_BIN = 4
FILE_CSV = 8
FILE_TXT = 16
FILE_ANSI = 32
FILE_UNICODE = 64
FILE_SHARE_READ = 128
FILE_SHARE_WRITE = 256
FILE_REWRITE = 512
FILE_COMMON = 4096

SEEK_SET = 0
SEEK_CUR = 1
SEEK_END = 2
"""
public static String typename(Class<?> clazz)
{
  Class<?> type = clazz.isArray() ? clazz.getComponentType() : clazz
  if (type.isAssignableFrom(Boolean.class)) {
     return "bool"
  }
  if (type.isAssignableFrom(Character.class)) {
     return "char"
  }
  if (type.isAssignableFrom(Short.class)) {
     return "short"
  }
  if (type.isAssignableFrom(Integer.class)) {
     return "int"
  }
  if (type.isAssignableFrom(Long.class)) {
     return "long"
  }
  if (type.isAssignableFrom(Float.class)) {
     return "float"
  }
  if (type.isAssignableFrom(Double.class)) {
     return "double"
  }
  if (type.isAssignableFrom(String.class)) {
     return "string"
  }
  return ""
}
"""


def ArraySize(array: list) -> int:
    return len(array)


def ArrayResize(array: list, new_size: int, reserve_size: int = 0) -> int:
    size = new_size + reserve_size
    count = len(array)
    if count > size:
        del array[size:count]
    elif count < size:
        array += [None for x in range(size - count)]
    return len(array)


def StringLen(string: str) -> int:
    return len(string)


def DoubleToString(value: float, digits: int = 8) -> str:
    return "{:.{digits}F}".format(value, digits=digits)


PATHFILES = ""
PATHFILESCOMMON = str(pathlib.Path(os.environ["APPDATA"], r"MetaQuotes\Terminal\Common\Files"))


def getPathFiles() -> str:
    return PATHFILES


def setPathFiles(pathFiles: str) -> None:
    global PATHFILES
    PATHFILES = pathFiles


def getPathFilesCommon() -> str:
    return PATHFILESCOMMON


def setPathFilesCommon(pathFilesCommon: str) -> None:
    global PATHFILESCOMMON
    PATHFILESCOMMON = pathFilesCommon


def FileOpen(file_name: str, open_flags: int, delimiter: str = "\t",
             codepage: int = 0) -> io.BufferedRandom or int:
    full_file_name = pathlib.Path(file_name)
    # os.path.isabs("\\Program Files") == True
    # pathlib.Path("\\Program Files").is_absolute() == False
    if os.path.isabs(full_file_name) == False:
        full_file_name = pathlib.Path(PATHFILESCOMMON if (open_flags & FILE_COMMON) != 0 else PATHFILES,
                                      file_name)
    mode = "r"
    if (open_flags & (FILE_WRITE | FILE_REWRITE)) != 0:
        mode = "w"
    cdpage = "UTF-16LE"
    if (open_flags & FILE_ANSI) != 0:
        cdpage = "cp" + str(codepage) if codepage != 0 else "UTF-8"
    try:
        if (open_flags & FILE_BIN) != 0:
            file = open(full_file_name, mode + "b")
            file.encoding = cdpage
            file.delimiter = delimiter if (open_flags & FILE_CSV) != 0 else ""
            file.binflag = True
            return file
        else:
            file = open(full_file_name, mode, encoding=cdpage, newline="\r\n")
            file.delimiter = delimiter if (open_flags & FILE_CSV) != 0 else ""
            file.binflag = False
            return file
    except:
        return INVALID_HANDLE


def FileClose(file_handle: io.BufferedRandom) -> None:
    file_handle.close()


def FileFlush(file_handle: io.BufferedRandom) -> None:
    file_handle.flush()


def FileSeek(file_handle: io.BufferedRandom, offset: int, origin: int) -> bool:
    file_handle.seek(offset, origin)
    return True


def FileTell(file_handle: io.BufferedRandom) -> int:
    return file_handle.tell()


def FileIsEnding(file_handle: io.BufferedRandom) -> bool:
    return (file_handle.peek() == 0)


def FileWriteInteger(file_handle: io.BufferedRandom, value: int, size: int = INT_VALUE) -> int:
    if size < CHAR_VALUE or size > INT_VALUE:
        raise Exception("Size error")
    file_handle.write(int(value).to_bytes(size, byteorder="little", signed=False))
    return size


def FileReadInteger(file_handle: io.BufferedRandom, size: int = INT_VALUE) -> int:
    if size < CHAR_VALUE or size > INT_VALUE:
        raise Exception("Size error")
    return int.from_bytes(file_handle.read(size), byteorder="little", signed=False)


def FileWriteLong(file_handle: io.BufferedRandom, value: int) -> int:
    file_handle.write(int(value).to_bytes(8, byteorder="little", signed=False))
    return 8


def FileReadLong(file_handle: io.BufferedRandom) -> int:
    return int.from_bytes(file_handle.read(8), byteorder="little", signed=False)


def FileWriteFloat(file_handle: io.BufferedRandom, value: float) -> int:
    file_handle.write(struct.pack("<f", value))
    return 4


def FileReadFloat(file_handle: io.BufferedRandom) -> float:
    return struct.unpack("<f", file_handle.read(4))[0]


def FileWriteDouble(file_handle: io.BufferedRandom, value: float) -> int:
    file_handle.write(struct.pack("<d", value))
    return 8


def FileReadDouble(file_handle: io.BufferedRandom) -> float:
    return struct.unpack("<d", file_handle.read(8))[0]


def FileWriteString(file_handle: io.BufferedRandom, text: str, length: int = -1) -> int:
    if length != -1:
        text = text[:length]
    length = len(text)
    if file_handle.binflag:
        file_handle.write(text.encode(file_handle.encoding))
    else:
        file_handle.write(text)
    return length


def FileWrite(file_handle: io.BufferedRandom, *args) -> int:
    string = ""
    for x in range(len(args) - 1):
        string += str(args[x]) + file_handle.delimiter
    string += str(args[-1]) + "\n"
    return FileWriteString(file_handle, string)


def FileReadString(file_handle: io.BufferedRandom, length: int = -1) -> str:
    if file_handle.binflag:
        if length < 1:
            return ""
        return file_handle.read(len("a".encode(file_handle.encoding)) * length).decode(file_handle.encoding)
    return file_handle.readline(length)


def FileWriteArray(file_handle: io.BufferedRandom, array: list,
                   array_type: str, start: int = 0, count: int = -1) -> int:
    if start < 0 or count < -1:
        raise Exception("start < 0 || count < -1")
    if count == -1:
        count = len(array) - start
    else:
        count += start
    cbytes = 0
    if array_type == "char":
        for x in range(start, count):
            cbytes += FileWriteInteger(file_handle, array[x], CHAR_VALUE)
    elif array_type == "short":
        for x in range(start, count):
            cbytes += FileWriteInteger(file_handle, array[x], SHORT_VALUE)
    elif array_type == "int":
        for x in range(start, count):
            cbytes += FileWriteInteger(file_handle, array[x], INT_VALUE)
    elif array_type == "long":
        for x in range(start, count):
            cbytes += FileWriteLong(file_handle, array[x])
    elif array_type == "float":
        for x in range(start, count):
            cbytes += FileWriteFloat(file_handle, array[x])
    elif array_type == "double":
        for x in range(start, count):
            cbytes += FileWriteDouble(file_handle, array[x])
    else:
        raise Exception("Is unknown type")
    return cbytes


def FileReadArray(file_handle: io.BufferedRandom, array: list,
                  array_type: str, start: int = 0, count: int = -1) -> int:
    if start < 0 or count < -1:
        raise Exception("start < 0 || count < -1")
    if count == -1:
        count = len(array) - start
    else:
        count += start
    ArrayResize(array, start, count)
    if array_type == "char":
        for x in range(start, count):
            array[x] = FileReadInteger(file_handle, CHAR_VALUE)
    elif array_type == "short":
        for x in range(start, count):
            array[x] = FileReadInteger(file_handle, SHORT_VALUE)
    elif array_type == "int":
        for x in range(start, count):
            array[x] = FileReadInteger(file_handle, INT_VALUE)
    elif array_type == "long":
        for x in range(start, count):
            array[x] = FileReadLong(file_handle)
    elif array_type == "float":
        for x in range(start, count):
            array[x] = FileReadFloat(file_handle)
    elif array_type == "double":
        for x in range(start, count):
            array[x] = FileReadDouble(file_handle)
    else:
        raise Exception("Is unknown type")
    return len(array) - start
