# Библиотека Roffild'a

Docs: [MQL5](https://roffild.com/mql5/) [Java](https://roffild.com/java/)

* Experts/Roffild/
  * [AmazonUtils](Experts/Roffild/AmazonUtils) - можно использовать как пример разработки проекта на Java
  * [Alglib_MultilayerPerceptron.mq5](Experts/Roffild/Alglib_MultilayerPerceptron.mq5)
  * [Alglib_RandomForest.mq5](Experts/Roffild/Alglib_RandomForest.mq5)
  * [Examples/](Experts/Roffild/Examples/)
    * [ToIndicator_Example.mq5](Experts/Roffild/Examples/ToIndicator_Example.mq5)
* Include/Roffild/
  * [MLPDataFile.mqh](Include/Roffild/MLPDataFile.mqh) - формат данных для Alglib_MultilayerPerceptron и Alglib_RandomForest
  * [ArrayList_macros.mqh](Include/Roffild/ArrayList_macros.mqh) - этот вариант еще используется из-за плохой поддержки шаблонов редактором кода
  * [ArrayList.mqh](Include/Roffild/ArrayList.mqh)
  * [ArrayListClass.mqh](Include/Roffild/ArrayListClass.mqh)
  * [CsvFile.mqh](Include/Roffild/CsvFile.mqh)
  * [ForestSerializer.mqh](Include/Roffild/ForestSerializer.mqh)
  * [Log4MQL.mqh](Include/Roffild/Log4MQL.mqh) и [Log4MQL_tofile.mqh](Include/Roffild/Log4MQL_tofile.mqh) + [модуль](Include/Roffild/LogMX) для [LogMX](http://www.logmx.com/)
  * [OrderData.mqh](Include/Roffild/OrderData.mqh) - дампер данных для исследований
  * [OrderSql.mqh](Include/Roffild/OrderSql.mqh)
  * [Serialization.mqh](Include/Roffild/Serialization.mqh)
  * [SqlFile.mqh](Include/Roffild/SqlFile.mqh)
  * [Statistic.mqh](Include/Roffild/Statistic.mqh)
  * [TesterSql.mqh](Include/Roffild/TesterSql.mqh) - результаты оптимизации в форматах SQL и CSV
  * [ToIndicator.mqh](Include/Roffild/ToIndicator.mqh) - отображение данных из эксперта с помощью индикаторов
  * [UnitTest.mqh](Include/Roffild/UnitTest.mqh)
  * [RoffildJava/](Include/Roffild/RoffildJava/)
    * [AmazonUtils](Include/Roffild/RoffildJava/AmazonUtils/)
    * [RoffildLibrary](Include/Roffild/RoffildJava/RoffildLibrary/)
    * [Spark](Include/Roffild/RoffildJava/Spark/) - чтение из MLPDataFile
    * [aws_ubuntu_user_data.sh](Include/Roffild/RoffildJava/AmazonUtils/build/resources/main/aws_ubuntu_user_data.sh) - рабочий скрипт для поднятия агентов тестирования на Ubuntu 14 в AWS
* Indicators/Roffild/
  * [ToIndicator.mqh](Indicators/Roffild/ToIndicator.mqh)
  * [ToIndicator.mq5](Indicators/Roffild/ToIndicator.mq5)
  * [ToIndicator_window.mq5](Indicators/Roffild/ToIndicator_window.mq5)
* Scripts/Roffild/
  * [MLPDataFileSparkTest](Scripts/Roffild/MLPDataFileSparkTest) - пример проекта для Spark и тест MLPDataFile
  * [UnitTests](Scripts/Roffild/UnitTests)

## Установка

(Необязательно)

``` mklink /j ссылка куда ``` - не требует прав администратора.

Имеет смысл вынести папку %APPDATA%\MetaQuotes в корень раздела или на раздел большего размера.
Windows имеет ограничения на 255 символов пути к файлу. Полный путь к папке MQL5 у меня состоит из 88 символов.
При тестировании терминал копирует историю по количеству локальных агентов, что увеличивает размер этой папки на несколько гигабайт.
1. Переместить папку %APPDATA%\MetaQuotes в D:\MQLProjects
2. ``` mklink /j %APPDATA%\MetaQuotes D:\MQLProjects ```
3. ``` mklink /j D:\MQLProjects\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\ D:\MQLProjects\MQL5 ```

(Важно)

Запустить create_links.bat из папки MQL5\MyProjects\RoffildLibrary после клонирования проекта.

## Code style

[Google Java Style](https://google.github.io/styleguide/javaguide.html)

Tab = 3 spaces

Column limit = 110

## License

[Apache License 2.0](LICENSE)
