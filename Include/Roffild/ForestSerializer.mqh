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
#include <Math/Alglib/dataanalysis.mqh>

/**
 * Save and load data for the class CDecisionForest (Alglib).
 */
class CForestSerializer
{
public:
   /**
    * Save to the text format Alglib (very slow).
    */
   static void toText(CDecisionForest &forest, int hfile)
   {
      CSerializer ser;
      ser.Alloc_Start();
      CDForest::DFAlloc(ser, forest);
      ser.SStart_Str();
      CDForest::DFSerialize(ser, forest);
      ser.Stop();
      FileWrite(hfile, ser.Get_String());
   }

   /**
    * Save to the text format Alglib (very slow).
    */
   static bool toText(CDecisionForest &forest, const string filename, const bool common = true)
   {
      int hfile = FileOpen(filename, FILE_TXT|FILE_WRITE|(common ? FILE_COMMON : 0));
      if (hfile == INVALID_HANDLE) {
         return false;
      }
      toText(forest, hfile);
      FileClose(hfile);
      return true;
   }

   /**
    * Load from the text format Alglib (very slow).
    */
   static void fromText(CDecisionForest &forest, int hfile)
   {
      CSerializer ser;
      string dump = "";
      while (FileIsEnding(hfile) == false) {
         dump += " " + FileReadString(hfile);
      }
      ser.UStart_Str(dump);
      CDForest::DFUnserialize(ser, forest);
      ser.Stop();
   }

   /**
    * Load from the text format Alglib (very slow).
    */
   static bool fromText(CDecisionForest &forest, const string filename, const bool common = true)
   {
      int hfile = FileOpen(filename, FILE_TXT|FILE_READ|FILE_SHARE_READ|(common ? FILE_COMMON : 0));
      if (hfile == INVALID_HANDLE) {
         return false;
      }
      fromText(forest, hfile);
      FileClose(hfile);
      return true;
   }

   /**
    * Save to the binary format (fast).
    */
   static void toBinary(CDecisionForest &forest, int hfile)
   {
      FileWriteInteger(hfile, forest.m_nvars);
      FileWriteInteger(hfile, forest.m_nclasses);
      FileWriteInteger(hfile, forest.m_ntrees);
      FileWriteInteger(hfile, forest.m_bufsize);
      FileWriteArray(hfile, forest.m_trees);
   }

   /**
    * Save to the binary format (fast).
    */
   static bool toBinary(CDecisionForest &forest, const string filename, const bool common = true)
   {
      int hfile = FileOpen(filename, FILE_BIN|FILE_WRITE|(common ? FILE_COMMON : 0));
      if (hfile == INVALID_HANDLE) {
         return false;
      }
      toBinary(forest, hfile);
      FileClose(hfile);
      return true;
   }

   /**
    * Load from the binary format (fast).
    */
   static void fromBinary(CDecisionForest &forest, int hfile)
   {
      forest.m_nvars = FileReadInteger(hfile);
      forest.m_nclasses = FileReadInteger(hfile);
      forest.m_ntrees = FileReadInteger(hfile);
      forest.m_bufsize = FileReadInteger(hfile);
      ArrayResize(forest.m_trees, forest.m_bufsize);
      FileReadArray(hfile, forest.m_trees, 0, forest.m_bufsize);
   }

   /**
    * Load from the binary format (fast).
    */
   static bool fromBinary(CDecisionForest &forest, const string filename, const bool common = true)
   {
      int hfile = FileOpen(filename, FILE_BIN|FILE_READ|FILE_SHARE_READ|(common ? FILE_COMMON : 0));
      if (hfile == INVALID_HANDLE) {
         return false;
      }
      fromBinary(forest, hfile);
      FileClose(hfile);
      return true;
   }
};
