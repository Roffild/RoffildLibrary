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
package roffild.amazonutils.main;

import com.amazonaws.regions.Regions;
import roffild.amazonutils.EC2InstanceTypes;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;

import static roffild.amazonutils.EC2.getSpotPrices;
import static roffild.amazonutils.EC2.getSpotPricesMinimal;

public class EC2SpotPrices
{
   public static void main(String[] args)
   {
      try (BufferedReader config = Files.newBufferedReader(Paths.get("amazon.config"))) {
         Properties properties = new Properties();
         properties.load(config);
         for (String key : properties.stringPropertyNames()) {
            System.setProperty(key, properties.getProperty(key));
         }
      } catch (IOException e) {
      }
      System.out.println("All SpotPrices...");
      save(Paths.get("aws_spotprices_all.csv"), getSpotPrices(Regions.values()));
      System.out.println("Minimal SpotPrices...");
      save(Paths.get("aws_spotprices_minimal.csv"), getSpotPricesMinimal(Regions.values()));
   }

   public static void save(Path path, List<EC2InstanceTypes> ec2InstanceTypes)
   {
      LinkedList<String[]> data = new LinkedList<>();
      data.add(new String[]{
              "Type", "CPU", "ECU", "Memory", "Storage", "StorageGB", "Zone", "SpotPrice", "Product", "Time"
      });
      for (EC2InstanceTypes instanceTypes : ec2InstanceTypes) {
         data.add(new String[]{
                 instanceTypes.type,
                 String.valueOf(instanceTypes.cpu),
                 String.valueOf(instanceTypes.ecu),
                 String.valueOf(instanceTypes.memoryGiB),
                 String.valueOf(instanceTypes.storage),
                 String.valueOf(instanceTypes.storageGB),
                 String.valueOf(instanceTypes.zone),
                 String.valueOf(instanceTypes.spotPrice),
                 String.valueOf(instanceTypes.product),
                 String.valueOf(instanceTypes.timestemp)
         });
      }
      try (BufferedWriter csv = Files.newBufferedWriter(path,
              StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING)) {
         String dil = ";";
         for (String[] line : data) {
            csv.write(line[0]);
            for (int x = 1; x < line.length; x++) {
               csv.write(dil + line[x]);
            }
            csv.newLine();
         }
      } catch (IOException e) {
         e.printStackTrace();
      }
   }
}
