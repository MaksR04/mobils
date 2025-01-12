class Task {
  // Название задачи
  String title;

  // Описание задачи (не обязательный параметр)
  String description;

  // Статус выполнения задачи (по умолчанию - не выполнено)
  bool isCompleted;

  // Дата завершения задачи (не обязательный параметр)
  DateTime? dueDate;

  // Конструктор для инициализации задачи
  Task({
    required this.title, // Название задачи обязательно
    required this.description, // Описание задачи необязательно
    this.isCompleted = false, // Статус выполнения по умолчанию - false (не выполнено)
    this.dueDate, // Дата завершения задачи необязательна
  });

  // Преобразование объекта Task в Map для хранения в формате JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title, // Название задачи
      'description': description, // Описание задачи
      'isCompleted': isCompleted, // Статус выполнения
      'dueDate': dueDate?.toIso8601String(), // Преобразование даты завершения в строку (если она существует)
    };
  }

  // Статический метод для создания объекта Task из Map, полученного из JSON
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'], // Извлечение названия задачи из JSON
      description: json['description'], // Извлечение описания задачи из JSON
      isCompleted: json['isCompleted'], // Извлечение статуса выполнения из JSON
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate']) // Преобразование строки даты в DateTime, если она существует
          : null, // Если дата не существует, присваиваем null
    );
  }
}
