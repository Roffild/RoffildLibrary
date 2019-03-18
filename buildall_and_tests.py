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

import os
import shutil
import subprocess as proc
import sys
import unittest
from configparser import ConfigParser
from pathlib import Path

CURDIR = Path(__file__).parent.joinpath("_buildall")


def search(glob_pattern):
    for path in CURDIR.glob(glob_pattern):
        return path
    return None


def searchInPF(glob_pattern):
    for path in Path(os.environ["ProgramW6432"]).glob(glob_pattern):
        return path
    for path in Path(os.environ["ProgramFiles(x86)"]).glob(glob_pattern):
        return path
    return None


def environmentWrite(fpath):
    with open(fpath, "w", encoding="utf-16le") as cfg:
        cfg.write("\uFEFF")  # 0xFFFE - in file
        cfg.write("Windows Registry Editor Version 5.00\n\n")
        cfg.write("#[HKEY_CURRENT_USER\Environment]\n")
        cfg.write("[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment]\n")
        cfg.write('"PYTHONHOME"="' + str(sys.prefix).replace("\\", "\\\\") + '"\n')
        env = os.environ.get("MT5_HOME")
        if env is None:
            for env in Path(os.environ["ProgramFiles"]).rglob("metaeditor64.exe"):
                env = env.parent
                break
        cfg.write('"MT5_HOME"="' + str(env).replace("\\", "\\\\") + '"\n')
        env = os.environ.get("JAVA_HOME")
        if env is None:
            for env in Path(os.environ["ProgramFiles"]).rglob("java.exe"):
                env = env.parent
                break
        cfg.write('"JAVA_HOME"="' + str(env).replace("\\", "\\\\") + '"\n')
        env = os.environ.get("JAVA_TOOL_OPTIONS")
        if env is None:
            env = "-Xmx9g"
        cfg.write('"JAVA_TOOL_OPTIONS"="' + str(env).replace("\\", "\\\\") + '"\n')
        env = os.environ.get("GRADLE_USER_HOME")
        if env is None:
            cfg.write('# "GRADLE_USER_HOME"=""\n')
        env = os.environ.get("HADOOP_HOME")
        if env is None:
            env = ""
        cfg.write('# %HADOOP_HOME%\\bin\winutils.exe\n# https://github.com/steveloughran/winutils\n')
        cfg.write('"HADOOP_HOME"="' + str(env).replace("\\", "\\\\") + '"\n')
        env = os.environ.get("SPARK_HOME")
        if env is None:
            env = ""
        cfg.write('"SPARK_HOME"="' + str(env).replace("\\", "\\\\") + '"\n')
        env = os.environ.get("SPARK_LOCAL_DIRS")
        if env is None:
            env = ""
        cfg.write('"SPARK_LOCAL_DIRS"="' + str(env).replace("\\", "\\\\") + '"\n')


def environmentRead(fpath):
    with open(fpath, "r", encoding="utf-16le") as cfg:
        cfg.readline()
        source = "[env]\n"
        for line in cfg:
            kv = line.split("=", 1)
            if len(kv) > 1:
                source += kv[0].strip("\" \n") + "=" + kv[1].strip("\" \n") + "\n"
        print(source)
        parser = ConfigParser()
        parser.read_string(source)
        for k in parser.options("env"):
            os.environ[k.upper()] = str(parser.get("env", k, raw=True)) \
                .replace("\\\\", "\\").replace("\\\\", "\\")


def mql5():
    MT5_HOME = Path(os.environ["MT5_HOME"])
    MT5_EDITOR = MT5_HOME.joinpath("metaeditor64.exe")
    with open(CURDIR.joinpath("mql5_all.log"), "w") as log_all, \
            open(CURDIR.joinpath("mql5_errors.log"), "w") as log_errors:
        for root, folders, names in os.walk(CURDIR.parent):
            for n in names:
                ext = n[-4:]
                if ext == ".mq5" or ext == ".mqh":
                    pth = Path(root, n)
                    print(pth, end="", flush=True)
                    ret = proc.run('"' + str(MT5_EDITOR) + '" /log /compile:"' + str(pth) + '"',
                                   cwd=MT5_HOME).returncode
                    print(" - OK" if ret == 1 else " - FAIL")
                    with open(pth.with_suffix(".log"), 'r', encoding='utf-16le') as flog:
                        flog.read(1)
                        lines = flog.readlines()
                        log_all.write(n + ":\n")
                        log_all.writelines(lines)
                        log_all.write("\n")
                        log_all.flush()
                        if ret == 0:
                            log_errors.write(n + ":\n")
                            log_errors.writelines(lines)
                            log_errors.write("\n")
                            log_errors.flush()


