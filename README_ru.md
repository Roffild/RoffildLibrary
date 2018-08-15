# Библиотека Roffild'a

Я известен сообществу программистов на MQL5 под ником Roffild и это моя библиотека с открытым кодом для MQL5. Попытка реализовать возможности на MQL5, которые уже давно стали стандартом для популярных языков программирования. В каждом файле реализована одна идея. Библиотека пополняется по мере необходимости в новых возможностях.

Мало кто пытался выложить проект в Github. Единого стандарта нет. MetaQuotes не учитывают использование системы контроля версий при создании проекта. Почему-то программисты из MetaQuotes считают, что проект должен быть одного типа. Для мелких проектов, которые публикуются в CodeBase на сайте MQL5.com, такое разделение обосновано. Для средних и крупных проектов невозможно выбрать один тип проекта.

Я экспериментировал с разной структурой построения проекта. Для использования Git пришлось вынести файлы за пределы стандартной структуры папок, принятой в MetaQuotes. Создать ссылку на промежуточную папку (в этой библиотеке папка "Roffild") - лучший вариант.

MetaEditor может сохранять код в UTF-16, но кодировка UTF-8 с BOM тоже поддерживается. Для конвертации файла с исходным кодом нужно использовать сторонний редактор (рекомендую [Notepad++](https://notepad-plus-plus.org/)).

Библиотеку можно разделить на интересы:
* обычные задачи (ArrayList, Log4MQL, ToIndicator и т.д.);
* эксперименты с AlgLib в машинном обучении;
* использование Apache Spark с Amazon Web Services (EC2 и EMR), когда возможностей AlgLib перестало хватать.

MQL5 является частью торговой платформы MetaTrader 5 (MT5) для Forex, CFD и Futures. До сих пор используется версия MetaTrader 4 (MT4) с MQL4, но после последних обновлений совместима с синтаксисом MQL5. Официально версия MetaTrader 4 (MT4) уже не поддерживается, но для совместимости можно использовать ``` #property strict ``` в начале файла.

### Документация
[MQL5](https://roffild.com/mql5/)<br/>
[Java](https://roffild.com/java/)

### Ссылки
[Roffild.com](https://roffild.com/ru/)<br/>
[Github](https://github.com/Roffild/RoffildLibrary)<br/>
[GitLab](https://gitlab.com/Roffild/RoffildLibrary)<br/>
[BitBucket](https://bitbucket.org/Roffild/roffildlibrary/)<br/>
[MQL5.com: topic for discussion in English](https://www.mql5.com/en/forum/247134)<br/>
[MQL5.com: тема для обсуждения на Русском](https://www.mql5.com/ru/forum/245373)

-----------------
* [Experts/Roffild/](Experts/Roffild/)
  * [AmazonUtils](Experts/Roffild/AmazonUtils) - Можно использовать как пример разработки проекта на Java.
  * [Alglib_MultilayerPerceptron.mq5](Experts/Roffild/Alglib_MultilayerPerceptron.mq5)
  * [Alglib_RandomForest.mq5](Experts/Roffild/Alglib_RandomForest.mq5)
  * [Examples/](Experts/Roffild/Examples/)
    * [ToIndicator_Example.mq5](Experts/Roffild/Examples/ToIndicator_Example.mq5)
* [Include/Roffild/](Include/Roffild/)
  * [MLPDataFile.mqh](Include/Roffild/MLPDataFile.mqh) - Формат данных для Alglib_MultilayerPerceptron и Alglib_RandomForest. MLPDataFile = CSV в бинарном формате.
  * [ArrayList_macros.mqh](Include/Roffild/ArrayList_macros.mqh) - Этот вариант еще используется из-за плохой поддержки шаблонов редактором кода.
  * [ArrayList.mqh](Include/Roffild/ArrayList.mqh) - ArrayList из Java.
  * [ArrayListClass.mqh](Include/Roffild/ArrayListClass.mqh) - ArrayList из Java только для Класса.
  * [ForestSerializer.mqh](Include/Roffild/ForestSerializer.mqh) - Сохранение и загрузка данных для класса CDecisionForest (Alglib).
  * [Log4MQL.mqh](Include/Roffild/Log4MQL.mqh) и [Log4MQL_tofile.mqh](Include/Roffild/Log4MQL_tofile.mqh) + [модуль](Include/Roffild/LogMX) ([скачать](https://roffild.com/Log4MQLParser.zip)) для [LogMX](http://www.logmx.com/) - Logger for MQL5 (Log4MQL).
  * [OrderData.mqh](Include/Roffild/OrderData.mqh) - Симуляция ордеров с прикреплёнными данными для исследований.
    * [OrderSql.mqh](Include/Roffild/OrderSql.mqh) - Запись данных от ордеров (COrderData) в файл формата MySQL.
  * [SqlFile.mqh](Include/Roffild/SqlFile.mqh) - Запись данных в файл формата MySQL.
    * [CsvFile.mqh](Include/Roffild/CsvFile.mqh) - Запись данных в файл формата CSV.
  * [Statistic.mqh](Include/Roffild/Statistic.mqh) - Подсчёт данных и распечатка накопленной информации.
  * [TesterSql.mqh](Include/Roffild/TesterSql.mqh) - Запись результатов оптимизации в файлы SQL и CSV.
  * [ToIndicator.mqh](Include/Roffild/ToIndicator.mqh) - Отображение данных из Эксперта или Скрипта с помощью индикаторов.
  * [UnitTest.mqh](Include/Roffild/UnitTest.mqh) - Базовый класс для UnitTest.
  * [Serialization.mqh](Include/Roffild/Serialization.mqh)
  * [RoffildJava/](Include/Roffild/RoffildJava/)
    * [AmazonUtils](Include/Roffild/RoffildJava/AmazonUtils/)
    * [RoffildLibrary](Include/Roffild/RoffildJava/RoffildLibrary/)
    * [Spark](Include/Roffild/RoffildJava/Spark/) - Чтение из MLPDataFile.
    * [aws_ubuntu_user_data.sh](Include/Roffild/RoffildJava/AmazonUtils/src/main/resources/aws_ubuntu_user_data.sh) - Рабочий скрипт для поднятия агентов тестирования на Ubuntu в AWS. [Инструкция здесь.](https://roffild.com/ru/agents.html)
* [Indicators/Roffild/](Indicators/Roffild/)
  * [ToIndicator.mqh](Indicators/Roffild/ToIndicator.mqh)
  * [ToIndicator.mq5](Indicators/Roffild/ToIndicator.mq5)
  * [ToIndicator_window.mq5](Indicators/Roffild/ToIndicator_window.mq5)
* [Scripts/Roffild/](Scripts/Roffild/)
  * [MLPDataFileSparkTest](Scripts/Roffild/MLPDataFileSparkTest) - Пример проекта для Spark и тест MLPDataFile.
  * [UnitTests](Scripts/Roffild/UnitTests)

## Установка

(Необязательно)

``` mklink /j ссылка куда ``` - не требует прав администратора.

Имеет смысл вынести папку ``` %APPDATA%\MetaQuotes ``` в корень раздела или на раздел большего размера.
Windows имеет ограничения на 255 символов пути к файлу. Полный путь к папке MQL5 у меня состоит из 88 символов.
При тестировании терминал копирует историю по количеству локальных агентов, что увеличивает размер этой папки на несколько гигабайт.
1. Переместить папку ``` %APPDATA%\MetaQuotes ``` в ``` D:\MQLProjects ```
2. ``` mklink /j %APPDATA%\MetaQuotes D:\MQLProjects ```
3. ``` mklink /j D:\MQLProjects\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\ D:\MQLProjects\MQL5 ```

(Важно)

Запустить ``` create_links.bat ``` из папки ``` MQL5\MyProjects\RoffildLibrary ``` после клонирования проекта.

## Code style

[Google Java Style](https://google.github.io/styleguide/javaguide.html)

Tab = 3 spaces

Column limit = 110

## License

[Apache License 2.0](LICENSE)
