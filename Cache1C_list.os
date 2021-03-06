#Использовать parserV8i

Функция КаталогиПользователейУстройства()
	
	Результат = Новый Массив;

	КаталогПользователей = ПолучитьПеременнуюСреды("USERPROFILE");
	ПозицияРазделителя = СтрНайти(КаталогПользователей, "\", НаправлениеПоиска.СКонца);
	Если ПозицияРазделителя > 0 Тогда
		КаталогПользователей = Лев(КаталогПользователей, ПозицияРазделителя - 1);
	КонецЕсли;

	Для Каждого ТекущийКаталог Из НайтиФайлы(КаталогПользователей, "*.*", Ложь) Цикл			
		Если ТекущийКаталог.ЭтоФайл() Тогда
			Продолжить;
		КонецЕсли;
		Результат.Добавить(ТекущийКаталог.ПолноеИмя);
	КонецЦикла;

	Возврат Результат;

КонецФункции

Функция ПрочитатьСписокБаз(ПутьКСпискуБаз)
	
	Парсер = Новый ПарсерСпискаБаз;
	Парсер.УстановитьФайл(ПутьКСпискуБаз);
	Возврат Парсер.ПолучитьСписокБаз();

КонецФункции

Функция РазмерКаталога(ПутьККаталогу)

	Размер = 0;
	МассивФайлов = НайтиФайлы(ПутьККаталогу, "*.*", Истина);
	
	Для Каждого Файл Из МассивФайлов Цикл
		Если НЕ Файл.ЭтоФайл() Тогда
			Продолжить;
		КонецЕсли;
		Размер = Размер + Файл.Размер();
	КонецЦикла;

	Возврат Размер;

КонецФункции

Функция ИнициализироватьТабКаталогиКэша()

	ТабКаталогиКэша = Новый ТаблицаЗначений();
	ТабКаталогиКэша.Колонки.Добавить("Имя");
	ТабКаталогиКэша.Колонки.Добавить("ID");
	ТабКаталогиКэша.Колонки.Добавить("РазмерКэша");
	ТабКаталогиКэша.Колонки.Добавить("РазмерМб");
	ТабКаталогиКэша.Колонки.Добавить("ПутьКБазе");
	ТабКаталогиКэша.Колонки.Добавить("ПутьККэшу");

	Возврат ТабКаталогиКэша;

КонецФункции

Функция КаталогиКэшаПользователя(КаталогПользователя)

	Результат = Новый Массив;
	
	ВозможныеКаталоги = Новый Массив;
	ВозможныеКаталоги.Добавить(КаталогПользователя + "\AppData\Local\1C\1cv8");
	ВозможныеКаталоги.Добавить(КаталогПользователя + "\AppData\Roaming\1C\1cv8");

	// проверка существования и переопределение каталогов при наличии файла location.cfg	
	Для каждого Каталог Из ВозможныеКаталоги Цикл
	
		Если НЕ Новый Файл(Каталог).Существует() Тогда
			Продолжить;
		КонецЕсли;

		ФайлРасположенияКэша = Новый Файл(Каталог + "\location.cfg");

		Если НЕ ФайлРасположенияКэша.Существует() Тогда
			Результат.Добавить(Каталог);
			Продолжить;
		КонецЕсли;
			
		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.Прочитать(ФайлРасположенияКэша.ПолноеИмя);
		
		Для сч = 1 По ТекстовыйДокумент.КоличествоСтрок() Цикл
			
			Строка = ТекстовыйДокумент.ПолучитьСтроку(сч);
			Если Найти(НРег(Строка), "location") = 0 Тогда
				Продолжить;
			КонецЕсли;
			
			Подстроки = СтрРазделить(Строка, "=");
			Если Подстроки.Количество() = 2 И ЗначениеЗаполнено(Подстроки[1]) Тогда
				Каталог = СтрЗаменить(СокрЛП(Подстроки[1]), "/", "\");
			КонецЕсли;

			Прервать;

		КонецЦикла;

		Результат.Добавить(Каталог);
	
	КонецЦикла;

	Возврат Результат;

КонецФункции // КаталогиКэшаПользователя()

Процедура ЗаполнитьТабКаталоговКэша(ТабКаталогиКэша, КаталогПользователя)

	КаталогиКэша = КаталогиКэшаПользователя(КаталогПользователя);
	Если КаталогиКэша.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	СписокБаз = Новый Массив;
	ФайлСпискаБаз = Новый Файл(КаталогПользователя + "\AppData\Roaming\1C\1CEStart\ibases.v8i");
	// проверяем не только наличие файла, но и размер, т.к. на пустой файл будет выдана ошибка
	Если ФайлСпискаБаз.Существует() И ФайлСпискаБаз.Размер() > 4 Тогда
		СписокБаз = ПрочитатьСписокБаз(ФайлСпискаБаз.ПолноеИмя);
	КонецЕсли;
	
	ИдентификаторыЗарегистрированныхБаз = Новый Массив;

	Для каждого КлючИЗначение Из СписокБаз Цикл

		Если Не КлючИЗначение.Значение.Свойство("Connect") Тогда
			Продолжить; // это группа
		КонецЕсли;

		ИдентификаторыЗарегистрированныхБаз.Добавить(КлючИЗначение.Значение.ID);

		Для каждого КаталогКэша Из КаталогиКэша Цикл
			
			ПутьККэшуБазы = КаталогКэша + "\" + КлючИЗначение.Значение.ID;
			Если НЕ Новый Файл(ПутьККэшуБазы).Существует() Тогда
				Продолжить;
			КонецЕсли;
		
			Строка = ТабКаталогиКэша.Добавить();
			Строка.Имя        = КлючИЗначение.Значение.Name;
			Строка.ID         = КлючИЗначение.Значение.ID;
			Строка.ПутьКБазе  = КлючИЗначение.Значение.Connect.String;
			Строка.ПутьККэшу  = ПутьККэшуБазы;
			Строка.РазмерКэша = РазмерКаталога(ПутьККэшуБазы);
			Строка.РазмерМб   = Окр(Строка.РазмерКэша / Pow(2, 20));
		
		КонецЦикла;

	КонецЦикла;

	ДлинаИд = 36;
	// дополняем таблицу каталогами незарегистированных баз
	Для каждого КаталогКэша Из КаталогиКэша Цикл
		Для Каждого ТекущийКаталог Из НайтиФайлы(КаталогКэша, "*.*", Ложь) Цикл
			
			Если ТекущийКаталог.ЭтоФайл() ИЛИ СтрДлина(ТекущийКаталог.Имя) <> ДлинаИд Тогда
				Продолжить;
			КонецЕсли;

			Если ИдентификаторыЗарегистрированныхБаз.Найти(ТекущийКаталог.Имя) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;

			Строка = ТабКаталогиКэша.Добавить();
			Строка.Имя        = "<не зарегистрирована>";
			Строка.ID         = ТекущийКаталог.Имя;
			Строка.ПутьККэшу  = ТекущийКаталог.ПолноеИмя;
			Строка.РазмерКэша = РазмерКаталога(ТекущийКаталог.ПолноеИмя);
			Строка.РазмерМб   = Окр(Строка.РазмерКэша/Pow(2, 20));

		КонецЦикла;
	КонецЦикла;

КонецПроцедуры // ЗаполнитьТабКаталоговКэша()

Процедура УдалитьКэшНезарегистрированныхБаз(ТабКаталогиКэша)
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("Имя", "<не зарегистрирована>");

	Для каждого Строка Из ТабКаталогиКэша.НайтиСтроки(ПараметрыОтбора) Цикл
		УдалитьФайлы(Строка.ПутьККэшу);
	КонецЦикла;
	
КонецПроцедуры

// Сохраням таблицу значений в XML файл
// Таблица - сохраняемая таблица
Функция ПреобразоватьТаблицуВСтрокуXML(Таблица)
	
	Запись = Новый ЗаписьXML();
	Запись.УстановитьСтроку();
	Запись.ЗаписатьОбъявлениеXML();
	Запись.ЗаписатьНачалоЭлемента("root");

	МасКолонки = Новый Массив;
	Для Ном = 0 По Таблица.Колонки.Количество() - 1 Цикл		
		Колонка = Таблица.Колонки[Ном];
		МасКолонки.Добавить(Колонка.Имя);
	КонецЦикла;
	
	Запись.ЗаписатьНачалоЭлемента("records");

	Для Каждого СтрТаблицы Из Таблица Цикл
		Запись.ЗаписатьНачалоЭлемента("record");
		Для каждого ИмяКолонки Из МасКолонки Цикл
			Запись.ЗаписатьНачалоЭлемента(ИмяКолонки);
			Значение = Строка(СтрТаблицы[ИмяКолонки]);
			Запись.ЗаписатьСекциюCDATA(Значение);
			Запись.ЗаписатьКонецЭлемента();
		КонецЦикла;
		Запись.ЗаписатьКонецЭлемента();
	КонецЦикла;				
	
	Запись.ЗаписатьКонецЭлемента(); // records
	Запись.ЗаписатьКонецЭлемента(); // root
	
	Возврат Запись.Закрыть();
	
КонецФункции // ПреобразоватьТаблицуВСтрокуXML()

////////////////////////////////////////////////////////////
// ОСНОВНАЯ ПРОГРАММА
//

ТабКаталогиКэша = ИнициализироватьТабКаталогиКэша();
Для каждого КаталогПользователя Из КаталогиПользователейУстройства() Цикл
	ЗаполнитьТабКаталоговКэша(ТабКаталогиКэша, КаталогПользователя);
КонецЦикла;

УдалятьНезарегистрированныеБазы = Ложь;
Если УдалятьНезарегистрированныеБазы Тогда
	УдалитьКэшНезарегистрированныхБаз(ТабКаталогиКэша);
КонецЕсли;

ТабКаталогиКэша.Сортировать("РазмерКэша Убыв");

ТекстовыйДокумент = Новый ТекстовыйДокумент;
ТекстовыйДокумент.УстановитьТекст(ПреобразоватьТаблицуВСтрокуXML(ТабКаталогиКэша));
ТекстовыйДокумент.Записать("out.xml", "UTF-8");

// открытие файла в Excel
ИмяВремФайлаСкрипта = ПолучитьИмяВременногоФайла();
ПозицияТочки = СтрНайти(ИмяВремФайлаСкрипта, ".", НаправлениеПоиска.СКонца, , 1);
Если ПозицияТочки > 0 Тогда
	ИмяВремФайлаСкрипта = Лев(ИмяВремФайлаСкрипта, ПозицияТочки) + "bat";
Иначе
	ИмяВремФайлаСкрипта = ИмяВремФайлаСкрипта + ".bat";
КонецЕсли;

ТекстовыйДокумент = Новый ТекстовыйДокумент;
ТекстовыйДокумент.ДобавитьСтроку("start Excel /n out.xml");
ТекстовыйДокумент.Записать(ИмяВремФайлаСкрипта, КодировкаТекста.OEM);
ЗапуститьПриложение(ИмяВремФайлаСкрипта);
Приостановить(100);
УдалитьФайлы(ИмяВремФайлаСкрипта);