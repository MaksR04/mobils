import 'package:flutter/material.dart'; // Библиотека для создания интерфейсов
import 'task.dart'; // Модель задачи
import 'task_detail_screen.dart'; // Экран для просмотра/редактирования задачи
import 'task_storage.dart'; // Класс для работы с локальным хранилищем
import 'package:intl/intl.dart'; // Для форматирования даты и времени
import 'package:flutter_localizations/flutter_localizations.dart'; // Для локализации приложения

// Точка входа в приложение
void main() => runApp(TodoApp());

// Главный виджет приложения
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo', // Заголовок приложения
      locale: Locale('ru', 'RU'), // Устанавливаем локаль для русского языка
      supportedLocales: [
        Locale('en', 'US'), // Английский
        Locale('ru', 'RU'), // Русский
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate, // Локализация Material-компонентов
        GlobalWidgetsLocalizations.delegate, // Локализация виджетов
        GlobalCupertinoLocalizations.delegate, // Локализация iOS-компонентов
      ],
      theme: ThemeData(
        primaryColor: Colors.teal, // Основной цвет приложения
        colorScheme: ColorScheme.light(
          primary: Colors.teal, // Основной цвет
          secondary: Colors.tealAccent, // Вторичный цвет
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 16), // Текст для тела
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Текст для заголовков
        ),
      ),
      home: TodoScreen(), // Основной экран приложения
    );
  }
}

// Экран со списком задач
class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Task> tasks = []; // Список задач
  TaskFilter _filter = TaskFilter.all; // Выбранный фильтр задач

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Загрузка задач из локального хранилища при инициализации
  }

  // Загрузка задач из локального хранилища
  Future<void> _loadTasks() async {
    tasks = await TaskStorage.loadTasks();
    setState(() {}); // Обновление состояния после загрузки
  }

  // Фильтрация задач в зависимости от выбранного фильтра
  List<Task> get filteredTasks {
    switch (_filter) {
      case TaskFilter.current:
        return tasks.where((task) => !task.isCompleted).toList(); // Только невыполненные
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList(); // Только выполненные
      default:
        return tasks; // Все задачи
    }
  }

  // Переключение состояния выполнения задачи
  void toggleTaskCompletion(int index) {
    setState(() {
      filteredTasks[index].isCompleted = !filteredTasks[index].isCompleted;
    });
    TaskStorage.saveTasks(tasks); // Сохранение изменений
  }

  // Добавление новой задачи
  void addTask(Task task) {
    setState(() {
      tasks.insert(0, task); // Добавляем в начало списка
    });
    TaskStorage.saveTasks(tasks); // Сохраняем задачи
  }

  // Редактирование существующей задачи
  void editTask(int index, Task task) {
    setState(() {
      tasks[index] = task;
    });
    TaskStorage.saveTasks(tasks); // Сохраняем задачи
  }

  // Удаление задачи
  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
    TaskStorage.saveTasks(tasks); // Сохраняем изменения
  }

  // Форматирование даты и времени
  String formatDateTime(DateTime dateTime) {
    Intl.defaultLocale = 'ru_RU';
    final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'ru_RU');
    final DateFormat timeFormat = DateFormat('HH:mm');
    final String date = dateFormat.format(dateTime);
    final String time = (dateTime.hour != 0 || dateTime.minute != 0)
        ? ' ${timeFormat.format(dateTime)}'
        : '';
    return '$date$time';
  }

  @override
  Widget build(BuildContext context) {
    final filteredTaskList = filteredTasks; // Получаем список с учетом фильтра

    return Scaffold(
      appBar: AppBar(
        title: Text('Планировщик задач'),
      ),
      body: filteredTaskList.isEmpty
          ? Center(
        child: Text(
          _filter == TaskFilter.completed
              ? 'Нет выполненных задач'
              : 'Нет запланированных задач', // Показать сообщение, если задачи отсутствуют
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: filteredTaskList.length, // Количество задач
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4, // Тень для карточки
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Закругленные углы
            ),
            color: filteredTaskList[index].isCompleted
                ? Colors.green[50] // Цвет для выполненных задач
                : Colors.white, // Цвет для невыполненных задач
            child: ListTile(
              contentPadding: EdgeInsets.all(16), // Отступы внутри карточки
              title: Text(
                filteredTaskList[index].title, // Название задачи
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: filteredTaskList[index].isCompleted
                      ? Colors.green[700] // Цвет текста выполненной задачи
                      : Colors.black87, // Цвет текста невыполненной задачи
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (filteredTaskList[index].description.isNotEmpty)
                    Text(
                      filteredTaskList[index].description, // Описание задачи
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  if (filteredTaskList[index].dueDate != null)
                    Text(
                      'Срок: ${formatDateTime(filteredTaskList[index].dueDate!)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  filteredTaskList[index].isCompleted
                      ? Icons.check_circle // Иконка выполненной задачи
                      : Icons.check_circle_outline, // Иконка невыполненной задачи
                  color: filteredTaskList[index].isCompleted
                      ? Colors.green
                      : Colors.grey,
                ),
                onPressed: () => toggleTaskCompletion(index), // Изменить статус задачи
              ),
              onTap: () async {
                final editedTask = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(
                      task: filteredTaskList[index], // Передаем задачу для редактирования
                      onDelete: deleteTask, // Удаление задачи
                    ),
                  ),
                );
                if (editedTask != null) {
                  editTask(index, editedTask); // Редактируем задачу
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add), // Кнопка добавления задачи
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskDetailScreen()),
          );
          if (newTask != null) {
            addTask(newTask); // Добавляем новую задачу
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: TaskFilter.values.indexOf(_filter), // Индекс текущего фильтра
        onTap: (index) {
          setState(() {
            _filter = TaskFilter.values[index]; // Изменяем фильтр
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Все', // Все задачи
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Текущие', // Текущие задачи
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            label: 'Выполненные', // Выполненные задачи
          ),
        ],
      ),
    );
  }
}

// Перечисление для фильтров задач
enum TaskFilter { all, current, completed }
