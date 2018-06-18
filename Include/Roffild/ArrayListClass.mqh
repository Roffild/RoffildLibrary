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

/// ArrayList from Java for Class only
template<typename Type>
class CArrayListClass
{
protected:
   Type *elements[];
   int reserve;
   bool useDelete; ///< Use delete() when cleaning?

   // Всё, что требует сравнение классов мне сейчас не нужно...
   //bool removeList(const Type *&list[], bool saveOnlyList = false)
   //{
   //         if (elements[x].compare(list[y])) {
   //}

public:
   CArrayListClass(bool _useDelete = true, int _reserve = 0)
   {
      reserve = _reserve;
      useDelete = _useDelete;
   }

   ~CArrayListClass()
   {
      clear();
   }

   int getReserve()
   {
      return reserve;
   }
   void setReserve(int _reserve)
   {
      reserve = _reserve;
   }

   /// Use delete() when cleaning?
   bool getUseDelete()
   {
      return useDelete;
   }
   /// Use delete() when cleaning?
   void setUseDelete(bool _useDelete)
   {
      useDelete = _useDelete;
   }

   /// Appends the specified element to the end of this list.
   bool add(Type *element)
   {
      return add(ArraySize(elements), element);
   }

   /// Inserts the specified element at the specified position in this list.
   bool add(int index, Type *element)
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
   bool addAll(const Type *&list[])
   {
      return addAll(ArraySize(elements), list);
   }
   /// Appends all of the elements in the specified collection to the end of this list.
   bool addAll(const CArrayListClass<Type> &list)
   {
      return addAll(ArraySize(elements), list);
   }

   /// Inserts all of the elements in the specified collection into this list,
   /// starting at the specified position.
   bool addAll(int index, const Type * const &list[])
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
   bool addAll(int index, const CArrayListClass<Type> &list)
   {
      return addAll(index, list.elements);
   }

   /// Removes all of the elements from this list.
   void clear()
   {
      if (useDelete) {
         for (int x = ArraySize(elements) - 1; x > -1; x--) {
            delete(elements[x]);
         }
      }
      ArrayResize(elements, 0, reserve);
   }

   // / Returns a shallow copy of this ArrayList instance.
   //Object clone()

   // / Increases the capacity of this ArrayList instance, if necessary,
   // / to ensure that it can hold at least the number of elements
   // / specified by the minimum capacity argument.
   //void ensureCapacity(int minCapacity)

   // / Performs the given action for each element of the Iterable until all elements
   // / have been processed or the action throws an exception.
   //void forEach(Consumer<? super E> action)

   /// Returns the element at the specified position in this list.
   Type* get(int index)
   {
      return elements[index];
   }
   /// Returns the element at the specified position in this list.
   Type* operator[](int index)
   {
      return get(index);
   }

   /// Replaces the element at the specified position in this list with the specified element.
   void set(int index, Type *element)
   {
      if (useDelete) {
         delete(get(index));
      }
      elements[index] = element;
   }

   /// Returns true if this list contains no elements.
   bool isEmpty()
   {
      return ArraySize(elements) == 0;
   }

   /// Removes the element at the specified position in this list.
   void remove(int index)
   {
      int count = ArraySize(elements);
      if (index < 0) {
         return;
      }
      if (useDelete) {
         delete(get(index));
      }
      if (index < count-1) {
         ArrayCopy(elements, elements, index, index+1);
      }
      ArrayResize(elements, count-1, reserve);
   }

   /// Returns the number of elements in this list.
   int size()
   {
      return ArraySize(elements);
   }

   /// @see https://www.mql5.com/en/docs/array/arraycopy
   int subList(Type *&dst_array[], int dst_start = 0, int src_start = 0, int count = WHOLE_ARRAY)
   {
      return ArrayCopy(dst_array, elements, dst_start, src_start, count);
   }

   /// Returns an array containing all of the elements in this list in proper sequence
   /// (from first to last element).
   void toArray(Type *&dst_array[])
   {
      ArrayCopy(dst_array, elements);
   }
};
