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

import java.io.IOException;
import java.lang.reflect.Field;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Locale;

public class MqlLibrary
{
   public static final int INVALID_HANDLE = -1;

   public static final int CHAR_VALUE = 1;
   public static final int SHORT_VALUE = 2;
   public static final int INT_VALUE = 4;

   public static final int FILE_READ = 1;
   public static final int FILE_WRITE = 2;
   public static final int FILE_BIN = 4;
   public static final int FILE_CSV = 8;
   public static final int FILE_TXT = 16;
   public static final int FILE_ANSI = 32;
   public static final int FILE_UNICODE = 64;
   public static final int FILE_SHARE_READ = 128;
   public static final int FILE_SHARE_WRITE = 256;
   public static final int FILE_REWRITE = 512;
   public static final int FILE_COMMON = 4096;

   public static final int SEEK_SET = 0;
   public static final int SEEK_CUR = 1;
   public static final int SEEK_END = 2;

   public static String typename(Class<?> clazz)
   {
      Class<?> type = clazz.isArray() ? clazz.getComponentType() : clazz;
      if (type.isAssignableFrom(Boolean.class)) {
         return "bool";
      }
      if (type.isAssignableFrom(Character.class)) {
         return "char";
      }
      if (type.isAssignableFrom(Short.class)) {
         return "short";
      }
      if (type.isAssignableFrom(Integer.class)) {
         return "int";
      }
      if (type.isAssignableFrom(Long.class)) {
         return "long";
      }
      if (type.isAssignableFrom(Float.class)) {
         return "float";
      }
      if (type.isAssignableFrom(Double.class)) {
         return "double";
      }
      if (type.isAssignableFrom(String.class)) {
         return "string";
      }
      return "";
   }

   public static <T> int ArraySize(T array[])
   {
      return array.length;
   }

   /*public static <T> int ArrayResize(T array[], int new_size)
   {
      array = new T[new_size];
      return new_size;
   }*/

   public static <T> int ArraySize(MqlArray<T> array)
   {
      return array.size();
   }

   public static <T> int ArrayResize(MqlArray<T> array, int new_size)
   {
      return ArrayResize(array, new_size, 0);
   }
   public static <T> int ArrayResize(MqlArray<T> array, int new_size, int reserve_size)
   {
      return array.resize(new_size, reserve_size);
   }

   public static int StringLen(final String str)
   {
      return str.length();
   }

   public static String DoubleToString(double value)
   {
      return DoubleToString(value, 8);
   }
   public static String DoubleToString(double value, int digits)
   {
      return String.format(Locale.ENGLISH, "%." + digits + "f", value);
   }

   protected static ArrayList<FileHandle> Handles = new ArrayList<>();

   public static FileHandle getFileHandle(int file_handle) throws IOException
   {
      if (file_handle <= INVALID_HANDLE || file_handle >= Handles.size()) {
         throw new IOException("INVALID_HANDLE");
      }
      return Handles.get(file_handle);
   }

   public static RandomAccessFileLE getRas(int file_handle) throws IOException
   {
      if (file_handle <= INVALID_HANDLE || file_handle >= Handles.size()) {
         throw new IOException("INVALID_HANDLE");
      }
      return Handles.get(file_handle).ras;
   }

   protected static class FileHandle
   {
      public RandomAccessFileLE ras;
      public int openFlags;
      public String delimiter;
      public Charset codepage;
      public int codepageBytes;

      public FileHandle(RandomAccessFileLE ras, int openFlags, String delimiter, long codepage)
      {
         this.ras = ras;
         this.openFlags = openFlags;
         this.delimiter = delimiter;
         this.codepage = Charset.forName("UTF-16LE");
         this.codepageBytes = 2;
         if ((openFlags & FILE_ANSI) != 0) {
            if (codepage == 0) {
               this.codepage = Charset.defaultCharset();
            } else {
               this.codepage = Charset.forName("cp" + codepage);
            }
            this.codepageBytes = 1;
         }
      }

      @Override
      protected void finalize() throws Throwable
      {
         close();
         super.finalize();
      }

      public void close() throws IOException
      {
         this.ras.close();
      }
   }

