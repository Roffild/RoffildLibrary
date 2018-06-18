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

#define CUnitTest_FUNC(NUM) virtual bool test_##NUM(string &testName)

/**
 * Base class for UnitTest
 *
 * Examples:
 * https://github.com/Roffild/RoffildLibrary/blob/master/Scripts/Roffild/UnitTests
 */
class CUnitTest
{
private:
   int counttests;

public:
   void run(string name = "")
   {
      Print("===== ", name, " UnitTest Start =====");

      string fails[];

      #define _CUnitTest_RUN(NUM)                                                        \
         if (counttests > NUM) {                                                         \
            ResetLastError();                                                            \
            string testname;                                                             \
            bool result = test_##NUM(testname);                                          \
            if (testname != NULL) {                                                      \
               string textresult = "-- #" + string(NUM) + " " +                          \
                  testname + " - " + (result ? "OK" : "FAIL") +                          \
                  (_LastError > 0 ? "   LastError = " + string(_LastError) : "");        \
               Print(textresult);                                                        \
               if (result == false) {                                                    \
                  ArrayResize(fails, ArraySize(fails)+1, 10);                            \
                  fails[ArraySize(fails)-1] = textresult;                                \
               }                                                                         \
            }                                                                            \
         }

      _CUnitTest_RUN(1)
      _CUnitTest_RUN(2)
      _CUnitTest_RUN(3)
      _CUnitTest_RUN(4)
      _CUnitTest_RUN(5)
      _CUnitTest_RUN(6)
      _CUnitTest_RUN(7)
      _CUnitTest_RUN(8)
      _CUnitTest_RUN(9)
      _CUnitTest_RUN(10)
      _CUnitTest_RUN(11)
      _CUnitTest_RUN(12)
      _CUnitTest_RUN(13)
      _CUnitTest_RUN(14)
      _CUnitTest_RUN(15)
      _CUnitTest_RUN(16)
      _CUnitTest_RUN(17)
      _CUnitTest_RUN(18)
      _CUnitTest_RUN(19)
      _CUnitTest_RUN(20)
      _CUnitTest_RUN(21)
      _CUnitTest_RUN(22)
      _CUnitTest_RUN(23)
      _CUnitTest_RUN(24)
      _CUnitTest_RUN(25)
      _CUnitTest_RUN(26)
      _CUnitTest_RUN(27)
      _CUnitTest_RUN(28)
      _CUnitTest_RUN(29)
      _CUnitTest_RUN(30)
      _CUnitTest_RUN(31)
      _CUnitTest_RUN(32)
      _CUnitTest_RUN(33)
      _CUnitTest_RUN(34)
      _CUnitTest_RUN(35)
      _CUnitTest_RUN(36)
      _CUnitTest_RUN(37)
      _CUnitTest_RUN(38)
      _CUnitTest_RUN(39)
      _CUnitTest_RUN(40)
      _CUnitTest_RUN(41)
      _CUnitTest_RUN(42)
      _CUnitTest_RUN(43)
      _CUnitTest_RUN(44)
      _CUnitTest_RUN(45)
      _CUnitTest_RUN(46)
      _CUnitTest_RUN(47)
      _CUnitTest_RUN(48)
      _CUnitTest_RUN(49)
      _CUnitTest_RUN(50)
      _CUnitTest_RUN(51)
      _CUnitTest_RUN(52)
      _CUnitTest_RUN(53)
      _CUnitTest_RUN(54)
      _CUnitTest_RUN(55)
      _CUnitTest_RUN(56)
      _CUnitTest_RUN(57)
      _CUnitTest_RUN(58)
      _CUnitTest_RUN(59)
      _CUnitTest_RUN(60)
      _CUnitTest_RUN(61)
      _CUnitTest_RUN(62)
      _CUnitTest_RUN(63)
      _CUnitTest_RUN(64)
      _CUnitTest_RUN(65)
      _CUnitTest_RUN(66)
      _CUnitTest_RUN(67)
      _CUnitTest_RUN(68)
      _CUnitTest_RUN(69)
      _CUnitTest_RUN(70)
      _CUnitTest_RUN(71)
      _CUnitTest_RUN(72)
      _CUnitTest_RUN(73)
      _CUnitTest_RUN(74)
      _CUnitTest_RUN(75)
      _CUnitTest_RUN(76)
      _CUnitTest_RUN(77)
      _CUnitTest_RUN(78)
      _CUnitTest_RUN(79)
      _CUnitTest_RUN(80)
      _CUnitTest_RUN(81)
      _CUnitTest_RUN(82)
      _CUnitTest_RUN(83)
      _CUnitTest_RUN(84)
      _CUnitTest_RUN(85)
      _CUnitTest_RUN(86)
      _CUnitTest_RUN(87)
      _CUnitTest_RUN(88)
      _CUnitTest_RUN(89)
      _CUnitTest_RUN(90)
      _CUnitTest_RUN(91)
      _CUnitTest_RUN(92)
      _CUnitTest_RUN(93)
      _CUnitTest_RUN(94)
      _CUnitTest_RUN(95)
      _CUnitTest_RUN(96)
      _CUnitTest_RUN(97)
      _CUnitTest_RUN(98)
      _CUnitTest_RUN(99)
      _CUnitTest_RUN(100)

      int countfails = ArraySize(fails);
      if (countfails > 0) {
         Print("----------");
         for (int x = 0; x < countfails; x++) {
            Print(fails[x]);
         }
      }

      Print("===== ", name, " UnitTest Stop =====");
   }

