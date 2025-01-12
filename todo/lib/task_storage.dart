import 'dart:convert'; // Для работы с JSON (кодирование и декодирование)
import 'package:shared_preferences/shared_preferences.dart'; // Для работы с локальным хранилищем
import 'task.dart'; // Модель задачи

// Класс для управления сохранением и загрузкой задач
class TaskStorage {
  // Ключ для хранения задач в SharedPreferences
  static const _tasksKey = 'tasks';

  // Метод для загрузки списка задач из локального хранилища
  static Future<List<Task>> loadTasks() async {
    // Получение экземпляра SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Получение строки задач из локального хранилища
    final tasksString = prefs.getString(_tasksKey);

    // Если строка задач существует, декодируем JSON в список объектов Task
    if (tasksString != null) {
      final List<dynamic> jsonList = jsonDecode(tasksString);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    }

    // Если данных нет, возвращаем пустой список
    return [];
  }

  // Метод для сохранения списка задач в локальное хранилище
  static Future<void> saveTasks(List<Task> tasks) async {
    // Получение экземпляра SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Преобразование списка задач в JSON-строку
    final jsonList = tasks.map((task) => task.toJson()).toList();

    // Сохранение JSON-строки в локальное хранилище
    prefs.setString(_tasksKey, jsonEncode(jsonList));
  }
}
