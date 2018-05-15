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

import java.io.*;
import java.nio.channels.FileChannel;
import java.util.Arrays;

public class RandomAccessFileLE implements DataOutput, DataInput, Closeable, Flushable
{
   protected RandomAccessFile ras;
   protected byte[] buffer = new byte[8 * 1024];
   protected int bufsize = 0;
   protected int bufpos = 0;
   protected boolean readOnly = true;
   protected boolean writeFlag = false;

   public RandomAccessFileLE(String name, String mode) throws FileNotFoundException
   {
      ras = new RandomAccessFile(name, mode);
      if (mode.contains("w")) {
         readOnly = false;
      }
   }

   public RandomAccessFileLE(File file, String mode) throws FileNotFoundException
   {
      ras = new RandomAccessFile(file, mode);
      if (mode.contains("w")) {
         readOnly = false;
      }
   }

   public FileDescriptor getFD() throws IOException
   {
      return ras.getFD();
   }

   public FileChannel getChannel()
   {
      return ras.getChannel();
   }

   @Override
   public void flush() throws IOException
   {
      if (writeFlag) {
         ras.write(buffer, 0, bufsize);
         bufsize = 0;
         bufpos = 0;
         writeFlag = false;
      }
      long pos = bufsize - bufpos;
      if (pos > 0) {
         ras.seek(ras.getFilePointer() - pos);
      }
      bufsize = 0;
      bufpos = 0;
   }

   public long tell() throws IOException
   {
      if (writeFlag) {
         flush();
      }
      return ras.getFilePointer() - (bufsize - bufpos);
   }

   public long getFilePointerReal() throws IOException
   {
      return ras.getFilePointer();
   }

   public void seek(long pos) throws IOException
   {
      flush();
      ras.seek(pos);
   }

   public long length() throws IOException
   {
      return ras.length();
   }

   public void setLength(long newLength) throws IOException
   {
      flush();
      ras.setLength(newLength);
   }

   public void setBufferSize(int size) throws IOException
   {
      if (size < 1) {
         throw new IndexOutOfBoundsException("size < 1");
      }
      flush();
      buffer = new byte[size];
   }

   public boolean isEnding() throws IOException
   {
      if (writeFlag) {
         flush();
      }
      if (bufpos < bufsize) {
         return false;
      }
      long pos = ras.getFilePointer();
      if (ras.read() < 0) {
         return true;
      }
      ras.seek(pos);
      return false;
   }

   public int read() throws IOException
   {
      if (writeFlag) {
         flush();
      }
      if (bufpos < bufsize) {
         bufpos++;
         return buffer[bufpos - 1] & 0xFF;
      }
      bufsize = ras.read(buffer, 0, buffer.length);
      bufpos = 0;
      if (bufsize < 0) {
         bufsize = 0;
         return -1;
      }
      return read();
   }

   public int read(byte[] b) throws IOException
   {
      return read(b, 0, b.length);
   }

   public int read(byte[] b, int off, int len) throws IOException
   {
      if (b == null) {
         throw new NullPointerException("b == null");
      }
      if (off < 0 || len < 0 || len > (b.length - off)) {
         throw new IndexOutOfBoundsException("off(" + off + ") < 0 || len(" + len +
                 ") < 0 || len > (b.length(" + b.length + ") - off)");
      }
      int boff = read();
      if (boff < 0) {
         return -1;
      }
      b[off] = (byte)boff;
      boff = off + 1;
      int size = len - boff;
      int bfsize = bufsize - bufpos;
      if (bfsize > 0) {
         int length = Math.min(size, bfsize);
         System.arraycopy(buffer, bufpos, b, boff, length);
         bufpos += length;
         boff += length;
         size = len - boff;
      }
      int shift = boff - off;
      if (size > 0) {
         int count = ras.read(b, boff, size);
         if (count < 0) {
            return shift > 0 ? shift : -1;
         }
         return shift + count;
      }
      return shift;
   }

   @Override
   public void readFully(byte[] b) throws IOException
   {
      readFully(b, 0, b.length);
   }

   @Override
   public void readFully(byte[] b, int off, int len) throws IOException
   {
      int n = 0;
      do {
         int count = this.read(b, off + n, len - n);
         if (count < 0)
            throw new EOFException();
         n += count;
      } while (n < len);
   }

   @Override
   public int skipBytes(int n) throws IOException
   {
      if (n <= 0) {
         return 0;
      }
      flush();
      return ras.skipBytes(n);
   }

   @Override
   public boolean readBoolean() throws IOException
   {
      int ch = read();
      if (ch < 0)
         throw new EOFException();
      return (ch != 0);
   }

   @Override
   public byte readByte() throws IOException
   {
      int ch = read();
      if (ch < 0)
         throw new EOFException();
      return (byte)(ch);
   }

   @Override
   public int readUnsignedByte() throws IOException
   {
      int ch = read();
      if (ch < 0)
         throw new EOFException();
      return ch;
   }

   @Override
   public short readShort() throws IOException
   {
      int ch1 = read();
      int ch2 = read();
      if ((ch1 | ch2) < 0)
         throw new EOFException();
      return (short)((ch1 << 0) + (ch2 << 8));
   }

   @Override
   public int readUnsignedShort() throws IOException
   {
      int ch1 = read();
      int ch2 = read();
      if ((ch1 | ch2) < 0)
         throw new EOFException();
      return (ch1 << 0) + (ch2 << 8);
   }

