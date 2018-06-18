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

/// ArrayList from Java.
template<typename Type>
class CArrayList
{
protected:
   Type elements[];
   int reserve;

   bool removeList(const Type &list[], bool saveOnlyList = false)
   {
      int ltcount = ArraySize(list);
      if (ltcount == 0) {
         return false;
      }
      int elcount = ArraySize(elements);
      int last = 0;
      for (int x = 0; x < elcount && last < elcount; x++) {
         bool found = false;
         for (int y = ltcount-1; y > -1; y--) {
            if (elements[x] == list[y]) {
               found = true;
               break;
            }
         }
         if (found != saveOnlyList) {
            continue;
         }
         if (x > last) {
            elements[last] = elements[x];
         }
         last++;
      }
      if (last < elcount) {
         ArrayResize(elements, last, reserve);
         return true;
      }
      return false;
   }

public:
   CArrayList(int _reserve = 0)
   {
      reserve = _reserve;
   }

   int getReserve()
   {
      return reserve;
   }
   void setReserve(int _reserve)
   {
      reserve = _reserve;
   }

   /// Appends the specified element to the end of this list.
   bool add(const Type element)
   {
      return add(ArraySize(elements), element);
   }

   /// Inserts the specified element at the specified position in this list.
   bool add(int index, const Type element)
   {
      if (index < 0) {
         return false;
      }

      int start = ArraySize(elements);
      if (ArrayResize(elements, start+1, reserve) > -1) {
         if (index < start) {
            for (int x = ArraySize(elements)-1; start > index; x--, start--) {
               elements[x] = elements[start-1];
            }
         }
         elements[start] = element;
         return true;
      }
      return false;
   }

   /// Appends all of the elements in the specified collection to the end of this list.
   bool addAll(const Type &list[])
   {
      return addAll(ArraySize(elements), list);
   }
   /// Appends all of the elements in the specified collection to the end of this list.
   bool addAll(const CArrayList<Type> &list)
   {
      return addAll(ArraySize(elements), list.elements);
   }

   /// Inserts all of the elements in the specified collection into this list,
   /// starting at the specified position.
   bool addAll(int index, const Type &list[])
   {
      if (index < 0) {
         return false;
      }

      int start = ArraySize(elements);
      int count = ArraySize(list);
      if (ArrayResize(elements, start + count, reserve) > -1) {
         if (index < start) {
            for (int x = ArraySize(elements)-1; start > index; x--, start--) {
               elements[x] = elements[start-1];
            }
         }
         return ArrayCopy(elements, list, start) > 0;
      }
      return false;
   }
   /// Inserts all of the elements in the specified collection into this list,
   /// starting at the specified position.
   bool addAll(int index, const CArrayList<Type> &list)
   {
      return addAll(index, list.elements);
   }

   /// Removes all of the elements from this list.
   void clear()
   {
      ArrayResize(elements, 0, reserve);
   }

   // / Returns a shallow copy of this ArrayList instance.
   //Object clone()

   /// Returns true if this list contains the specified element.
   bool contains(const Type o)
   {
      return indexOf(o) > -1;
   }

   // / Increases the capacity of this ArrayList instance, if necessary,
   // / to ensure that it can hold at least the number of elements
   // / specified by the minimum capacity argument.
   //void ensureCapacity(int minCapacity)

   // / Performs the given action for each element of the Iterable until all elements
   // / have been processed or the action throws an exception.
   //void forEach(Consumer<? super E> action)

   /// Returns the element at the specified position in this list.
   Type get(int index)
   {
      return elements[index];
   }
   /// Returns the element at the specified position in this list.
   Type operator[](int index)
   {
      return get(index);
   }

   /// Replaces the element at the specified position in this list with the specified element.
   Type set(int index, const Type element)
   {
      Type oldvalue = get(index);
      elements[index] = element;
      return oldvalue;
   }

   /// Returns the index of the first occurrence of the specified element in this list,
   /// or -1 if this list does not contain the element.
   int indexOf(const Type o)
   {
      int count = ArraySize(elements);
      for (int x = 0; x < count; x++) {
         if (elements[x] == o) {
            return x;
         }
      }
      return -1;
   }

   /// Returns the index of the last occurrence of the specified element in this list,
   /// or -1 if this list does not contain the element.
   int lastIndexOf(const Type o)
   {
      int count = ArraySize(elements);
      for (int x = count-1; x > -1; x--) {
         if (elements[x] == o) {
            return x;
         }
      }
      return -1;
   }

   /// Returns true if this list contains no elements.
   bool isEmpty()
   {
      return ArraySize(elements) == 0;
   }

   /// Removes the element at the specified position in this list.
   Type remove(int index)
   {
      int count = ArraySize(elements);
      if (index < 0) {
         return NULL;
      }
      Type oldvalue = set(index, NULL);
      if (index < count-1) {
         ArrayCopy(elements, elements, index, index+1);
      }
      ArrayResize(elements, count-1, reserve);
      return oldvalue;
   }

   /// Removes the first occurrence of the specified element from this list, if it is present.
   bool removeFirst(const Type o)
   {
      int index = indexOf(o);
      if (index == -1) {
         return false;
      }
      remove(index);
      return true;
   }

   /// Removes from this list all of its elements that are contained in the specified collection.
   bool removeAll(const Type &list[])
   {
      return removeList(list, false);
   }

   /// Retains only the elements in this list that are contained in the specified collection.
   bool retainAll(const Type &list[])
   {
      return removeList(list, true);
   }

   // / Removes all of the elements of this collection that satisfy the given predicate.
   //bool removeIf(Predicate<? super E> filter)

   // / Removes from this list all of the elements whose index is between fromIndex,
   // / inclusive, and toIndex, exclusive.
   //protected void removeRange(int fromIndex, int toIndex)

   // / Replaces each element of this list with the result of applying the operator to that element.
   //void replaceAll(UnaryOperator<E> operator)

   /// Returns the number of elements in this list.
   int size()
   {
      return ArraySize(elements);
   }

   // / Sorts this list according to the order induced by the specified Comparator.
   //void sort(Comparator<? super E> c)

   /// @see https://www.mql5.com/en/docs/array/arraycopy
   int subList(Type &dst_array[], int dst_start = 0, int src_start = 0, int count = WHOLE_ARRAY)
   {
      return ArrayCopy(dst_array, elements, dst_start, src_start, count);
   }

   /// Returns an array containing all of the elements in this list in proper sequence
   /// (from first to last element).
   void toArray(Type &dst_array[])
   {
      ArrayCopy(dst_array, elements);
   }
};
