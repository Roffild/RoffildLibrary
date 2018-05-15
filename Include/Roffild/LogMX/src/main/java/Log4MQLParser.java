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
import java.text.SimpleDateFormat;
import java.util.Date;

import com.lightysoft.logmx.business.ParsedEntry;
import com.lightysoft.logmx.mgr.LogFileParser;

public class Log4MQLParser extends LogFileParser
{
   public static void main(String[] args) throws Exception
   {
      Log4MQLParser test = new Log4MQLParser();
      test.testParser("GL\t0\t06:24:36.029\tCore 1\t2014.09.29 00:00:00   ERROR: UnitTest 2");
   }

   public void testParser(String line) throws Exception
   {
      parseLine(line);
   }

   @Override
   public String getParserName()
   {
      return "Log4MQL";
   }

   @Override
   public String getSupportedFileType()
   {
      return "MetaTrader Log + Log4MQL";
   }

   private final static SimpleDateFormat absDATE_FORMAT = new SimpleDateFormat("HH:mm:ss.SSS dd.MM.yyyy");
   @Override
   public Date getAbsoluteEntryDate(ParsedEntry arg0) throws Exception
   {
      return absDATE_FORMAT.parse(arg0.getDate());
   }

   @Override
   public Date getRelativeEntryDate(ParsedEntry arg0) throws Exception
   {
      return null;
   }

   private final static SimpleDateFormat parseDATE_FORMAT1 = new SimpleDateFormat("HH:mm:ss.SSSyyyyMMdd");
   private final static SimpleDateFormat parseDATE_FORMAT2 = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
   @Override
   protected void parseLine(String arg0) throws Exception
   {
      if (arg0 == null) {
         return;
      }

      String[] field = arg0.split("\\t");
      String message = field[4];
      String level = field[1];

      boolean CLog4MqlFile = false;
      String date = "";
      try {
         if (field[3].substring(0, 5).equals("Core ") && Integer.parseInt(field[3].substring(5)) > 0) {
            date = absDATE_FORMAT.format(parseDATE_FORMAT2.parse(message.substring(0, 20)));
            message = message.substring(22);
         } else if (field[0].equals("--")) {
            CLog4MqlFile = true;
            date = absDATE_FORMAT.format(parseDATE_FORMAT2.parse(field[2]));
         }
      } catch (Exception e) {}

      int pos;
      if (level.equals("2")) {
         level = "FATAL";
      } else if (level.equals("1")) {
         level = "WARNING";
      } else if ((pos = message.indexOf(':')) > -1) {
         level = message.substring(0, pos).toUpperCase();
         switch (level) {
            case "ERROR":
            case "WARNING":
            case "WARN":
            case "INFO":
            case "DEBUG":
            case "TRACE":
               message = message.substring(pos + 1).trim();
               break;
            default:
               level = "INFO";
               break;
         }
      } else {
         level = "INFO";
      }

      ParsedEntry entry = createNewEntry();
      entry.setEmitter(field[3]);
      if (CLog4MqlFile) {
         entry.setDate(date);
      } else {
         entry.setDate(absDATE_FORMAT.format((parseDATE_FORMAT1.parse(field[2] + getParsedFileName().substring(
                 getParsedFileName().lastIndexOf(System.getProperty("file.separator")) + 1).substring(0, 8)))));
         if (!date.isEmpty()) {
            message = date + "  " + message;
         }
      }
      entry.setLevel(level);
      entry.setMessage(message);
      addEntry(entry);
   }
}
