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
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.S3ObjectSummary;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.LinkedList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class S3
{
   public static void download(Regions region, String bucket, String prefix, String folder)
   {
      AmazonS3 s3 = AmazonS3ClientBuilder.standard().withRegion(region).build();
      for (S3ObjectSummary objectSummary : s3.listObjects(bucket, prefix).getObjectSummaries()) {
         System.out.println(objectSummary.getKey());
         s3.getObject(new GetObjectRequest(objectSummary.getBucketName(), objectSummary.getKey()),
                 Paths.get(folder, "/", objectSummary.getKey()).toFile());
      }
   }

   public static void upload(Regions region, String bucket, LinkedList<MyPath> list)
   {
      AmazonS3 s3 = AmazonS3ClientBuilder.standard().withRegion(region).build();
      s3.putObject(bucket, "logs/.dir", "empty");
      s3.putObject(bucket, "output/.dir", "empty");
      scanDir(list);
      ExecutorService thpool = Executors.newFixedThreadPool(36);
      final int slist = list.size();
      for (int x = 0; x < slist; x++) {
         int finalX = x;
         thpool.submit(new Runnable()
         {
            @Override
            public void run()
            {
               MyPath p = list.get(finalX);
               s3.putObject(bucket, p.getKey(), p.getValue().toFile());
               System.out.println(finalX + "/" + slist + " " + p.getKey() + " = " + p.getValue().toString());
            }
         });
      }
      try {
         thpool.shutdown();
         thpool.awaitTermination(99, TimeUnit.HOURS);
      } catch (InterruptedException e) {
         e.printStackTrace();
      }
      System.out.println(list.size());
   }

   private static void scanDir(LinkedList<MyPath> list)
   {
      boolean folders = true;
      while (folders) {
         folders = false;
         for (int x = list.size() - 1; x > -1; x--) {
            if (list.get(x).getValue().toFile().isDirectory()) {
               folders = true;
               boolean last = x == list.size() - 1;
               if (last) {
                  list.addLast(new MyPath("last", null));
               }
               for (String name : list.get(x).getValue().toFile().list()) {
                  Path path = Paths.get(list.get(x).getValue().toString(), name);
                  list.add(x + 1, new MyPath(Paths.get(list.get(x).getKey(), list.get(x).getValue().getFileName().toString()).toString(),
                          path));
               }
               list.remove(x);
               if (last) {
                  list.removeLast();
               }
            }
         }
      }
      for (int x = list.size() - 1; x > -1; x--) {
         list.set(x,
                 new MyPath(
                         Paths.get(list.get(x).getKey(),
                                 list.get(x).getValue().getFileName().toString()).toString().replace('\\', '/'),
                         list.get(x).getValue()));
      }
   }

   public static class MyPath
   {
      public String key;
      public Path path;

      public MyPath(String k, Path p)
      {
         key = k;
         path = p;
      }

      public String getKey()
      {
         return key;
      }

      public Path getValue()
      {
         return path;
      }
   }
}