   @Override
   public char readChar() throws IOException
   {
      int ch1 = read();
      int ch2 = read();
      if ((ch1 | ch2) < 0)
         throw new EOFException();
      return (char)((ch1 << 0) + (ch2 << 8));
   }

   @Override
   public int readInt() throws IOException
   {
      int ch1 = read();
      int ch2 = read();
      int ch3 = read();
      int ch4 = read();
      if ((ch1 | ch2 | ch3 | ch4) < 0)
         throw new EOFException();
      return ((ch1 << 0) + (ch2 << 8) + (ch3 << 16) + (ch4 << 24));
   }

   @Override
   public long readLong() throws IOException
   {
      return (readInt() & 0xFFFFFFFFL) + ((long)(readInt()) << 32);
   }

   @Override
   public float readFloat() throws IOException
   {
      return Float.intBitsToFloat(readInt());
   }

   @Override
   public double readDouble() throws IOException
   {
      return Double.longBitsToDouble(readLong());
   }

   @Override
   public String readLine() throws IOException
   {
      StringBuffer input = new StringBuffer();
      int c = -1;
      boolean eol = false;

      while (!eol) {
         switch (c = read()) {
            case -1:
            case '\n':
               eol = true;
               break;
            case '\r':
               eol = true;
               long cur = tell();
               if ((read()) != '\n') {
                  seek(cur);
               }
               break;
            default:
               input.append((char)c);
               break;
         }
      }

      if ((c == -1) && (input.length() == 0)) {
         return null;
      }
      return input.toString();
   }

   @Override
   public String readUTF() throws IOException
   {
      return DataInputStream.readUTF(this);
   }

   @Override
   public void write(int b) throws IOException
   {
      if (readOnly) {
         ras.write(1); //for IOException
      }
      if (writeFlag == false) {
         flush();
      }
      if (bufpos < buffer.length) {
         bufsize++;
         bufpos++;
         buffer[bufpos - 1] = (byte)b;
         writeFlag = true;
         return;
      }
      flush();
      write(b);
   }

   @Override
   public void write(byte[] b) throws IOException
   {
      write(b, 0, b.length);
   }

   @Override
   public void write(byte[] b, int off, int len) throws IOException
   {
      if (b == null) {
         throw new NullPointerException("b == null");
      }
      if (off < 0 || len < 0 || len > (b.length - off)) {
         throw new IndexOutOfBoundsException("off(" + off + ") < 0 || len(" + len +
                 ") < 0 || len > (b.length(" + b.length + ") - off)");
      }
      if (readOnly) {
         ras.write(1); //for IOException
      }
      if (writeFlag == false) {
         flush();
      }
      int size = len - off;
      if ((bufsize + size) <= buffer.length) {
         System.arraycopy(b, off, buffer, bufsize, size);
         bufsize += size;
         bufpos = bufsize;
         writeFlag = true;
         return;
      }
      flush();
      ras.write(b, off, len);
   }

   @Override
   public void writeBoolean(boolean v) throws IOException
   {
      write(v ? 1 : 0);
      //written++;
   }

   @Override
   public void writeByte(int v) throws IOException
   {
      write(v);
      //written++;
   }

   @Override
   public void writeShort(int v) throws IOException
   {
      write((v >>> 0) & 0xFF);
      write((v >>> 8) & 0xFF);
      //written += 2;
   }

   @Override
   public void writeChar(int v) throws IOException
   {
      write((v >>> 0) & 0xFF);
      write((v >>> 8) & 0xFF);
      //written += 2;
   }

   @Override
   public void writeInt(int v) throws IOException
   {
      write((v >>> 0) & 0xFF);
      write((v >>> 8) & 0xFF);
      write((v >>> 16) & 0xFF);
      write((v >>> 24) & 0xFF);
      //written += 4;
   }

   @Override
   public void writeLong(long v) throws IOException
   {
      write((int)(v >>> 0) & 0xFF);
      write((int)(v >>> 8) & 0xFF);
      write((int)(v >>> 16) & 0xFF);
      write((int)(v >>> 24) & 0xFF);
      write((int)(v >>> 32) & 0xFF);
      write((int)(v >>> 40) & 0xFF);
      write((int)(v >>> 48) & 0xFF);
      write((int)(v >>> 56) & 0xFF);
      //written += 8;
   }

   @Override
   public void writeFloat(float v) throws IOException
   {
      writeInt(Float.floatToIntBits(v));
   }

   @Override
   public void writeDouble(double v) throws IOException
   {
      writeLong(Double.doubleToLongBits(v));
   }

   @Override
   @SuppressWarnings("deprecation")
   public void writeBytes(String s) throws IOException
   {
      int len = s.length();
      byte[] b = new byte[len];
      s.getBytes(0, len, b, 0);
      write(b, 0, len);
   }

   @Override
   public void writeChars(String s) throws IOException
   {
      int clen = s.length();
      int blen = 2 * clen;
      byte[] b = new byte[blen];
      char[] c = new char[clen];
      s.getChars(0, clen, c, 0);
      for (int i = 0, j = 0; i < clen; i++) {
         b[j++] = (byte)(c[i] >>> 0);
         b[j++] = (byte)(c[i] >>> 8);
      }
      write(b, 0, blen);
   }

   @Override
   public void writeUTF(String str) throws IOException
   {
      throw new IOException("writeUTF() not work");
      //DataOutputStream.writeUTF(str, this);
   }

   @Override
   public void close() throws IOException
   {
      try {
         flush();
      } finally {
         ras.close();
      }
   }
}
