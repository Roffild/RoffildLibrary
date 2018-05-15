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
package roffild.amazonutils;

import com.amazonaws.services.ec2.model.SpotPrice;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Date;
import java.util.LinkedList;

public class EC2InstanceTypes
{
   public static EC2InstanceTypes[] instanceTypes;

   static {
      try (BufferedReader reader = new BufferedReader(
              new InputStreamReader(Class.class.getResourceAsStream("/aws_ec2_types.csv")))) {
         LinkedList<EC2InstanceTypes> list = new LinkedList<>();
         String line;
         while ((line = reader.readLine()) != null) {
            String[] info = line.split("\t");
            if (info.length > 5 && info[0].compareTo("") != 0) {
               list.add(new EC2InstanceTypes(info));
            }
         }
         instanceTypes = list.toArray(new EC2InstanceTypes[0]);
      } catch (IOException e) {
         instanceTypes = null;
      }
   }

   public String type = "";
   public int cpu = 0;
   public double ecu = 0;
   public double memoryGiB = 0;
   public String storage = "";
   public int storageGB = 0;
   public String zone = "";
   public double spotPrice = 0;
   public String product = "";
   public Date timestemp = new Date();

   public EC2InstanceTypes(String[] info)
   {
      try {
         type = info[0];
         cpu = Integer.valueOf(info[1]);
         ecu = info[2].compareToIgnoreCase("Variable") == 0 ? 0 : Double.valueOf(info[2]);
         memoryGiB = Double.valueOf(info[3]);
         storage = info[4];
         if (storage.contains("EBS")) {
            storage = "EBS";
         } else if (storage.contains("SSD")) {
            String[] gb = storage.split(" ");
            storageGB = Integer.valueOf(gb[0]) * Integer.valueOf(gb[2]);
            storage = "SSD";
         } else if (storage.contains("HDD")) {
            String[] gb = storage.split(" ");
            storageGB = Integer.valueOf(gb[0]) * Integer.valueOf(gb[2]);
            storage = "HDD";
         }
      } catch (NumberFormatException ex) {
      }
   }

   public EC2InstanceTypes(EC2InstanceTypes from)
   {
      set(from);
   }

   public void set(EC2InstanceTypes from)
   {
      type = from.type;
      cpu = from.cpu;
      ecu = from.ecu;
      memoryGiB = from.memoryGiB;
      storage = from.storage;
      storageGB = from.storageGB;
      zone = from.zone;
      spotPrice = from.spotPrice;
      product = from.product;
      timestemp = new Date(from.timestemp.getTime());
   }

   public EC2InstanceTypes(EC2InstanceTypes from, SpotPrice price)
   {
      this(from);
      zone = price.getAvailabilityZone();
      spotPrice = Double.valueOf(price.getSpotPrice());
      product = price.getProductDescription();
      timestemp = price.getTimestamp();
   }

   @Override
   public String toString()
   {
      return type + "CPU: " + cpu + " " + ecu + " " + memoryGiB + " " + storage + " " + storageGB;
   }
}
