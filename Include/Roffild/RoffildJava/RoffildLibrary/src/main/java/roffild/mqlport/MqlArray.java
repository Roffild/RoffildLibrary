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
package roffild.mqlport;

import java.lang.reflect.Field;
import java.util.ArrayList;

public class MqlArray<E> extends ArrayList<E>
{
   public boolean isSeria = false;

   public int resize(int newSize, int reserve)
   {
      if (newSize < 1) {
         clear();
      } else if (newSize < size()) {
         removeRange(newSize, size());
      } else if (newSize > size()) {
         try {
            final int DEFAULT_CAPACITY = 10; // from ArrayList
            ensureCapacity(newSize > DEFAULT_CAPACITY ? newSize : DEFAULT_CAPACITY + 1);
            Field field = this.getClass().getSuperclass().getDeclaredField("size");
            field.setAccessible(true);
            field.setInt(this, newSize);
            field.setAccessible(false);
         } catch (Exception e) {
            e.printStackTrace();
         }
      }
      if (reserve > 0) {
         final int res = reserve - (size() % reserve);
         ensureCapacity(size() + (res > 0 ? res : reserve));
      }
      return size();
   }
}
