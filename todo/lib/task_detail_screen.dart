import 'package:flutter/material.dart';
import 'task.dart';

// Экран для отображения и редактирования деталей задачи
class TaskDetailScreen extends StatefulWidget {
  // Задача для отображения (необязательно)
  final Task? task;

  // Функция для удаления задачи (необязательно)
  final Function(Task)? onDelete;

  TaskDetailScreen({this.task, this.onDelete});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // Ключ формы для управления состоянием валидации
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей ввода
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Переменные для хранения выбранной даты и времени
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Если передана задача, заполняем поля её данными
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      if (_selectedDate != null) {
        _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
      }
    }
  }

  // Метод для выбора даты через диалоговое окно
  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Текущая или выбранная дата
      firstDate: DateTime.now(), // Минимально допустимая дата
      lastDate: DateTime(2100), // Максимально допустимая дата
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Метод для выбора времени через диалоговое окно
  void _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(), // Текущее или выбранное время
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Виджет для выбора даты и времени
  Widget _buildDateTimeSelectors() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Дата не установлена'
                    : 'Дата: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text('Выбрать дату'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Цвет фона
                foregroundColor: Colors.white, // Цвет текста
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedTime == null
                    ? 'Время не установлено'
                    : 'Время: ${_selectedTime!.format(context)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
            ElevatedButton(
              onPressed: _pickTime,
              child: Text('Выбрать время'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Цвет фона
                foregroundColor: Colors.white, // Цвет текста
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Название экрана в зависимости от режима (создание или редактирование задачи)
      title: Text(
          widget.task == null ? 'Новая задача' : 'Редактировать задачу',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Увеличен размер текста
        ),
        backgroundColor: Colors.teal,
        titleTextStyle: TextStyle(color: Colors.white),
        actions: [
          // Кнопка удаления задачи, если она передана
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                widget.onDelete?.call(widget.task!); // Удаление задачи
                Navigator.pop(context); // Закрытие экрана
              },
              color: Colors.white,
            ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white, // Белый цвет стрелочки
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Внутренний отступ
        child: Form(
          key: _formKey, // Подключение формы
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название задачи с валидацией
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Название задачи',
                  hintText: 'Введите название задачи',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название задачи'; // Сообщение об ошибке
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Описание задачи
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  hintText: 'Введите описание задачи',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              SizedBox(height: 20),
              _buildDateTimeSelectors(), // Выбор даты и времени
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Сохранение задачи при успешной валидации
                    if (_formKey.currentState?.validate() ?? false) {
                      final task = Task(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        isCompleted: widget.task?.isCompleted ?? false,
                        dueDate: _selectedDate != null
                            ? DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime?.hour ?? 0,
                          _selectedTime?.minute ?? 0,
                        )
                            : null,
                      );
                      Navigator.pop(context, task);
                    }
                  },
                  child: Text(
                    'Сохранить',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
