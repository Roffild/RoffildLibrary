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
package roffild.spark;

import org.apache.spark.ml.linalg.Vectors;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.RowFactory;

import java.io.IOException;

public class MLPDataFileRecordReaderVector extends MLPDataFileRecordReader
{
   @Override
   public Row getCurrentValue() throws IOException, InterruptedException
   {
      int x;
      double[] in = new double[nin.value];
      for (x = 0; x < in.length; x++) {
         in[x] = data.get(x);
      }
      return RowFactory.create(Vectors.dense(in).toSparse(), data.get(nin.value));
   }
}
