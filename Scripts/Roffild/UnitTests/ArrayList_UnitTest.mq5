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
#property copyright "Roffild"
#property link      "https://github.com/Roffild/RoffildLibrary"

#include <Roffild/UnitTest.mqh>

#include <Roffild/ArrayList.mqh>
#include <Roffild/ArrayListClass.mqh>

class CArrayListTest : public CUnitTest
{
public:
   void run(string name = "")
   {
      CUnitTest::run(name != "" ? name : "ArrayList");
   }

protected:
   CUnitTest_FUNC(1)
   {
      testName = "add(int)";
      int ideal[] = {1};
      int result[];
      CArrayList<int> arr();
      arr.add(1);
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(2)
   {
      testName = "addAll(int)";
      int ideal[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
      int result[];
      CArrayList<int> arr();
      arr.add(1);
      int addall[] = {2, 3, 4, 5, 6};
      arr.addAll(addall);
      CArrayList<int> arr2();
      int addall2[] = {7, 8, 9};
      arr2.addAll(addall2);
      arr.addAll(arr2);
      arr.add(10);
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(3)
   {
      testName = "add(index, int)";
      int ideal[] = {1, 2, 3, 4, 5};
      int result[];
      CArrayList<int> arr();
      arr.add(1);
      arr.add(3);
      arr.add(4);
      arr.add(5);
      arr.add(1, 2);
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(4)
   {
      testName = "addAll(index, int)";
      int ideal[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
      int result[];
      CArrayList<int> arr();
      arr.add(1);
      arr.add(10);
      int addall[] = {2, 3, 4, 8, 9};
      arr.addAll(1, addall);
      CArrayList<int> arr2();
      int addall2[] = {5, 6, 7};
      arr2.addAll(addall2);
      arr.addAll(4, arr2);
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(10)
   {
      testName = "size() and clear() and isEmpty()";
      CArrayList<int> arr();
      arr.add(1);
      if (arr.size() != 1) {
         return false;
      }
      arr.clear();
      if (arr.size() == 0 && arr.isEmpty()) {
         return true;
      }
      return false;
   }

   CUnitTest_FUNC(20)
   {
      testName = "indexOf(int) and lastIndexOf(int) and contains(int)";
      CArrayList<int> arr();
      int addall[] = {2, 3, 4, 5, 6, 7, 8, 9};
      arr.addAll(addall);
      if (arr.indexOf(100) != -1 || arr.lastIndexOf(100) != -1) {
         return false;
      }
      if (arr.indexOf(5) != 3 || arr.lastIndexOf(5) != 3) {
         return false;
      }
      if (arr.contains(8) == false) {
         return false;
      }
      return true;
   }

   CUnitTest_FUNC(30)
   {
      testName = "get() and operator[]()";
      CArrayList<int> arr();
      int addall[] = {2, 3, 4, 5, 6, 7, 8, 9};
      arr.addAll(addall);
      if (arr.get(3) != 5 || arr[3] != 5) {
         return false;
      }
      return true;
   }

   CUnitTest_FUNC(31)
   {
      testName = "set(int)";
      int ideal[] = {1, 2, 3};
      int result[];
      CArrayList<int> arr();
      arr.add(1);
      arr.add(3);
      arr.add(1, 999);
      if (arr.set(1, 2) != 999) {
         return false;
      }
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(40)
   {
      testName = "remove(int)";
      int ideal[] = {1, 2, 3, 4, 6, 7, 8, 9, 10};
      int result[];
      CArrayList<int> arr();
      int addall[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
      arr.addAll(addall);
      if (arr.remove(4) != 5) {
         return false;
      }
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(41)
   {
      testName = "removeFirst(int)";
      int ideal[] = {1, 3, 4, 5, 6, 7, 8, 2, 10};
      int result[];
      CArrayList<int> arr();
      int addall[] = {1, 2, 3, 4, 5, 6, 7, 8, 2, 10};
      arr.addAll(addall);
      if (arr.removeFirst(99) == true || arr.removeFirst(2) == false) {
         return false;
      }
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(42)
   {
      testName = "removeAll(int)";
      int ideal[] = {3, 4, 6, 7, 8, 9};
      int remlist[] = {2, 5, 10, 1, 999};
      int result[];
      CArrayList<int> arr();
      int addall[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
      arr.addAll(addall);
      if (arr.removeAll(remlist) == false) {
         return false;
      }
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(43)
   {
      testName = "retainAll(int)";
      int ideal[] = {1, 2, 5, 10};
      int remlist[] = {2, 5, 10, 1, 999};
      int result[];
      CArrayList<int> arr();
      int addall[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
      arr.addAll(addall);
      if (arr.retainAll(remlist) == false) {
         return false;
      }
      arr.toArray(result);
      return ArrayCompare(ideal, result) == 0;
   }

   CUnitTest_FUNC(48)
   {
      testName = "subList(int)";
      int ideal[] = {3, 4, 5, 6, 7, 8};
      int result[];
      CArrayList<int> arr();
      int addall[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
      arr.addAll(addall);
      if (arr.subList(result, 0, 2, ArraySize(ideal)) != ArraySize(ideal)) {
         return false;
      }
      return ArrayCompare(ideal, result) == 0;
   }
};

/////////////////////////////////////////////////////

class CSomeClass
{
public:
   int number;

   CSomeClass() : number(0)
   {
   }

   CSomeClass(int num) : number(num)
   {
   }
};

class CArrayListClassTest : public CUnitTest
{
public:
   void run(string name = "")
   {
      CUnitTest::run(name != "" ? name : "ArrayListClass");
   }

protected:
   bool compare(CSomeClass &ideal[], CSomeClass *&result[])
   {
      int countid = ArraySize(ideal);
      int countres = ArraySize(result);
      if (countid != countres) {
         return false;
      }
      for (int x = countid-1; x > -1; x--) {
         if (CheckPointer(result[x]) == POINTER_INVALID ||
             ideal[x].number != result[x].number) {
            return false;
         }
      }
      return true;
   }

   CUnitTest_FUNC(1)
   {
      testName = "add(Class)";
      CSomeClass ideal[1];
      ideal[0].number = 1;
      CSomeClass *result[];
      CArrayListClass<CSomeClass> arr();
      arr.add(new CSomeClass(1));
      arr.toArray(result);
      return compare(ideal, result);
   }

   CUnitTest_FUNC(2)
   {
      testName = "addAll(Class)";
      CSomeClass ideal[10];
      for (int x = 1, y = 0; x < 11; x++, y++) {
         ideal[y].number = x;
      }
      CSomeClass *result[];
      CArrayListClass<CSomeClass> arr();
      arr.add(new CSomeClass(1));
      CSomeClass *addall[5];
      for (int x = 2, y = 0; x < 7; x++, y++) {
         addall[y] = new CSomeClass(x);
      }
      arr.addAll(addall);
      CArrayListClass<CSomeClass> arr2(false);
      CSomeClass *addall2[3];
      for (int x = 7, y = 0; x < 10; x++, y++) {
         addall2[y] = new CSomeClass(x);
      }
      arr2.addAll(addall2);
      arr.addAll(arr2);
      arr.add(new CSomeClass(10));
      arr.toArray(result);
      return compare(ideal, result);
   }

   CUnitTest_FUNC(3)
   {
      testName = "add(index, Class)";
      CSomeClass ideal[5];
      for (int x = 1, y = 0; x < 6; x++, y++) {
         ideal[y].number = x;
      }
      CSomeClass *result[];
      CArrayListClass<CSomeClass> arr();
      arr.add(new CSomeClass(1));
      arr.add(new CSomeClass(3));
      arr.add(new CSomeClass(4));
      arr.add(new CSomeClass(5));
      arr.add(1, new CSomeClass(2));
      arr.toArray(result);
      return compare(ideal, result);
   }

   CUnitTest_FUNC(4)
   {
      testName = "addAll(index, Class)";
      CSomeClass ideal[10];
      for (int x = 1, y = 0; x < 11; x++, y++) {
         ideal[y].number = x;
      }
      CSomeClass *result[];
      CArrayListClass<CSomeClass> arr();
      arr.add(new CSomeClass(1));
      arr.add(new CSomeClass(10));
      CSomeClass *addall[5];
      addall[0] = new CSomeClass(2);
      addall[1] = new CSomeClass(3);
      addall[2] = new CSomeClass(4);
      addall[3] = new CSomeClass(8);
      addall[4] = new CSomeClass(9);
      arr.addAll(1, addall);
      CArrayListClass<CSomeClass> arr2(false);
      CSomeClass *addall2[3];
      for (int x = 5, y = 0; x < 8; x++, y++) {
         addall2[y] = new CSomeClass(x);
      }
      arr2.addAll(addall2);
      arr.addAll(4, arr2);
      arr.toArray(result);
      return compare(ideal, result);
   }

   CUnitTest_FUNC(10)
   {
      testName = "size() and clear() and isEmpty()";
      CArrayListClass<CSomeClass> arr();
      arr.add(new CSomeClass(1));
      if (arr.size() != 1) {
         return false;
      }
      arr.clear();
      if (arr.size() == 0 && arr.isEmpty()) {
         return true;
      }
      return false;
   }
/*
   CUnitTest_FUNC(20)
   {
      testName = "indexOf(Class) and lastIndexOf(Class) and contains(Class)";
   }
*/
   CUnitTest_FUNC(30)
   {
      testName = "get() and operator[]()";
      CArrayListClass<CSomeClass> arr();
      CSomeClass *addall[8];
      for (int x = 2, y = 0; x < 10; x++, y++) {
         addall[y] = new CSomeClass(x);
      }
      arr.addAll(addall);
      if (arr.get(3).number != 5 || arr[3].number != 5) {
         return false;
      }
      return true;
   }

   CUnitTest_FUNC(31)
   {
      testName = "set(Class)";
      CSomeClass ideal[3];
      for (int x = 1, y = 0; x < 4; x++, y++) {
         ideal[y].number = x;
      }
      CSomeClass *result[];
      CArrayListClass<CSomeClass> arr();
      arr.add(new CSomeClass(1));
      arr.add(new CSomeClass(3));
      arr.add(1, new CSomeClass(999));
      arr.set(1, new CSomeClass(2));
      arr.toArray(result);
      return compare(ideal, result);
   }

   CUnitTest_FUNC(40)
   {
      testName = "remove(Class)";
      CSomeClass ideal[9];
      for (int x = 1, y = 0; x < 11; x++, y++) {
         if (x == 5) {
            y--;
            continue;
         }
         ideal[y].number = x;
      }
      CSomeClass *result[];
      CArrayListClass<CSomeClass> arr();
      CSomeClass *addall[10];
      for (int x = 1, y = 0; x < 11; x++, y++) {
         addall[y] = new CSomeClass(x);
      }
      arr.addAll(addall);
      arr.remove(4);
      arr.toArray(result);
      return compare(ideal, result);
   }
/*
   CUnitTest_FUNC(41)
   {
      testName = "removeFirst(Class)";
   }

   CUnitTest_FUNC(42)
   {
      testName = "removeAll(Class)";
   }

   CUnitTest_FUNC(43)
   {
      testName = "retainAll(Class)";
   }
*/
   CUnitTest_FUNC(48)
   {
      testName = "subList(Class)";
      CSomeClass ideal[6];
      for (int x = 3, y = 0; x < 9; x++, y++) {
         ideal[y].number = x;
      }
      CSomeClass *result[];
      CArrayListClass<CSomeClass> arr();
      CSomeClass *addall[10];
      for (int x = 1, y = 0; x < 11; x++, y++) {
         addall[y] = new CSomeClass(x);
      }
      arr.addAll(addall);
      if (arr.subList(result, 0, 2, ArraySize(ideal)) != ArraySize(ideal)) {
         return false;
      }
      return compare(ideal, result);
   }
};

void OnStart()
{
   CArrayListTest test();
   test.run();

   CArrayListClassTest classtest();
   classtest.run();
}
