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


try:
    sys.__stdin__ = sys.stdin = open('CONIN$', 'rt')
    sys.__stdout__ = sys.stdout = open('CONOUT$', 'wt')
    sys.__stderr__ = sys.stderr = open('CONOUT$', 'wt')
except:
    pass

gc.set_debug(gc.DEBUG_SAVEALL)  # Bug in PyGC_Collect()
__mql_stderr__ = __mql_stderr_class__()
__name__ = '__mql__'


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
