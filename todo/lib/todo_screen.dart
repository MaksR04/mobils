import 'package:flutter/material.dart'; // Библиотека для построения интерфейсов
import 'task.dart'; // Импорт модели задачи
import 'task_detail_screen.dart'; // Экран для редактирования и добавления задач
import 'task_storage.dart'; // Класс для работы с локальным хранилищем задач

// Точка входа в приложение
void main() {
  runApp(TodoApp());
}

// Главный виджет приложения
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo', // Название приложения
      theme: ThemeData(primarySwatch: Colors.blue), // Установка основной цветовой темы
      home: TodoScreen(), // Установка стартового экрана
    );
  }
}

// Экран списка задач
class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Task> tasks = []; // Локальный список задач

  // Метод добавления задачи
  void addTask(Task task) {
    setState(() {
      tasks.add(task); // Добавление новой задачи в список
    });
    TaskStorage.saveTasks(tasks); // Сохранение обновленного списка задач
  }

  // Метод редактирования задачи
  void editTask(int index, Task task) {
    setState(() {
      tasks[index] = task; // Обновление задачи по индексу
    });
    TaskStorage.saveTasks(tasks); // Сохранение изменений
  }

  // Метод переключения состояния выполнения задачи
  void toggleTaskCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted; // Инвертируем статус выполнения
    });
    TaskStorage.saveTasks(tasks); // Сохранение изменений
  }

  // Метод удаления задачи
  void deleteTask(Task? task) {
    if (task != null) {
      setState(() {
        tasks.remove(task); // Удаление задачи из списка
      });
      TaskStorage.saveTasks(tasks); // Сохранение изменений
    }
  }

  // Метод, вызываемый при инициализации виджета
  @override
  void initState() {
    super.initState();
    TaskStorage.loadTasks().then((loadedTasks) {
      setState(() {
        tasks = loadedTasks; // Загрузка задач из локального хранилища
      });
    });
  }

  // Построение интерфейса экрана
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Планировщик задач'), // Заголовок приложения
      ),
      body: tasks.isEmpty
          ? Center(
        child: Text('Нет запланированных задач'), // Сообщение, если список пуст
      )
          : ListView.builder(
        itemCount: tasks.length, // Количество элементов в списке
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].title), // Заголовок задачи
            subtitle: Text(tasks[index].description), // Описание задачи
            trailing: IconButton(
              icon: Icon(
                tasks[index].isCompleted
                    ? Icons.check_circle // Иконка выполненной задачи
                    : Icons.check_circle_outline, // Иконка невыполненной задачи
              ),
              onPressed: () => toggleTaskCompletion(index), // Изменение статуса выполнения
            ),
            onTap: () async {
              // Открытие экрана редактирования задачи
              final editedTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(
                    task: tasks[index], // Передаем выбранную задачу
                    onDelete: deleteTask, // Передаем функцию удаления
                  ),
                ),
              );
              if (editedTask != null) {
                editTask(index, editedTask); // Обновляем задачу после редактирования
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Открытие экрана добавления новой задачи
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(onDelete: deleteTask), // Передаем функцию удаления
            ),
          );
          if (newTask != null) {
            addTask(newTask); // Добавляем новую задачу
          }
        },
        child: Icon(Icons.add), // Иконка для кнопки добавления задачи
      ),
    );
  }
}