def mql5tests():
    # The function does not work
    import time
    MT5_HOME = Path(os.environ["MT5_HOME"])
    MT5_TERMINAL = MT5_HOME.joinpath("terminal64.exe")
    config = CURDIR.joinpath("temp_terminal.ini")
    for pth in CURDIR.parent.joinpath(r"Scripts\Roffild\UnitTests").glob("*.mq5"):
        with open(config, "w", encoding="utf-16le") as cfg:
            cfg.write("\uFEFF")  # 0xFFFE - in file
            cfg.write("[StartUp]\nSymbol=EURUSD\nPeriod=M1\n")
            cfg.write("Script=Roffild\\UnitTests\\" + pth.stem + "\n")
        try:
            proc.run('start "" "' + str(MT5_TERMINAL) + '" /config:"' + str(config) + '"', cwd=MT5_HOME,
                     shell=True)
            time.sleep(5)
            # proc.Popen('"'+str(MT5_TERMINAL) + '" /config:"' + str(config) + '"', cwd=MT5_HOME).communicate(None, timeout=1)
        except proc.TimeoutExpired:
            pass


def mql5doc():
    with open(CURDIR.joinpath("doxygen.log"), "w") as log:
        doxygen = search("**/doxygen.exe")
        if doxygen is None:
            doxygen = searchInPF("**/doxygen.exe")
        if doxygen is None:
            log.write("doxygen.exe not found!\n")
            print("doxygen.exe not found!\n")
            return
        mql5doc_src = CURDIR.parent.joinpath("mql5doc")
        mql5doc_dst = CURDIR.joinpath("mql5doc")
        if mql5doc_src.exists():
            shutil.rmtree(mql5doc_src)
        cmd = '"' + str(doxygen) + '"'
        cwd = str(CURDIR.parent)
        log.write(cwd + ">" + cmd + "\n")
        log.flush()
        print(cwd + ">" + cmd + "\n")
        proc.run(cmd, cwd=cwd, stdout=log, stderr=log)
        if mql5doc_dst.exists():
            shutil.rmtree(mql5doc_dst)
        shutil.move(mql5doc_src, mql5doc_dst)


def python():
    if sys.gettrace() is None:
        import pip._internal
        pip._internal.main(
            ["install", "-I", "-e", str(CURDIR.parent.joinpath(r"Include\Roffild\RoffildPython"))])
    with open(CURDIR.joinpath("python_unittests.log"), "w") as log:
        log.writeln = lambda text="": log.write(text + "\n")
        testresult = unittest.TextTestResult(log, "", 100)
        unittest.defaultTestLoader.discover(
            CURDIR.parent.joinpath(r"Include\Roffild\RoffildPython\roffild\test")).run(testresult)
        testresult.printErrors()


def java():
    root = CURDIR.parent
    with open(CURDIR.joinpath("java.log"), "w") as log:
        gradle = search("**/gradle.bat")
        if gradle is None:
            log.write("gradle.bat not found!\n")
            print("gradle.bat not found!\n")
            return
        if "GRADLE_USER_HOME" not in os.environ \
                and not Path(os.environ["USERPROFILE"], ".gradle").exists():
            os.environ["GRADLE_USER_HOME"] = str(CURDIR.joinpath(".gradle"))

        def gradle_run(cmd, path):
            cmd = '"' + str(gradle) + '" ' + cmd
            text = str(path) + ">" + cmd + "\n"
            log.write(text)
            log.flush()
            print(text)
            proc.run(cmd, cwd=path, stdout=log, stderr=log)

        gradle_run("clean check :alljavadoc", root.joinpath(r"Include\Roffild\RoffildJava"))
        gradle_run("clean check shadowJar", root.joinpath(r"Experts\Roffild\AmazonUtils"))
        gradle_run("clean check shadowJar", root.joinpath(r"Scripts\Roffild\MLPDataFileSparkTest"))
        gradle_run("clean check jar", root.joinpath(r"Include\Roffild\LogMX"))
        javadoc_src = root.joinpath(r"Include\Roffild\RoffildJava\build\javadoc")
        javadoc_dst = CURDIR.joinpath("javadoc")
        if javadoc_dst.exists():
            shutil.rmtree(javadoc_dst)
        shutil.move(javadoc_src, javadoc_dst)

    with open(CURDIR.joinpath("spark.log"), "w") as log:
        path = root.joinpath(r"Scripts\Roffild\MLPDataFileSparkTest")
        cmd = str(Path(os.environ["APPDATA"], r"MetaQuotes\Terminal\Common\Files",
                       r"MLPData\mlp_2147483645.bin"))
        cmd = '"' + str(path.joinpath("spark.bat")) + '" "' + cmd + '"'
        text = str(path) + ">" + cmd + "\n"
        log.write(text)
        log.flush()
        print(text)
        proc.run(cmd, cwd=path, stdout=log, stderr=log)


if __name__ == '__main__':
    fenv = CURDIR.joinpath("environment.reg")
    if not fenv.is_file():
        CURDIR.mkdir(exist_ok=True)
        environmentWrite(fenv)
    environmentRead(fenv)
    mql5()
    python()
    java()
    # mql5tests()
    mql5doc()
