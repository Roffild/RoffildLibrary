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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.fs.*;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import org.apache.spark.sql.Row;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static roffild.mqlport.MqlLibrary.FileTell;

/**
 * Only for local files
 */
public class MLPDataFileInputFormat extends FileInputFormat<String[], Row>
{
   private static final Log LOG = LogFactory.getLog(MLPDataFileInputFormat.class);

   @Override
   public RecordReader<String[], Row> createRecordReader(InputSplit split, TaskAttemptContext context)
           throws IOException, InterruptedException
   {
      return new MLPDataFileRecordReader();
   }

   @Override
   protected boolean isSplitable(JobContext context, Path filename)
   {
      return true;
   }

   @Override
   public List<InputSplit> getSplits(JobContext job) throws IOException
   {
      long minSize = 0; //Math.max(getFormatMinSplitSize(), getMinSplitSize(job));
      long maxSize = getMaxSplitSize(job);

      // generate splits
      List<InputSplit> splits = new ArrayList<InputSplit>();
      List<FileStatus> files = listStatus(job);
      for (FileStatus file: files) {
         Path path = file.getPath();
         long length = file.getLen();
         if (length != 0) {
            BlockLocation[] blkLocations;
            if (file instanceof LocatedFileStatus) {
               blkLocations = ((LocatedFileStatus) file).getBlockLocations();
            } else {
               FileSystem fs = path.getFileSystem(job.getConfiguration());
               blkLocations = fs.getFileBlockLocations(file, 0, length);
            }
            long header = 0;
            try (MLPDataFileRecordReader mlp = new MLPDataFileRecordReader()) {
               mlp.initialize(new FileSplit(path, 0, length, new String[]{""}), null);
               header = FileTell(mlp.mlpfile.handleFile);
               if (mlp.nextKeyValue()) {
                  minSize = FileTell(mlp.mlpfile.handleFile) - header;
               } else {
                  throw new Exception("No key-value");
               }
            } catch (Exception ex) {
               LOG.warn("File " + path.toString() + ": " + ex.getMessage(), ex);
               continue;
            }
            if (isSplitable(job, path)) {
               long blockSize = file.getBlockSize();
               long splitSize = computeSplitSize(blockSize, minSize, maxSize);
               splitSize = splitSize - (splitSize % minSize);

               long sizeFile = header + splitSize;
               int blkIndex = getBlockIndex(blkLocations,0);
               splits.add(makeSplit(path, 0, sizeFile,
                       blkLocations[blkIndex].getHosts(),
                       blkLocations[blkIndex].getCachedHosts()));

               while ((sizeFile + splitSize) < length) {
                  blkIndex = getBlockIndex(blkLocations, sizeFile);
                  splits.add(makeSplit(path, sizeFile, splitSize,
                          blkLocations[blkIndex].getHosts(),
                          blkLocations[blkIndex].getCachedHosts()));
                  sizeFile += splitSize;
               }

               if ((length - sizeFile) > 0) {
                  blkIndex = getBlockIndex(blkLocations, sizeFile);
                  splits.add(makeSplit(path, sizeFile, length - sizeFile,
                          blkLocations[blkIndex].getHosts(),
                          blkLocations[blkIndex].getCachedHosts()));
               }
            } else { // not splitable
               splits.add(makeSplit(path, 0, length, blkLocations[0].getHosts(),
                       blkLocations[0].getCachedHosts()));
            }
         } else {
            //Create empty hosts array for zero length files
            splits.add(makeSplit(path, 0, length, new String[0]));
         }
      }
      // Save the number of input files for metrics/loadgen
      job.getConfiguration().setLong(NUM_INPUT_FILES, files.size());
      return splits;
   }
}
