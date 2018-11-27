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

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.RowFactory;
import roffild.MLPDataFile;
import roffild.mqlport.MqlArray;
import roffild.mqlport.Pointer;

import java.io.IOException;

import static roffild.mqlport.MqlLibrary.*;


public class MLPDataFileRecordReader extends RecordReader<String[], Row>
{
   protected MLPDataFile mlpfile;
   public Pointer<Integer> nin = new Pointer<Integer>(0);
   public Pointer<Integer> nout = new Pointer<Integer>(0);
   public String[] header;
   protected MqlArray<Double> data = new MqlArray<Double>();
   protected Pointer<Integer> size = new Pointer<Integer>(0);
   private long start, tell, finish;

   @Override
   public void initialize(InputSplit split, TaskAttemptContext context)
           throws IOException, InterruptedException
   {
      FileSplit fileSplit = (FileSplit) split;
      start = fileSplit.getStart();
      tell = start;
      finish = start + fileSplit.getLength();
      Path path = Path.getPathWithoutSchemeAndAuthority(fileSplit.getPath());
      mlpfile = new MLPDataFile();
      mlpfile.initRead0(path.toString(), nin, nout);
      if (start > 0) {
         FileSeek(mlpfile.handleFile, start, 0);
      }
      setBufferSize(mlpfile.handleFile, 1024 * 1024);
      if (mlpfile.header.size() != (nin.value + nout.value)) {
         mlpfile.header.clear();
         for (int x = 0; x < nin.value; x++) {
            mlpfile.header.add("fd" + x);
         }
         for (int x = 0; x < nout.value; x++) {
            mlpfile.header.add("result" + x);
         }
      }
      header = mlpfile.header.toArray(new String[1]);
   }

   @Override
   public boolean nextKeyValue() throws IOException, InterruptedException
   {
      if (mlpfile.handleFile > -1 && (tell = FileTell(mlpfile.handleFile)) < finish &&
              mlpfile.read(data, size) > 0) {
         return true;
      }
      return false;
   }

   @Override
   public String[] getCurrentKey() throws IOException, InterruptedException
   {
      if (header.length != size.value) {
         throw new IOException("header (" + header.length + ") != size (" + size.value + ")");
      }
      return header;
   }

   @Override
   public Row getCurrentValue() throws IOException, InterruptedException
   {
      return RowFactory.create(data.toArray());
   }

   @Override
   public float getProgress() throws IOException, InterruptedException
   {
      return (finish - tell) / (finish - start);
   }

   @Override
   public void close() throws IOException
   {
      mlpfile.close();
   }
}
