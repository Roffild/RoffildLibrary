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

import com.amazonaws.regions.Regions;
import com.amazonaws.services.ec2.AmazonEC2;
import com.amazonaws.services.ec2.AmazonEC2ClientBuilder;
import com.amazonaws.services.ec2.model.SpotPrice;

import java.util.LinkedList;
import java.util.List;

public class EC2
{
   public static List<EC2InstanceTypes> getSpotPrices(Regions... regions)
   {
      LinkedList<EC2InstanceTypes> result = new LinkedList<>();
      for (Regions region : regions) {
         try {
            AmazonEC2 ec2 = AmazonEC2ClientBuilder.standard().withRegion(region).build();
            for (SpotPrice spotPrice : ec2.describeSpotPriceHistory().getSpotPriceHistory()) {
               for (EC2InstanceTypes instanceType : EC2InstanceTypes.instanceTypes) {
                  if (instanceType.type.equalsIgnoreCase(spotPrice.getInstanceType())) {
                     result.add(new EC2InstanceTypes(instanceType, spotPrice));
                     break;
                  }
               }
            }
         } catch (Exception ex) {
         }
      }
      return result;
   }

   public static List<EC2InstanceTypes> getSpotPricesMinimal(Regions... regions)
   {
      LinkedList<EC2InstanceTypes> result = new LinkedList<>();
      for (EC2InstanceTypes instanceType : getSpotPrices(regions)) {
         boolean find = false;
         for (EC2InstanceTypes res : result) {
            if (res.type.equalsIgnoreCase(instanceType.type)) {
               if (res.spotPrice > instanceType.spotPrice) {
                  res.set(instanceType);
               }
               find = true;
               break;
            }
         }
         if (find == false) {
            result.add(new EC2InstanceTypes(instanceType));
         }
      }
      return result;
   }
}
