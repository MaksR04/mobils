import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Отключаем баннер отладки
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String input = ""; // Строка для хранения текущего выражения
  String result = ""; // Строка для отображения результата
  int openBracketsCount = 0; // Счётчик открытых скобок
  bool isResultDisplayed = false; // Флаг, показывающий, отображается ли результат

  // Функция для обработки нажатий на кнопки
  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        // Очистить всё
        input = "";
        result = "";
        openBracketsCount = 0;
      } else if (value == "⌫") {
        // Удалить последний символ
        if (input.isNotEmpty) {
          String lastChar = input[input.length - 1];
          if (lastChar == "(") openBracketsCount--;
          if (lastChar == ")") openBracketsCount++;
          input = input.substring(0, input.length - 1);
        }
      } else if (value == "()") {
        // Обработка кнопки скобок
        if (openBracketsCount > 0) {
          input += ")";
          openBracketsCount--;
        } else {
          input += "(";
          openBracketsCount++;
        }
      } else if (value == "=") {
        // Вычисление результата
        try {
          if (openBracketsCount == 0) {
            result = evaluateExpression(input); // Вычислить выражение
            isResultDisplayed = true;
          } else {
            result = "Ошибка: скобки"; // Несбалансированные скобки
          }
        } catch (e) {
          result = "Ошибка"; // Ошибка в выражении
        }
      } else {
        if (isResultDisplayed) {
          // Если отображается результат, начать новый ввод
          if (value == ".") {
            // Если точка, использовать результат как начальное значение
            input = result + value;
          } else if ("+-*/^".contains(value)) {
            // Если оператор, использовать результат как начальное значение
            input = result + value;
          } else {
            // Иначе начать новый пример
            input = value;
          }
          result = "";
          isResultDisplayed = false;
        } else {
          input += value; // Добавить символ к текущему вводу
        }
      }
    });
  }

  // Функция для вычисления выражения
  String evaluateExpression(String expression) {
    try {
      // Проверка деления на 0
      if (expression.contains("/0")) {
        return "Ошибка: делить на 0 нельзя!";
      }
      Parser parser = Parser(); // Создаём парсер для выражения
      Expression exp = parser.parse(expression); // Парсим выражение
      ContextModel cm = ContextModel(); // Контекст для переменных (пустой)
      double eval = exp.evaluate(EvaluationType.REAL, cm); // Вычисляем значение
      return (eval % 1 == 0) ? eval.toInt().toString() : eval.toString(); // Убираем десятичную часть, если число целое
    } catch (e) {
      return "Ошибка"; // Обработка ошибок
    }
  }

  @override
  Widget build(BuildContext context) {
    // Список кнопок калькулятора
    final List<String> buttons = [
      "C", "⌫", "()", "/",
      "7", "8", "9", "*",
      "4", "5", "6", "-",
      "1", "2", "3", "+",
      "^", "0", ".", "=",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
        backgroundColor: Colors.blue, // Цвет AppBar
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Расположить элементы внизу
        children: [
          // Отображение текущего выражения
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(20),
            child: Text(
              input,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
            ),
          ),
          // Отображение результата
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(20),
            child: Text(
              result,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          // Кнопки калькулятора
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Четыре кнопки в строке
              mainAxisSpacing: 10, // Расстояние между строками
              crossAxisSpacing: 10, // Расстояние между кнопками
            ),
            itemCount: buttons.length, // Количество кнопок
            shrinkWrap: true, // Уменьшить GridView до его содержимого
            physics: NeverScrollableScrollPhysics(), // Отключить прокрутку
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final buttonText = buttons[index]; // Текст кнопки
              final isOperator = "+-*/^=C⌫".contains(buttonText); // Проверка, является ли кнопка оператором

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOperator ? Colors.orange : Colors.blueAccent, // Цвет кнопки
                  foregroundColor: Colors.white, // Цвет текста
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Закруглённые углы
                  ),
                ),
                onPressed: () => buttonPressed(buttonText), // Обработка нажатия
                child: Text(
                  buttonText,
                  style: TextStyle(fontSize: 25), // Размер текста кнопки
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
