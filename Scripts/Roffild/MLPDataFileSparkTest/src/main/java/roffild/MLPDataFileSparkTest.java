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

import org.apache.hadoop.io.MD5Hash;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import roffild.mqlport.Pointer;
import roffild.spark.MLPDataFileSpark;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.Iterator;

public class MLPDataFileSparkTest
{
   public static void main(String[] args)
   {
      if (args.length < 1) {
         System.out.println("=========================");
         System.out.println("spark.bat path_to_MLPDataFile");
         System.out.println("=========================");
      }
      SparkSession spark = SparkSession.builder().appName("MLPDataFileSparkTest").getOrCreate();
      String path = args[0];
      String pathsave = path + "_save";
      String pathspark = path + "_spark";

      Pointer<Integer> nin = new Pointer<>(0);
      Pointer<Integer> nout = new Pointer<>(0);
      try (MLPDataFile infofile = new MLPDataFile()) {
         infofile.initRead0(path, nin, nout);
      }

      Dataset<Row> data = MLPDataFileSpark.getDataset(path, spark);

      int repartition = 1;

      // In real code, the value of repartition should be selected depending on the size of the RAM.
      // The parquet format incorrectly sets the value for repartition.
      //repartition = data.count() > 100 ? 100 : (int)data.count();

      data.repartition(repartition).write().save(pathsave);

      data = spark.read().load(pathsave).repartition(repartition).cache();

      writeFile(pathspark, data, nin, nout);
      compareFiles(path, pathspark);
   }

   private static void writeFile(String pathspark, Dataset<Row> data,
           Pointer<Integer> nin, Pointer<Integer> nout)
   {
      try (MLPDataFile mlpfile = new MLPDataFile()) {
         mlpfile.initWrite0(pathspark, nin.value, nout.value, data.columns());
         Iterator<Row> iterator = data.toLocalIterator();
         while (iterator.hasNext()) {
            Row row = iterator.next();
            double[] doubles = new double[row.size()];
            for (int x = row.size() - 1; x > -1; x--) {
               doubles[x] = row.getDouble(x);
            }
            mlpfile.write(doubles);
         }
      }
   }

   private static void compareFiles(String path, String pathspark)
   {
      MD5Hash md5orig, md5spark;
      try (InputStream orig = Files.newInputStream(Paths.get(path), StandardOpenOption.READ)) {
         md5orig = MD5Hash.digest(orig);
      } catch (IOException e) {
         e.printStackTrace();
         return;
      }
      try (InputStream fspark = Files.newInputStream(Paths.get(pathspark), StandardOpenOption.READ)) {
         md5spark = MD5Hash.digest(fspark);
      } catch (IOException e) {
         e.printStackTrace();
         return;
      }
      System.out.println("=========================");
      if (md5orig.compareTo(md5spark) == 0) {
         System.out.println("Files are OK!");
      } else {
         System.out.println("Files are not equal!");
      }
      System.out.println("=========================");
   }
}
