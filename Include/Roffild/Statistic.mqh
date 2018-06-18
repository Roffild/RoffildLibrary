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
#include "ArrayListClass.mqh"

class CStatisticObject
{
public:
   ulong hash;
   int count;
   string describe;

   CStatisticObject(const ulong _hash, const string _describe = "none", const int _count = 0)
   {
      hash = _hash;
      describe = _describe;
      count = _count;
   }
};

/**
 * Counting data and printing out the accumulated information.
 */
class CStatistic
{
public:
   CArrayListClass<CStatisticObject> object;
   string name;

   CStatistic()
   {
      name = "NoName";
   }

   ~CStatistic()
   {
      print();
   }

   int index(const ulong hash)
   {
      const int count = object.size();
      for (int x = 0; x < count; x++) {
         if (object[x].hash == hash) {
            return x;
         }
      }
      return -1;
   }

   int plus(const ulong hash, const string describe = "none", const int number = 1)
   {
      const int ind = index(hash);
      if (ind > -1) {
         return object[ind].count += number;
      }
      if (object.add(new CStatisticObject(hash, describe))) {
         return object[object.size() - 1].count += number;
      }
      return 0;
   }

   int plus(CStatisticObject *value, const int number = 1)
   {
      const int ind = index(value.hash);
      if (ind > -1) {
         delete value;
         return object[ind].count += number;
      }
      if (object.add(value)) {
         return object[object.size() - 1].count += number;
      }
      delete value;
      return 0;
   }

   void print(const int file = INVALID_HANDLE)
   {
      if (file == INVALID_HANDLE) {
         if (MQLInfoInteger(MQL_OPTIMIZATION) == false) {
            Print("=== ", name, " -- Statistic ===");
            const int count = object.size();
            for (int x = 0; x < count; x++) {
               Print(object[x].describe, " = ", object[x].count);
            }
         }
      }
   }
};