   int getCount()
   {
      return counttests;
   }

protected:
   CUnitTest() : counttests(INT_MAX)
   {
   }

   void setCount(int count)
   {
      counttests = count;
   }

   #define _CUnitTest_FUNC(NUM) \
      CUnitTest_FUNC(NUM) { testName = NULL; return false; }

   _CUnitTest_FUNC(1)
   _CUnitTest_FUNC(2)
   _CUnitTest_FUNC(3)
   _CUnitTest_FUNC(4)
   _CUnitTest_FUNC(5)
   _CUnitTest_FUNC(6)
   _CUnitTest_FUNC(7)
   _CUnitTest_FUNC(8)
   _CUnitTest_FUNC(9)
   _CUnitTest_FUNC(10)
   _CUnitTest_FUNC(11)
   _CUnitTest_FUNC(12)
   _CUnitTest_FUNC(13)
   _CUnitTest_FUNC(14)
   _CUnitTest_FUNC(15)
   _CUnitTest_FUNC(16)
   _CUnitTest_FUNC(17)
   _CUnitTest_FUNC(18)
   _CUnitTest_FUNC(19)
   _CUnitTest_FUNC(20)
   _CUnitTest_FUNC(21)
   _CUnitTest_FUNC(22)
   _CUnitTest_FUNC(23)
   _CUnitTest_FUNC(24)
   _CUnitTest_FUNC(25)
   _CUnitTest_FUNC(26)
   _CUnitTest_FUNC(27)
   _CUnitTest_FUNC(28)
   _CUnitTest_FUNC(29)
   _CUnitTest_FUNC(30)
   _CUnitTest_FUNC(31)
   _CUnitTest_FUNC(32)
   _CUnitTest_FUNC(33)
   _CUnitTest_FUNC(34)
   _CUnitTest_FUNC(35)
   _CUnitTest_FUNC(36)
   _CUnitTest_FUNC(37)
   _CUnitTest_FUNC(38)
   _CUnitTest_FUNC(39)
   _CUnitTest_FUNC(40)
   _CUnitTest_FUNC(41)
   _CUnitTest_FUNC(42)
   _CUnitTest_FUNC(43)
   _CUnitTest_FUNC(44)
   _CUnitTest_FUNC(45)
   _CUnitTest_FUNC(46)
   _CUnitTest_FUNC(47)
   _CUnitTest_FUNC(48)
   _CUnitTest_FUNC(49)
   _CUnitTest_FUNC(50)
   _CUnitTest_FUNC(51)
   _CUnitTest_FUNC(52)
   _CUnitTest_FUNC(53)
   _CUnitTest_FUNC(54)
   _CUnitTest_FUNC(55)
   _CUnitTest_FUNC(56)
   _CUnitTest_FUNC(57)
   _CUnitTest_FUNC(58)
   _CUnitTest_FUNC(59)
   _CUnitTest_FUNC(60)
   _CUnitTest_FUNC(61)
   _CUnitTest_FUNC(62)
   _CUnitTest_FUNC(63)
   _CUnitTest_FUNC(64)
   _CUnitTest_FUNC(65)
   _CUnitTest_FUNC(66)
   _CUnitTest_FUNC(67)
   _CUnitTest_FUNC(68)
   _CUnitTest_FUNC(69)
   _CUnitTest_FUNC(70)
   _CUnitTest_FUNC(71)
   _CUnitTest_FUNC(72)
   _CUnitTest_FUNC(73)
   _CUnitTest_FUNC(74)
   _CUnitTest_FUNC(75)
   _CUnitTest_FUNC(76)
   _CUnitTest_FUNC(77)
   _CUnitTest_FUNC(78)
   _CUnitTest_FUNC(79)
   _CUnitTest_FUNC(80)
   _CUnitTest_FUNC(81)
   _CUnitTest_FUNC(82)
   _CUnitTest_FUNC(83)
   _CUnitTest_FUNC(84)
   _CUnitTest_FUNC(85)
   _CUnitTest_FUNC(86)
   _CUnitTest_FUNC(87)
   _CUnitTest_FUNC(88)
   _CUnitTest_FUNC(89)
   _CUnitTest_FUNC(90)
   _CUnitTest_FUNC(91)
   _CUnitTest_FUNC(92)
   _CUnitTest_FUNC(93)
   _CUnitTest_FUNC(94)
   _CUnitTest_FUNC(95)
   _CUnitTest_FUNC(96)
   _CUnitTest_FUNC(97)
   _CUnitTest_FUNC(98)
   _CUnitTest_FUNC(99)
   _CUnitTest_FUNC(100)
};
