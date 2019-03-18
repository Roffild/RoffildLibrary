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

import sys
import os

class PythonDLL_Example():
    def getLong(self, magic: int, value: int, array: tuple) -> tuple or list:
        raise NotImplementedError

    def getULong(self, magic: int, value: int, array: tuple) -> tuple or list:
        raise NotImplementedError

    def getDouble(self, magic: int, value: float, array: tuple) -> tuple or list:
        return [(array[1] + array[2]) / 2.0]

    def getString(self, magic: int, value: str, array: bytes) -> str:
        if magic == 1:
            return value + str(sys.version)
        if magic == 2:
            return str(array) + " " + str(sys.version_info)
        if magic == 3:
            return "sys.path:\n" + "\n".join(sys.path) + \
                   "os.environ[\"PATH\"]:\n" + os.environ["PATH"].replace(";", "\n")
        raise Exception("This is not a bug! This is a feature :D")


__mql__ = PythonDLL_Example()