   public static void setBufferSize(int file_handle, int size)
   {
      try {
         getRas(file_handle).setBufferSize(size);
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

   protected static String PathFiles = "";
   protected static String PathFilesCommon =
           System.getenv("APPDATA") + "\\MetaQuotes\\Terminal\\Common\\Files";

   public static String getPathFiles()
   {
      return PathFiles;
   }

   public static void setPathFiles(String pathFiles)
   {
      PathFiles = pathFiles;
   }

   public static String getPathFilesCommon()
   {
      return PathFilesCommon;
   }

   public static void setPathFilesCommon(String pathFilesCommon)
   {
      PathFilesCommon = pathFilesCommon;
   }

   public static int FileOpen(String file_name, int open_flags)
   {
      return FileOpen(file_name, open_flags, "\t", 0);
   }
   public static int FileOpen(String file_name, int open_flags, String delimiter)
   {
      return FileOpen(file_name, open_flags, delimiter, 0);
   }
   public static int FileOpen(String file_name, int open_flags, String delimiter, long codepage)
   {
      try {
         RandomAccessFileLE ras;
         Path full_file_name = Paths.get(file_name);
         if (full_file_name.isAbsolute() == false) {
            full_file_name = Paths.get((((open_flags & FILE_COMMON) != 0) ? PathFilesCommon : PathFiles),
                    file_name);
         }
         if ((open_flags & (FILE_WRITE | FILE_REWRITE)) != 0) {
            ras = new RandomAccessFileLE(full_file_name.toFile(), "rw");
            ras.setLength(0);
            // UTF-16 BOM ?
         } else {
            ras = new RandomAccessFileLE(full_file_name.toFile(), "r");
         }
         Handles.add(new FileHandle(ras, open_flags, delimiter, codepage));
         return Handles.size() - 1;
      } catch (IOException e) {
         return INVALID_HANDLE;
      }
   }

   public static void FileClose(int file_handle)
   {
      try {
         getFileHandle(file_handle).close();
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

   public static void FileFlush(int file_handle)
   {
      try {
         getRas(file_handle).flush();
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

   public static boolean FileSeek(int file_handle, long offset, int origin)
   {
      try {
         long shift = 0;
         if (origin == SEEK_CUR) {
            shift = getRas(file_handle).tell();
         } else if (origin == SEEK_END) {
            shift = getRas(file_handle).length();
         }
         getRas(file_handle).seek(shift + offset);
         return true;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return false;
   }

   public static long FileTell(int file_handle)
   {
      try {
         return getRas(file_handle).tell();
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static boolean FileIsEnding(int file_handle)
   {
      try {
         return getRas(file_handle).isEnding();
      } catch (Exception e) {
         e.printStackTrace();
      }
      return true;
   }

   public static int FileWriteInteger(int file_handle, int value)
   {
      return FileWriteInteger(file_handle, value, INT_VALUE);
   }
   public static int FileWriteInteger(int file_handle, int value, int size)
   {
      try {
         if (size < CHAR_VALUE || size > INT_VALUE) {
            throw new Exception("Size error");
         }
         switch (size) {
            case CHAR_VALUE:
               getRas(file_handle).writeByte(value);
               break;
            case SHORT_VALUE:
               getRas(file_handle).writeShort(value);
               break;
            case INT_VALUE:
               getRas(file_handle).writeInt(value);
               break;
         }
         return size;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static int FileReadInteger(int file_handle)
   {
      return FileReadInteger(file_handle, INT_VALUE);
   }
   public static int FileReadInteger(int file_handle, int size)
   {
      try {
         if (size < CHAR_VALUE || size > INT_VALUE) {
            throw new Exception("Size error");
         }
         switch (size) {
            case CHAR_VALUE:
               return getRas(file_handle).readByte();
            case SHORT_VALUE:
               return getRas(file_handle).readShort();
            case INT_VALUE:
               return getRas(file_handle).readInt();
         }
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static int FileWriteLong(int file_handle, long value)
   {
      try {
         getRas(file_handle).writeLong(value);
         return 8;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static long FileReadLong(int file_handle)
   {
      try {
         return getRas(file_handle).readLong();
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static int FileWriteFloat(int file_handle, float value)
   {
      try {
         getRas(file_handle).writeFloat(value);
         return 4;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static float FileReadFloat(int file_handle)
   {
      try {
         return getRas(file_handle).readFloat();
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static int FileWriteDouble(int file_handle, double value)
   {
      try {
         getRas(file_handle).writeDouble(value);
         return 8;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static double FileReadDouble(int file_handle)
   {
      try {
         return getRas(file_handle).readDouble();
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static int FileWriteString(int file_handle, final String text)
   {
      return FileWriteString(file_handle, text, -1);
   }
   public static int FileWriteString(int file_handle, final String text, int length)
   {
      try {
         if (length == -1) {
            length = text.length();
         }
         byte[] str = text.getBytes(getFileHandle(file_handle).codepage);
         getRas(file_handle).write(str, 0, str.length);
         return length;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static int FileWrite(int file_handle, final String text)
   {
      return FileWriteString(file_handle, text + "\r\n");
   }

   public static String FileReadString(int file_handle, int length)
   {
      try {
         FileHandle file = getFileHandle(file_handle);
         if ((file.openFlags & FILE_BIN) != 0) {
            if (length < 1) {
               return "";
            }
            length *= file.codepageBytes;
            byte[] str = new byte[length];
            file.ras.read(str, 0, length);
            return file.codepage.decode(ByteBuffer.wrap(str)).toString();
         }
      } catch (Exception e) {
         e.printStackTrace();
      }
      return "";
   }

   public static long FileWriteArray(int file_handle, Object[] array)
   {
      return FileWriteArray(file_handle, array, 0, -1);
   }
   public static long FileWriteArray(int file_handle, Object[] array, int start)
   {
      return FileWriteArray(file_handle, array, start, -1);
   }
   public static long FileWriteArray(int file_handle, Object[] array, int start, int count)
   {
      try {
         if (start < 0 || count < -1) {
            throw new Exception("start < 0 || count < -1");
         }
         if (count == -1) {
            count = array.length - start;
         } else {
            count += start;
         }
         getRas(file_handle); // test handle
         long bytes = 0;
         if (array[start] instanceof Boolean || array[start] instanceof Character ||
                 array[start] instanceof Byte) {
            for (int x = start; x < count; x++) {
               bytes += FileWriteInteger(file_handle, (int)array[x], CHAR_VALUE);
            }
         } else if (array[start] instanceof Short) {
            for (int x = start; x < count; x++) {
               bytes += FileWriteInteger(file_handle, (int)array[x], SHORT_VALUE);
            }
         } else if (array[start] instanceof Integer) {
            for (int x = start; x < count; x++) {
               bytes += FileWriteInteger(file_handle, (int)array[x], INT_VALUE);
            }
         } else if (array[start] instanceof Long) {
            for (int x = start; x < count; x++) {
               bytes += FileWriteLong(file_handle, (long)array[x]);
            }
         } else if (array[start] instanceof Float) {
            for (int x = start; x < count; x++) {
               bytes += FileWriteFloat(file_handle, (float)array[x]);
            }
         } else if (array[start] instanceof Double) {
            for (int x = start; x < count; x++) {
               bytes += FileWriteDouble(file_handle, (double)array[x]);
            }
         } else {
            throw new IllegalArgumentException("Is unknown type");
         }
         return bytes;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   /*public static long FileReadArray(int file_handle, Object[] array)
   {
      return FileReadArray(file_handle, array, 0, -1);
   }
   public static long FileReadArray(int file_handle, Object[] array, int start)
   {
      return FileReadArray(file_handle, array, start, -1);
   }
   public static <T> long FileReadArray(int file_handle, MqlArray<T> array, int start, int count)
   {
      try {
         if (start < 0 || count < -1) {
            throw new Exception("start < 0 || count < -1");
         }
         /*if (count == -1) {
            count = array.size() - start;
         } else {
            count += start;
         }
         Object stream = Handles.get(file_handle).Stream;
         if (stream instanceof BinaryInputStream) {
            BinaryInputStream inputStream = (BinaryInputStream)stream;
            array.ensureCapacity(count);
            if (Boolean.class.isInstance(array) || Character.class.isInstance(array) ||
               Byte.class.isInstance(array)) {
               for (int x = start; x < count; x++) {
                  array.add(FileReadInteger(file_handle, CHAR_VALUE));
               }
            } else if (Short.class.isInstance(array)) {
               for (int x = start; x < count; x++) {
                  array.add(FileReadInteger(file_handle, SHORT_VALUE));
               }
            } else if (Integer.class.isInstance(array)) {
               for (int x = start; x < count; x++) {
                  array.add(FileReadInteger(file_handle, INT_VALUE));
               }
            } else if (Long.class.isInstance(array)) {
               for (int x = start; x < count; x++) {
                  array.add(FileReadLong(file_handle));
               }
            } else if (Float.class.isInstance(array)) {
               for (int x = start; x < count; x++) {
                  array.add(FileReadFloat(file_handle));
               }
            } else if (Double.class.isInstance(array)) {
               for (int x = start; x < count; x++) {
                  array.add(inputStream.readDouble());
               }
            } else {
               throw new IllegalArgumentException("Is unknown type");
            }
            return array.size() - start;
         } else {
            throw new Exception("Not InputStream");
         }
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }*/
   public static long FileReadArray(int file_handle, MqlArray<Double> array, int start, int count)
   {
      try {
         if (start < 0 || count < -1) {
            throw new Exception("start < 0 || count < -1");
         }
         /*if (count == -1) {
            count = array.size() - start;
         } else {
            count += start;
         }*/
         RandomAccessFileLE ras = getRas(file_handle);
         array.resize(start, count);
         for (int x = start; x < count; x++) {
            array.add(ras.readDouble());
         }
         return array.size() - start;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   public static long FileWriteStruct(int file_handle, Object value)
   {
      return FileWriteStruct(file_handle, value, -1);
   }
   public static long FileWriteStruct(int file_handle, Object value, int size)
   {
      try {
         long bytes = 0;
         Class struct = value.getClass();
         Field thisfield = null;
         try {
            thisfield = struct.getDeclaredField("this$0");
         } catch (NoSuchFieldException e) {
         }
         for (Field field : struct.getDeclaredFields()) {
            if (size != -1 && size < bytes) {
               System.out.println("FileWriteStruct size < bytes");
               break;
            }
            if (thisfield != null && field.equals(thisfield)) {
               continue;
            }
            Class fldtype = field.getType();
            if (!fldtype.isPrimitive()) {
               throw new IllegalArgumentException(field.getName() + " is not Primitive in " +
                       value.getClass().getName());
            }
            if (fldtype.isArray()) {
               System.out.println("FileWriteStruct ARRAY");
               continue;
            }
            if (fldtype.equals(boolean.class) || fldtype.equals(Boolean.class) ||
                    fldtype.equals(char.class) || fldtype.equals(Character.class) ||
                    fldtype.equals(byte.class) || fldtype.equals(Byte.class))
            {
               bytes += FileWriteInteger(file_handle, field.getInt(value), CHAR_VALUE);
            } else if (fldtype.equals(short.class) || fldtype.equals(Short.class)) {
               bytes += FileWriteInteger(file_handle, field.getInt(value), SHORT_VALUE);
            } else if (fldtype.equals(int.class) || fldtype.equals(Integer.class)) {
               bytes += FileWriteInteger(file_handle, field.getInt(value), INT_VALUE);
            } else if (fldtype.equals(long.class) || fldtype.equals(Long.class)) {
               bytes += FileWriteLong(file_handle, field.getLong(value));
            } else if (fldtype.equals(float.class) || fldtype.equals(Float.class)) {
               bytes += FileWriteFloat(file_handle, field.getFloat(value));
            } else if (fldtype.equals(double.class) || fldtype.equals(Double.class)) {
               bytes += FileWriteDouble(file_handle, field.getDouble(value));
            } else {
               throw new IllegalArgumentException(field.getName() + " is unknown type in " +
                       value.getClass().getName());
            }
         }
         return bytes;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0;
   }

   /*public static long FileWriteArray(int file_handle, final boolean array[])
   {
      Boolean[] booleans = new Boolean[array.length];
      for (int x = array.length-1; x > -1; x--) {
         booleans[x] = array[x];
      }
      return FileWriteArray(file_handle, booleans);
   }
   public static long FileWriteArray(int file_handle, final byte array[])
   {
      Byte[] bytes = new Byte[array.length];
      for (int x = array.length-1; x > -1; x--) {
         bytes[x] = array[x];
      }
      return FileWriteArray(file_handle, bytes);
   }
   public static long FileWriteArray(int file_handle, final char array[])
   {
      Character[] characters = new Character[array.length];
      for (int x = array.length-1; x > -1; x--) {
         characters[x] = array[x];
      }
      return FileWriteArray(file_handle, characters);
   }
   public static long FileWriteArray(int file_handle, final short array[])
   {
      Short[] shorts = new Short[array.length];
      for (int x = array.length-1; x > -1; x--) {
         shorts[x] = array[x];
      }
      return FileWriteArray(file_handle, shorts);
   }
   public static long FileWriteArray(int file_handle, final int array[])
   {
      Integer[] ints = new Integer[array.length];
      for (int x = array.length-1; x > -1; x--) {
         ints[x] = array[x];
      }
      return FileWriteArray(file_handle, ints);
   }
   public static long FileWriteArray(int file_handle, final long array[])
   {
      Long[] longs = new Long[array.length];
      for (int x = array.length-1; x > -1; x--) {
         longs[x] = array[x];
      }
      return FileWriteArray(file_handle, longs);
   }
   public static long FileWriteArray(int file_handle, final float array[])
   {
      Float[] floats = new Float[array.length];
      for (int x = array.length-1; x > -1; x--) {
         floats[x] = array[x];
      }
      return FileWriteArray(file_handle, floats);
   }*/
   public static long FileWriteArray(int file_handle, final double array[])
   {
      Double[] doubles = new Double[array.length];
      for (int x = array.length-1; x > -1; x--) {
         doubles[x] = array[x];
      }
      return FileWriteArray(file_handle, doubles);
   }
}
