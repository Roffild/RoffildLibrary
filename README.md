# Roffild's Library

* Experts/Roffild/
  * [AmazonUtils](Experts/Roffild/AmazonUtils) - can be used as an example of developing a project in Java
  * [Alglib_MultilayerPerceptron.mq5](Experts/Roffild/Alglib_MultilayerPerceptron.mq5)
  * [Alglib_RandomForest.mq5](Experts/Roffild/Alglib_RandomForest.mq5)
  * [Examples/](Experts/Roffild/Examples/)
    * [ToIndicator_Example.mq5](Experts/Roffild/Examples/ToIndicator_Example.mq5)
* Include/Roffild/
  * [MLPDataFile.mqh](Include/Roffild/MLPDataFile.mqh) - data format for Alglib_MultilayerPerceptron and Alglib_RandomForest
  * [ArrayList_macros.mqh](Include/Roffild/ArrayList_macros.mqh) - this variant is still used because of poor template support by the code editor
  * [ArrayList.mqh](Include/Roffild/ArrayList.mqh)
  * [ArrayListClass.mqh](Include/Roffild/ArrayListClass.mqh)
  * [CsvFile.mqh](Include/Roffild/CsvFile.mqh)
  * [ForestSerializer.mqh](Include/Roffild/ForestSerializer.mqh)
  * [Log4MQL.mqh](Include/Roffild/Log4MQL.mqh) and [Log4MQL_tofile.mqh](Include/Roffild/Log4MQL_tofile.mqh) + [module](Include/Roffild/LogMX) for [LogMX](http://www.logmx.com/)
  * [OrderData.mqh](Include/Roffild/OrderData.mqh) - data dump for research
  * [OrderSql.mqh](Include/Roffild/OrderSql.mqh)
  * [Serialization.mqh](Include/Roffild/Serialization.mqh)
  * [SqlFile.mqh](Include/Roffild/SqlFile.mqh)
  * [Statistic.mqh](Include/Roffild/Statistic.mqh)
  * [TesterSql.mqh](Include/Roffild/TesterSql.mqh) - optimization results in SQL and CSV formats
  * [ToIndicator.mqh](Include/Roffild/ToIndicator.mqh) - displaying data from an expert using indicators
  * [UnitTest.mqh](Include/Roffild/UnitTest.mqh)
  * [RoffildJava/](Include/Roffild/RoffildJava/)
    * [AmazonUtils](Include/Roffild/RoffildJava/AmazonUtils/)
    * [RoffildLibrary](Include/Roffild/RoffildJava/RoffildLibrary/)
    * [Spark](Include/Roffild/RoffildJava/Spark/) - reading from MLPDataFile
    * [aws_ubuntu_user_data.sh](Include/Roffild/RoffildJava/AmazonUtils/build/resources/main/aws_ubuntu_user_data.sh) - working script for raising test agents on Ubuntu 14 in AWS
* Indicators/Roffild/
  * [ToIndicator.mqh](Indicators/Roffild/ToIndicator.mqh)
  * [ToIndicator.mq5](Indicators/Roffild/ToIndicator.mq5)
  * [ToIndicator_window.mq5](Indicators/Roffild/ToIndicator_window.mq5)
* Scripts/Roffild/
  * [MLPDataFileSparkTest](Scripts/Roffild/MLPDataFileSparkTest) - example project for Spark and MLPDataFile test
  * [UnitTests](Scripts/Roffild/UnitTests)

## Installation

(Optionally)

``` mklink /j link where ``` - does not require administrator rights.

It makes sense to move the %APPDATA%\MetaQuotes folder to the root of the partition or to a larger partition.
Windows has a limit of 255 characters to the file path. The full path to the MQL5 folder I have is 88 characters.
When testing, the terminal copies history by the number of local agents that increases the size of this folder by several gigabytes.
1. Move the %APPDATA%\MetaQuotes to D:\MQLProjects
2. ``` mklink /j %APPDATA%\MetaQuotes D:\MQLProjects ```
3. ``` mklink /j D:\MQLProjects\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\ D:\MQLProjects\MQL5 ```

(Important)

Run the create_links.bat from the MQL5\MyProjects\RoffildLibrary folder after cloning the project.

## Code style

[Google Java Style](https://google.github.io/styleguide/javaguide.html)

Tab = 3 spaces

Column limit = 110

## License

[Apache License 2.0](LICENSE)
