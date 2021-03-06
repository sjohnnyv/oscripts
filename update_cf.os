#Использовать v8runner
#Использовать v8storage
#Использовать json

Перем Настройки; // настройки подключения; логины и пароли

Процедура Инициализация(Отказ)

	Парсер = Новый ПарсерJSON();
	ИмяФайлаНастроек = "update_settings.ini";
	Файл = Новый Файл(ИмяФайлаНастроек);

	Если Файл.Существует() Тогда
		
		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.Прочитать(ИмяФайлаНастроек, "UTF-8");
		СтрокаJSON = ТекстовыйДокумент.ПолучитьТекст();
		Настройки = Парсер.ПрочитатьJSON(СтрокаJSON,,,Истина);

	Иначе

		Сообщить(СтрШаблон("Файл настроек ""%1"" не существует. Создан файл с пустыми настройками."
			+ " Его необходимо заполнить", ИмяФайлаНастроек));
			
		Настройки = Новый Структура;
		Настройки.Вставить("ВерсияПлатформы", "");
		
		ПодключениеКХранилищу = Новый Структура;
		ПодключениеКХранилищу.Вставить("ПутьОсн",          "tcp://<Сервер>:<Порт>/<Путь к хранилищу осн. конф>");
		ПодключениеКХранилищу.Вставить("ПутьРасш",         "tcp://<Сервер>:<Порт>/<Путь к хранилищу расширения>");
		ПодключениеКХранилищу.Вставить("ЛогинВХранилище",  "");
		ПодключениеКХранилищу.Вставить("ПарольВХранилище", "");
		ПодключениеКХранилищу.Вставить("ИмяРасширения",    "");
		Настройки.Вставить("ПодключениеКХранилищу", ПодключениеКХранилищу);
		
		ПодключениеКБазе = Новый Структура;
		ПодключениеКБазе.Вставить("ИмяСервера", "<ИмяСервераПриложений1С>");
		ПодключениеКБазе.Вставить("ИмяБазы",    "<ИмяБазыНаСервереПриложений1С>");
		ПодключениеКБазе.Вставить("ЛогинБазы",  "");
		ПодключениеКБазе.Вставить("ПарольБазы", "");
		Настройки.Вставить("ПодключениеКБазе", ПодключениеКБазе);
		
		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.УстановитьТекст(Парсер.ЗаписатьJSON(Настройки));
		ТекстовыйДокумент.Записать(ИмяФайлаНастроек, "UTF-8");

		Отказ = Истина;

	КонецЕсли;

КонецПроцедуры // Инициализация()

Процедура ПолучитьКонфигурациюИзХранилищаИОбновитьБазу()
		
	ПутьОсн          = Настройки.ПодключениеКХранилищу.ПутьОсн;
	ПутьРасш         = Настройки.ПодключениеКХранилищу.ПутьРасш;
	ЛогинВХранилище  = Настройки.ПодключениеКХранилищу.ЛогинВХранилище;
	ПарольВХранилище = Настройки.ПодключениеКХранилищу.ПарольВХранилище;
	ИмяРасширения    = Настройки.ПодключениеКХранилищу.ИмяРасширения;
	ИмяСервера       = Настройки.ПодключениеКБазе.ИмяСервера;
	ИмяБазы          = Настройки.ПодключениеКБазе.ИмяБазы;
	ЛогинБазы        = Настройки.ПодключениеКБазе.ЛогинБазы;
	ПарольБазы       = Настройки.ПодключениеКБазе.ПарольБазы;

	СтрокаСоединения = СтрШаблон("/IBConnectionString""Srvr=%1; Ref=%2""", ИмяСервера, ИмяБазы);

	Конфигуратор = Новый УправлениеКонфигуратором();
	Если Настройки.Свойство("ВерсияПлатформы") И ЗначениеЗаполнено(Настройки.ВерсияПлатформы) Тогда
		Конфигуратор.ИспользоватьВерсиюПлатформы(Настройки.ВерсияПлатформы);
	КонецЕсли;
	Конфигуратор.УстановитьКонтекст(СтрокаСоединения, ЛогинБазы, ПарольБазы);

	ХранилищеКонфигурации = Новый МенеджерХранилищаКонфигурации();
	ХранилищеКонфигурации.УстановитьУправлениеКонфигуратором(Конфигуратор);
	ХранилищеКонфигурации.УстановитьПутьКХранилищу(ПутьОсн);
	ХранилищеКонфигурации.УстановитьПараметрыАвторизации(ЛогинВХранилище, ПарольВХранилище);
	ХранилищеКонфигурации.ОбновитьКонфигурациюНаВерсию();
	Сообщить("Основная конфигурация получена из хранилища");

	ХранилищеКонфигурации.УстановитьПутьКХранилищу(ПутьРасш);
	ХранилищеКонфигурации.УстановитьПараметрыАвторизации(ЛогинВХранилище, ПарольВХранилище);
	ХранилищеКонфигурации.УстановитьРасширениеХранилища(ИмяРасширения);
	ХранилищеКонфигурации.ОбновитьКонфигурациюНаВерсию();
	Сообщить("Расширение " + ИмяРасширения + " получено из хранилища");

	Конфигуратор.ОбновитьКонфигурациюБазыДанных( , Ложь);
	Конфигуратор.ОбновитьКонфигурациюБазыДанных( , Ложь, , ИмяРасширения);
	Сообщить("База данных обновлена");
	
КонецПроцедуры

Отказ = Ложь;
Инициализация(Отказ);
Если НЕ Отказ Тогда
	ПолучитьКонфигурациюИзХранилищаИОбновитьБазу();
КонецЕсли;
Сообщить("--Конец--");