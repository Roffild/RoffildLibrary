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

import org.apache.hadoop.conf.Configuration;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.ml.linalg.VectorUDT;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.Metadata;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.StructType;

public class MLPDataFileSpark
{
   public static JavaPairRDD<String[], Row> getPairRDD(String path, JavaSparkContext jsc, Configuration conf)
   {
      return jsc.newAPIHadoopFile(path,
              MLPDataFileInputFormat.class, String[].class, Row.class, conf);
   }

   public static JavaPairRDD<String[], Row> getPairRDDVector(String path, JavaSparkContext jsc,
           Configuration conf)
   {
      return jsc.newAPIHadoopFile(path,
              MLPDataFileInputFormatVector.class, String[].class, Row.class, conf);
   }

   public static Dataset<Row> getDataset(String path, SparkSession spark)
   {
      JavaSparkContext jsc = new JavaSparkContext(spark.sparkContext());
      Configuration conf = new Configuration(jsc.hadoopConfiguration());
      return getDataset(path, spark, jsc, conf);
   }
   public static Dataset<Row> getDataset(String path, SparkSession spark,
           JavaSparkContext jsc, Configuration conf)
   {
      StructType st = new StructType();
      JavaPairRDD<String[], Row> rdd = getPairRDD(path, jsc, conf);
      for (String column : rdd.keys().first()) {
         st = st.add(column, DataTypes.DoubleType, false);
      }
      return spark.createDataFrame(rdd.values(), st);
   }

   public static Dataset<Row> getDatasetVector(String path, SparkSession spark)
   {
      JavaSparkContext jsc = new JavaSparkContext(spark.sparkContext());
      Configuration conf = new Configuration(jsc.hadoopConfiguration());
      return getDatasetVector(path, spark, jsc, conf);
   }
   public static Dataset<Row> getDatasetVector(String path, SparkSession spark,
           JavaSparkContext jsc, Configuration conf)
   {
      StructType st = new StructType(new StructField[]{
              new StructField("features", new VectorUDT(), false, Metadata.empty()),
              new StructField("label", DataTypes.DoubleType, false, Metadata.empty())
      });
      return spark.createDataFrame(getPairRDDVector(path, jsc, conf).values(), st);
   }
}
