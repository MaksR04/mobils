import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Библиотека для использования иконок Font Awesome
import 'dart:convert';
import 'package:http/http.dart' as http; // HTTP-клиент для выполнения запросов
import 'package:intl/intl.dart'; // Библиотека для форматирования чисел и дат

void main() {
  runApp(const ConverterApp()); // Запуск приложения
}

// Главный класс приложения
class ConverterApp extends StatelessWidget {
  const ConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter', // Заголовок приложения
      theme: ThemeData(
        primarySwatch: Colors.teal, // Основная цветовая схема
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87), // Основной текст
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Заголовки
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500), // Подзаголовки
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Отступы кнопок
            textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white, // Цвет текста кнопок
            ),
            backgroundColor: Colors.teal, // Цвет кнопок
            foregroundColor: Colors.white, // Цвет текста для всех состояний кнопки
          ),
        ),
        cardTheme: const CardTheme(
          elevation: 4, // Тень карточек
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Внешние отступы карточек
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)), // Скругление углов
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(), // Границы текстового поля
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal), // Цвет границы при фокусе
          ),
          labelStyle: TextStyle(color: Colors.teal), // Цвет метки текстового поля
        ),
      ),
      debugShowCheckedModeBanner: false, // Убирает баннер "debug" в верхнем правом углу
      home: const HomeScreen(), // Начальный экран приложения
    );
  }
}

