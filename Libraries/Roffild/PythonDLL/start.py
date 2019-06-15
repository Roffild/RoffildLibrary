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

import io
import sys
import gc


class __mql_stderr_class__(io.StringIO):
    def truncate_fix(self):
        self.seek(0, 0)
        self.truncate(0)


class __stdnull__():
    def close(self, *args, **kwargs):
        pass

    def fileno(self, *args, **kwargs):
        pass

    def flush(self, *args, **kwargs):
        pass

    def isatty(self, *args, **kwargs):
        return False

    def readable(self, *args, **kwargs):
        return False

    def readline(self, *args, **kwargs):
        return ''

    def readlines(self, *args, **kwargs):
        return ['']

    def seek(self, *args, **kwargs):
        return 0

    def seekable(self, *args, **kwargs):
        return False

    def tell(self, *args, **kwargs):
        return 0

    def truncate(self, *args, **kwargs):
        return 0

    def writable(self, *args, **kwargs):
        return False

    def writelines(self, *args, **kwargs):
        pass

    def _checkClosed(self, *args, **kwargs):
        pass

    def _checkReadable(self, *args, **kwargs):
        pass

    def _checkSeekable(self, *args, **kwargs):
        pass

    def _checkWritable(self, *args, **kwargs):
        pass

    def detach(self, *args, **kwargs):
        pass

    def read(self, *args, **kwargs):
        pass

    def write(self, *args, **kwargs):
        pass

    def reconfigure(self, *args, **kwargs):
        pass

    closed = property(lambda self: False, lambda self, v: None, lambda self: None)
    encoding = property(lambda self: 'UTF-8', lambda self, v: None, lambda self: None)
    errors = property(lambda self: object(), lambda self, v: None, lambda self: None)
    newlines = property(lambda self: object(), lambda self, v: None, lambda self: None)
    buffer = property(lambda self: object(), lambda self, v: None, lambda self: None)
    line_buffering = property(lambda self: False, lambda self, v: None, lambda self: None)
    name = property(lambda self: '<stdnull>', lambda self, v: None, lambda self: None)
    write_through = property(lambda self: True, lambda self, v: None, lambda self: None)
    _CHUNK_SIZE = property(lambda self: 8192, lambda self, v: None, lambda self: None)
    _finalizing = property(lambda self: False, lambda self, v: None, lambda self: None)


if sys.stdin is None:
    sys.__stdin__ = sys.stdin = __stdnull__()
if sys.stdout is None:
    sys.__stdout__ = sys.stdout = __stdnull__()
if sys.stderr is None:
    sys.__stderr__ = sys.stderr = __stdnull__()

try:
    sys.__stdin__ = sys.stdin = open('CONIN$', 'rt')
    sys.__stdout__ = sys.stdout = open('CONOUT$', 'wt')
    sys.__stderr__ = sys.stderr = open('CONOUT$', 'wt')
except:
    pass

gc.set_debug(gc.DEBUG_SAVEALL)  # Bug in PyGC_Collect()
__mql_stderr__ = __mql_stderr_class__()
__PythonDLL__ = True


#############################

class MQL():
    def getLong(self, magic: int, value: int, array: tuple) -> tuple or list:
        raise NotImplementedError

    def getULong(self, magic: int, value: int, array: tuple) -> tuple or list:
        raise NotImplementedError

    def getDouble(self, magic: int, value: float, array: tuple) -> tuple or list:
        raise NotImplementedError

    def getString(self, magic: int, value: str, array: bytes) -> str:
        raise NotImplementedError


__mql__ = MQL()
