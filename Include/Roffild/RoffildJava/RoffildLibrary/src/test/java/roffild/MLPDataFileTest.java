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

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import roffild.mqlport.MqlArray;
import roffild.mqlport.Pointer;

import java.io.IOException;
import java.nio.file.Paths;

public class MLPDataFileTest
{
   public static String tempFolder;
   Pointer<Integer> nin = new Pointer<>(1);
   Pointer<Integer> nout = new Pointer<>(1);

   @BeforeClass
   public static void createFolder() throws IOException
   {
      tempFolder = "tempFolder" + System.currentTimeMillis();
      java.nio.file.Files.createDirectory(Paths.get(tempFolder));
   }

   @AfterClass
   public static void deleteFolder() throws IOException
   {
      //Files.walk().sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
      //java.nio.file.Files.delete(Paths.get("tempFolder" + System.currentTimeMillis()));
   }

   @Test
   public void initRead0()
   {
      MLPDataFile file = new MLPDataFile();
      tempFolder = "d:\\MQLProjects\\MQL5\\FilesCommon";
      file.setPathFilesCommon(tempFolder);
      file.initRead(601, nin, nout);

      MLPDataFile out = new MLPDataFile();
      out.setPathFilesCommon(tempFolder);
      out.initWrite(888, nin.value, nout.value, file.header.toArray(new String[1]));
      out.flush();
      MqlArray<Double> data = new MqlArray<>();
      Pointer<Integer> size = new Pointer<>(0);
      while (file.read(data, size) > 0) {
         double[] in = new double[data.size()];
         for (int x = in.length - 1; x > -1; x--) {
            in[x] = data.get(x);
         }
         out.write(in);
      }
      out.close();
      file.close();
   }
}