// Экран главного меню
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Опции главного меню
    final options = [
      {'title': 'Длина', 'icon': Icons.straighten},
      {'title': 'Вес', 'icon': FontAwesomeIcons.weightHanging},
      {'title': 'Температура', 'icon': Icons.thermostat},
      {'title': 'Площадь', 'icon': Icons.square_foot},
      {'title': 'Валюта', 'icon': FontAwesomeIcons.rubleSign},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Конвертер единиц', style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true, // Заголовок по центру
      ),
      body: ListView.builder(
        itemCount: options.length, // Количество опций в меню
        itemBuilder: (context, index) {
          final option = options[index];
          return Card(
            child: ListTile(
              leading: Icon(option['icon'] as IconData, color: Colors.teal), // Иконка опции
              title: Text(option['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium), // Название опции
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal), // Иконка перехода
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ConversionScreen(conversionType: option['title'] as String), // Переход на экран конверсии
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Экран конверсии единиц
class ConversionScreen extends StatefulWidget {
  final String conversionType; // Тип конверсии

  const ConversionScreen({super.key, required this.conversionType});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  // Карта символов единиц измерения
  Map<String, String> getUnitSymbols() {
    return {
      'Миллиметры (мм)': 'мм',
      'Сантиметры (см)': 'см',
      'Метры (м)': 'м',
      'Километры (км)': 'км',
      'Миллиграммы (мг)': 'мг',
      'Граммы (г)': 'г',
      'Килограммы (кг)': 'кг',
      'Тонны (т)': 'т',
      'Гр Цельсия (°C)': '°C',
      'Гр Фаренгейта (°F)': '°F',
      'Гр Кельвина (K)': 'K',
      'Кв сантиметры (см²)': 'см²',
      'Кв метры (м²)': 'м²',
      'Кв километры (км²)': 'км²',
      'Акры (акр)': 'акр',
      'Гектары (га)': 'га',
      'USD': '\$',
      'EUR': '€',
      'RUB': '₽',
      'CNY': '¥',
    };
  }

  // Получение символа для единицы измерения
  String getSymbolForUnit(String unit) {
    Map<String, String> unitSymbols = getUnitSymbols();
    return unitSymbols[unit] ?? unit;
  }

  // Запрос курсов валют из API
  Future<Map<String, double>> _fetchCurrencyRates(String base) async {
    const String apiKey = '4628ba29c3188b6af632c12a'; // Ключ API
    final String url = 'https://v6.exchangerate-api.com/v6/$apiKey/latest/$base'; // URL API

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['conversion_rates'] != null) {
          final conversionRates = Map<String, dynamic>.from(data['conversion_rates']);
          return conversionRates.map((key, value) => MapEntry(key, value.toDouble()));
        } else {
          throw Exception('Курсы валют отсутствуют в ответе API.');
        }
      } else {
        throw Exception('Ошибка: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении данных: $e');
    }
  }

  // Начальные значения
  TextEditingController inputController = TextEditingController();
  String result = '';
  String fromUnit = '';
  String toUnit = '';
  Map<String, double> currencyRates = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fromUnit = _getUnitsForType(widget.conversionType).first;
    toUnit = _getUnitsForType(widget.conversionType).last;
    result = 'Введите значение';

    // Исключение для валют
    if (widget.conversionType == 'Валюта') {
      _fetchCurrencyRates('USD');
    }
  }

  // Обновлкние курса
  Future<void> _updateCurrencyRates() async {
    setState(() {
      isLoading = true;  // Устанавливаем флаг загрузки в true
    });

    try {
      // Асинхронный вызов метода _fetchCurrencyRates
      currencyRates = await _fetchCurrencyRates('USD');
    } catch (e) {
      setState(() {
        result = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        isLoading = false;  // Устанавливаем флаг загрузки в false
      });
    }
  }

  // Выпадающие списки
  List<String> _getUnitsForType(String conversionType) {
    switch (conversionType) {
      case 'Вес':
        return ['Миллиграммы (мг)', 'Граммы (г)', 'Килограммы (кг)', 'Тонны (т)',];
      case 'Температура':
        return ['Гр Цельсия (°C)', 'Гр Фаренгейта (°F)', 'Гр Кельвина (K)'];
      case 'Площадь':
        return ['Кв сантиметры (см²)', 'Кв метры (м²)', 'Кв километры (км²)', 'Акры (акр)', 'Гектары (га)'];
      case 'Валюта':
        return ['USD', 'EUR', 'RUB', 'CNY'];
      case 'Длина':
        return ['Миллиметры (мм)', 'Сантиметры (см)', 'Метры (м)', 'Километры (км)'];
      default:
        return [];
    }
  }

  // Если пусто
  void convert() async {
    if (inputController.text.trim().isEmpty) {
      setState(() {
        result = 'Вы же ничего не ввели!';
      });
      return;
    }

    // Заменяем запятую на точку в вводимом значении и убираем пробелы
    String input = inputController.text.replaceAll(' ', '').replaceAll(',', '.');
    double inputValue = double.tryParse(input) ?? double.nan;

    // Температура может быть и отрицательной
    if ((inputValue.isNaN || inputValue < 0) && widget.conversionType != 'Температура') {
      setState(() {
        result = 'Ну давай покажи мне как это решается! Или просто введи положительное число';
      });
      return;
    }

    double convertedValue = 0.0;
    Map<String, String> unitSymbols = getUnitSymbols(); // Получаем символы для единиц

    switch (widget.conversionType) {
      case 'Длина':
        convertedValue = _convertLength(inputValue, fromUnit, toUnit);
        break;
      case 'Вес':
        convertedValue = _convertWeight(inputValue, fromUnit, toUnit);
        break;
      case 'Температура':
        convertedValue = _convertTemperature(inputValue, fromUnit, toUnit);
        break;
      case 'Площадь':
        convertedValue = _convertArea(inputValue, fromUnit, toUnit);
        break;
      case 'Валюта':
        convertedValue = await _convertCurrency(inputValue, fromUnit, toUnit);
        break;
      default:
        setState(() {
          result = 'Неизвестный тип конверсии!';
        });
        return;
    }

    // Используем NumberFormat для форматирования больших чисел
    final numberFormat = NumberFormat("#,##0.##########", "ru_RU");  // Для русского формата с пробелами (вместо запятой, как в англоязычных странах)

    setState(() {
      // Форматируем вводимое значение
      String formattedInputValue = numberFormat.format(inputValue);

      // Форматируем результат, всегда показываем дробную часть, если она есть
      String formattedConvertedValue = numberFormat.format(convertedValue);

      // Заменяем название единиц на их символы
      String fromSymbol = getSymbolForUnit(fromUnit); // Используем функцию для получения символа
      String toSymbol = getSymbolForUnit(toUnit); // Используем функцию для получения символа

      result = 'Результат: $formattedInputValue $fromSymbol = $formattedConvertedValue $toSymbol';
    });
  }

  // Переключение местами "Из" и "В"
  void swapUnits() {
    setState(() {
      String temp = fromUnit;
      fromUnit = toUnit;
      toUnit = temp;
    });
  }

  // Конвертирование: коэффициенты и поиск его (если не найдёт, то 1.0)
  double _convertLength(double value, String from, String to) {
    const conversionFactors = {
      'Миллиметры (мм)': 1.0,
      'Сантиметры (см)': 10.0,
      'Метры (м)': 1000.0,
      'Километры (км)': 1000000.0,
    };

    double fromFactor = conversionFactors[from] ?? 1.0;
    double toFactor = conversionFactors[to] ?? 1.0;

    return value * fromFactor / toFactor;
  }

  double _convertWeight(double value, String from, String to) {
    const conversionFactors = {
      'Миллиграммы (мг)': 1.0,
      'Граммы (г)': 1000.0,
      'Килограммы (кг)': 1000000.0,
      'Тонны (т)': 1000000000.0,
    };

    double fromFactor = conversionFactors[from] ?? 1.0;
    double toFactor = conversionFactors[to] ?? 1.0;

    return value * fromFactor / toFactor;
  }

  double _convertTemperature(double value, String from, String to) {
    if (from == to) return value;

    if (from == 'Гр Цельсия (°C)') {
      if (to == 'Гр Фаренгейта (°F)') return value * 9 / 5 + 32;
      if (to == 'Гр Кельвина (K)') return value + 273.15;
    } else if (from == 'Гр Фаренгейта (°F)') {
      if (to == 'Гр Цельсия (°C)') return (value - 32) * 5 / 9;
      if (to == 'Гр Кельвина (K)') return (value - 32) * 5 / 9 + 273.15;
    } else if (from == 'Гр Кельвина (K)') {
      if (to == 'Гр Цельсия (°C)') return value - 273.15;
      if (to == 'Гр Фаренгейта (°F)') return (value - 273.15) * 9 / 5 + 32;
    }

    return value;
  }

  double _convertArea(double value, String from, String to) {
    const conversionFactors = {
      'Кв метры (м²)': 1.0, // Базовая единица
      'Кв сантиметры (см²)': 0.0001, // 1 кв см = 0.0001 кв метра
      'Кв километры (км²)': 1_000_000.0, // 1 кв км = 1 000 000 кв метров
      'Акры (акр)': 4046.85642, // 1 акр = 4046.85642 кв метра
      'Гектары (га)': 10_000.0, // 1 гектар = 10 000 кв метров
    };

    double fromFactor = conversionFactors[from] ?? 1.0;
    double toFactor = conversionFactors[to] ?? 1.0;

    return value * fromFactor / toFactor;
  }

  Future<double> _convertCurrency(double value, String from, String to) async {
    if (from == to) {
      return value; // Если валюты совпадают, возвращаем исходное значение
    }

    try {
      // Получаем курсы валют для базовой валюты `from`
      final rates = await _fetchCurrencyRates(from);

      // Проверяем, есть ли курс для `to`
      if (rates.containsKey(to)) {
        return value * rates[to]!; // Конвертация значения
      } else {
        throw Exception('Курс валюты $to отсутствует.');
      }
    } catch (e) {
      throw Exception('Ошибка конверсии валют: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Конвертация: ${widget.conversionType}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: isLoading // Загрузка на валюте
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: inputController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Введите значение',
              ),
            ),
            const SizedBox(height: 20),
            Text(result, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: fromUnit,
                    isExpanded: true,
                    items: _getUnitsForType(widget.conversionType)
                        .map(
                          (unit) => DropdownMenuItem<String>(
                        value: unit,
                        child: Text(
                          unit,
                          overflow: TextOverflow.visible, // Адаптивность текста
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        fromUnit = value!;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.teal), // Кнопка туда-сюда
                  onPressed: () {
                    setState(() {
                      String temp = fromUnit;
                      fromUnit = toUnit;
                      toUnit = temp;
                    });
                  },
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: toUnit,
                    isExpanded: true,
                    items: _getUnitsForType(widget.conversionType)
                        .map(
                          (unit) => DropdownMenuItem<String>(
                        value: unit,
                        child: Text(
                          unit,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        toUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: convert,
              child: const Text('Конвертировать'),
            ),
            const SizedBox(height: 20),
            // Отображаем кнопку только для валют
            if (widget.conversionType == 'Валюта')
            ElevatedButton(
              onPressed: _updateCurrencyRates,
              child: const Text('Обновить курсы'),
            ),
          ],
        ),
      ),
    );
  }
}