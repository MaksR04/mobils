import 'package:flutter/material.dart'; // Импорт библиотеки Flutter для создания пользовательского интерфейса.
import 'package:intl/intl.dart'; // Импорт библиотеки intl для работы с форматированием дат.
import 'package:intl/date_symbol_data_local.dart'; // Импорт локализации для работы с датами.
import 'package:flutter_localizations/flutter_localizations.dart'; // Импорт локализаций для приложения.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Инициализация привязки виджетов перед запуском приложения.
  await initializeDateFormatting('ru', null); // Установка формата дат для русского языка.
  runApp(CalendarApp()); // Запуск приложения с использованием класса CalendarApp.
}

class CalendarApp extends StatelessWidget { // Главный класс приложения, описывает интерфейс.
  @override
  Widget build(BuildContext context) { // Метод сборки виджетов.
    return MaterialApp(
      title: 'Календарь', // Название приложения.
      theme: ThemeData( // Настройки темы приложения.
        primarySwatch: Colors.blue, // Основной цвет темы.
        visualDensity: VisualDensity.adaptivePlatformDensity, // Адаптация интерфейса под платформу.
        scaffoldBackgroundColor: Color(0xFFF0F4F8), // Цвет фона приложения.
        textTheme: TextTheme( // Настройки текста.
          bodyLarge: TextStyle(color: Colors.black87), // Цвет основного текста.
          bodyMedium: TextStyle(color: Colors.black54), // Цвет текста средней важности.
          headlineMedium: TextStyle( // Настройки для заголовков.
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // Настройки кнопок ElevatedButton.
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // Цвет фона кнопок.
            foregroundColor: Colors.white, // Цвет текста кнопок.
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30), // Внутренние отступы кнопок.
            shape: RoundedRectangleBorder( // Скругленные края кнопок.
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: AppBarTheme( // Настройки панели приложения.
          backgroundColor: Colors.blueAccent, // Цвет фона панели.
          elevation: 0, // Убираем тень панели.
          titleTextStyle: TextStyle( // Стиль текста заголовка панели.
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      localizationsDelegates: [ // Делегаты для локализации.
        GlobalMaterialLocalizations.delegate, // Локализация компонентов Material.
        GlobalWidgetsLocalizations.delegate, // Локализация стандартных виджетов.
        GlobalCupertinoLocalizations.delegate, // Локализация компонентов Cupertino.
      ],
      supportedLocales: [ // Поддерживаемые языки.
        const Locale('ru', 'RU'), // Русская локализация.
        const Locale('en', 'US'), // Английская локализация.
      ],
      home: CalendarPage(), // Устанавливаем домашнюю страницу приложения.
    );
  }
}

class CalendarPage extends StatefulWidget { // Виджет с состоянием для главной страницы.
  @override
  _CalendarPageState createState() => _CalendarPageState(); // Создаем состояние.
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now(); // Выбранная дата, по умолчанию текущая.
  late PageController _pageController; // Контроллер для управления страницами.
  int monthsSince1900 = 0; // Количество месяцев с 1900 года.

  @override
  void initState() {
    super.initState();
    monthsSince1900 = (selectedDate.year - 1900) * 12 + selectedDate.month - 1; // Вычисляем номер текущего месяца.
    _pageController = PageController(initialPage: monthsSince1900); // Инициализируем контроллер страницы.
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat('LLLL yyyy', 'ru').format(selectedDate); // Форматируем текущую дату в "Месяц Год".
    return Scaffold( // Обертка для стандартной структуры экрана.
      appBar: AppBar(
        title: Text('Календарь',
          style: TextStyle(fontWeight: FontWeight.bold),
        ), // Заголовок на панели приложения.
      ),
      body: Column( // Основной контент организован в виде столбца.
        children: [
          GestureDetector( // Виджет, реагирующий на нажатие.
            onTap: _selectMonthYear, // Метод для выбора месяца и года.
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Отступ вокруг текста.
              child: Text(
                monthYear[0].toUpperCase() + monthYear.substring(1), // Первый символ заглавный.
                style: Theme.of(context).textTheme.headlineMedium, // Стиль текста из темы.
              ),
            ),
          ),
          Row( // Строка с метками дней недели.
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Равномерное распределение по строке.
            children: _generateWeekdayLabels(), // Генерация меток дней недели.
          ),
          Expanded( // Растягивает содержимое по вертикали.
            child: PageView.builder( // Прокручиваемый виджет страниц.
              controller: _pageController, // Устанавливаем контроллер.
              onPageChanged: (index) { // Обработчик изменения страницы.
                setState(() {
                  selectedDate = DateTime(1900 + (index ~/ 12), (index % 12) + 1); // Обновляем выбранную дату.
                });
              },
              itemBuilder: (context, index) { // Генерация содержимого для каждой страницы.
                DateTime date = DateTime(1900 + (index ~/ 12), (index % 12) + 1); // Расчет месяца и года.
                return _buildMonthView(date); // Построение вида месяца.
              },
              itemCount: 2400, // Ограничение на 100 лет назад и вперед.
            ),
          ),
          if (selectedDate.month != DateTime.now().month || selectedDate.year != DateTime.now().year) // Кнопка для перехода на текущий месяц.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _goToCurrentMonth, // Метод для перехода.
                child: Text('Текущий месяц'),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _generateWeekdayLabels() {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days
        .map((day) => Expanded(
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    ))
        .toList(); // Преобразуем список названий дней в список виджетов
  }

  Widget _buildMonthView(DateTime date) {
    List<Widget> daysOfMonth = _generateDaysOfMonth(date); // Генерация виджетов для всех дней месяца

    return GridView.builder(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8), // Отступы вокруг сетки
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 колонок (по количеству дней в неделе)
        crossAxisSpacing: 8, // Расстояние между колонками
        mainAxisSpacing: 8, // Расстояние между строками
      ),
      itemCount: daysOfMonth.length, // Общее количество виджетов
      itemBuilder: (context, index) {
        return daysOfMonth[index]; // Возвращаем виджет для каждого дня
      },
    );
  }

  List<Widget> _generateDaysOfMonth(DateTime date) {
    int daysInMonth = DateTime(date.year, date.month + 1, 0).day; // Количество дней в текущем месяце
    int firstDayOfWeek = _calculateFirstDayOfWeek(date.year, date.month); // День недели первого числа

    // Корректируем первый день так, чтобы он соответствовал понедельнику
    int shiftToMonday = (firstDayOfWeek == DateTime.sunday) ? 6 : firstDayOfWeek - 1;

    List<Widget> days = []; // Список виджетов для дней

    // Добавляем дни предыдущего месяца
    if (shiftToMonday > 0) {
      DateTime previousMonth = DateTime(date.year, date.month - 1); // Дата предыдущего месяца
      int daysInPreviousMonth = DateTime(previousMonth.year, previousMonth.month + 1, 0).day;

      for (int i = daysInPreviousMonth - shiftToMonday + 1; i <= daysInPreviousMonth; i++) {
        days.add(
          Container(
            alignment: Alignment.center,
            child: Text(
              '$i', // Номер дня
              style: TextStyle(
                color: Colors.black45, // Бледный цвет текста для дней предыдущего месяца
              ),
            ),
          ),
        );
      }
    }

    // Генерируем дни текущего месяца
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(date.year, date.month, day); // Текущая дата

      // Определяем выходные (суббота и воскресенье)
      bool isWeekend = currentDay.weekday == DateTime.saturday || currentDay.weekday == DateTime.sunday;

      // Устанавливаем цвет фона для выходных
      Color? backgroundColor;
      if (isWeekend) {
        backgroundColor = Colors.red[600]; // Красный фон для выходных
      }

      days.add(
        GestureDetector(
          onTap: () => _onDaySelected(currentDay), // Обработчик выбора дня
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isCurrentDay(currentDay)
                  ? Colors.blueAccent // Синий фон для текущего дня
                  : backgroundColor, // Красный фон для выходных
              borderRadius: BorderRadius.circular(8), // Скругленные углы
              boxShadow: [
                if (_isCurrentDay(currentDay))
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3), // Тень для текущего дня
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Text(
              '$day', // Отображение номера дня
              style: TextStyle(
                fontWeight: FontWeight.bold, // Жирный текст для дней текущего месяца
                fontSize: 18, // Увеличенный размер текста для чисел текущего месяца
                color: _isCurrentDay(currentDay)
                    ? Colors.white // Белый текст для текущего дня
                    : (isWeekend ? Colors.white : Colors.black87), // Цвет текста для выходных и будней
              ),
            ),
          ),
        ),
      );
    }

    // Добавляем дни следующего месяца
    int remainingDays = (7 - days.length % 7) % 7; // Вычисляем оставшиеся дни для заполнения
    List<Widget> nextMonthDays = [];
    for (int i = 1; i <= remainingDays; i++) {
      nextMonthDays.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            '$i', // Номер дня
            style: TextStyle(
              color: Colors.black45, // Бледный цвет текста для дней следующего месяца
            ),
          ),
        ),
      );
    }

    // Если неделя состоит полностью из дней следующего месяца, не добавляем её
    if (nextMonthDays.isNotEmpty && days.length % 7 != 0) {
      days.addAll(nextMonthDays);
    }

    return days; // Итоговый список виджетов
  }

  int _calculateFirstDayOfWeek(int year, int month) {
    // Получаем первый день месяца
    DateTime firstDay = DateTime(year, month, 1);
    // Возвращаем день недели первого числа месяца (понедельник = 1, воскресенье = 7)
    return firstDay.weekday;
  }

  bool _isCurrentDay(DateTime day) {
    // Проверяем, совпадает ли переданная дата с текущим днем
    return day.day == DateTime.now().day &&
        day.month == DateTime.now().month &&
        day.year == DateTime.now().year;
  }

  void _onDaySelected(DateTime date) {
    // Обновляем состояние при выборе дня пользователем
    setState(() {
      selectedDate = date; // Устанавливаем выбранную дату
    });
  }

  void _goToCurrentMonth() {
    // Возвращает пользователя на текущий месяц
    setState(() {
      selectedDate = DateTime.now(); // Устанавливаем текущую дату
      monthsSince1900 = (selectedDate.year - 1900) * 12 + selectedDate.month - 1;
      // Переходим на страницу с текущим месяцем
      _pageController.jumpToPage(monthsSince1900);
    });
  }

  Future<void> _selectMonthYear() async {
    // Открывает диалоговое окно для выбора месяца и года
    int selectedMonth = selectedDate.month; // Текущий выбранный месяц
    int selectedYear = selectedDate.year; // Текущий выбранный год

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Закругленные края окна
          ),
          child: Container(
            padding: EdgeInsets.all(16), // Внутренние отступы
            height: 350, // Высота диалогового окна
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Выберите месяц и год', // Заголовок диалогового окна
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16), // Отступ между элементами
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, setDialogState) {
                            // Прокрутка месяцев с помощью ListWheelScrollView
                            return ListWheelScrollView.useDelegate(
                              controller: FixedExtentScrollController(
                                initialItem: selectedMonth - 1, // Текущий выбранный месяц
                              ),
                              itemExtent: 40, // Высота одного элемента
                              physics: FixedExtentScrollPhysics(), // Физика прокрутки
                              onSelectedItemChanged: (index) {
                                setDialogState(() {
                                  selectedMonth = index + 1; // Обновляем месяц
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index > 11) return null; // Диапазон месяцев (0-11)
                                  bool isSelected = index + 1 == selectedMonth; // Проверка выбранности
                                  return Center(
                                    child: Text(
                                      DateFormat.MMMM('ru').format(DateTime(0, index + 1)), // Название месяца
                                      style: TextStyle(
                                        fontSize: isSelected ? 18 : 16, // Размер шрифта для выбранного месяца
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Жирный текст для выбранного месяца
                                        color: isSelected ? Colors.black : Colors.black54, // Цвет текста
                                      ),
                                    ),
                                  );
                                },
                                childCount: 12, // Всего 12 месяцев
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, setDialogState) {
                            // Прокрутка лет с помощью ListWheelScrollView
                            return ListWheelScrollView.useDelegate(
                              controller: FixedExtentScrollController(
                                initialItem: selectedYear - 1900, // Текущий выбранный год
                              ),
                              itemExtent: 40, // Высота одного элемента
                              physics: FixedExtentScrollPhysics(), // Физика прокрутки
                              onSelectedItemChanged: (index) {
                                setDialogState(() {
                                  selectedYear = 1900 + index; // Обновляем год
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0) return null; // Диапазон годов начинается с 1900
                                  bool isSelected = 1900 + index == selectedYear; // Проверка выбранности
                                  return Center(
                                    child: Text(
                                      '${1900 + index}', // Отображаем выбранный год
                                      style: TextStyle(
                                        fontSize: isSelected ? 18 : 16, // Размер шрифта для выбранного года
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Жирный текст для выбранного года
                                        color: isSelected ? Colors.black : Colors.black54, // Цвет текста
                                      ),
                                    ),
                                  );
                                },
                                childCount: 201, // 201 год для диапазона 1900-2100
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16), // Отступ перед кнопкой
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Устанавливаем выбранные месяц и год
                      selectedDate = DateTime(selectedYear, selectedMonth);
                      monthsSince1900 = (selectedDate.year - 1900) * 12 + selectedDate.month - 1;
                      // Переходим на соответствующую страницу
                      _pageController.jumpToPage(monthsSince1900);
                    });
                    Navigator.pop(context); // Закрываем диалог
                  },
                  child: Text('Выбрать'), // Текст кнопки
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}