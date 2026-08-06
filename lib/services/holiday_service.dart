class HolidayService {
  static final Map<String, String> _fixedHolidays = {
    "01-01": "Confraternização Universal",
    "21-04": "Tiradentes",
    "01-05": "Dia do Trabalho",
    "07-09": "Independência do Brasil",
    "12-10": "Nossa Senhora Aparecida",
    "02-11": "Finados",
    "15-11": "Proclamação da República",
    "20-11": "Dia da Consciência Negra",
    "25-12": "Natal",
  };

  static String? getHolidayName(DateTime date) {
    String key = "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}";
    
    // Check fixed
    if (_fixedHolidays.containsKey(key)) {
      return _fixedHolidays[key];
    }

    // Check movable
    Map<DateTime, String> movable = _calculateMovableHolidays(date.year);
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    if (movable.containsKey(dateOnly)) {
      return movable[dateOnly];
    }

    return null;
  }

  static Map<DateTime, String> _calculateMovableHolidays(int year) {
    DateTime easter = _calculateEaster(year);
    return {
      easter.subtract(const Duration(days: 48)): "Segunda-feira de Carnaval",
      easter.subtract(const Duration(days: 47)): "Terça-feira de Carnaval",
      easter.subtract(const Duration(days: 2)): "Sexta-feira Santa",
      easter: "Páscoa",
      easter.add(const Duration(days: 60)): "Corpus Christi",
    };
  }

  /// Butcher's Algorithm para calcular a data da Páscoa
  static DateTime _calculateEaster(int year) {
    int a = year % 19;
    int b = year ~/ 100;
    int c = year % 100;
    int d = b ~/ 4;
    int e = b % 4;
    int f = (b + 8) ~/ 25;
    int g = (b - f + 1) ~/ 3;
    int h = (19 * a + b - d - g + 15) % 30;
    int i = c ~/ 4;
    int k = c % 4;
    int l = (32 + 2 * e + 2 * i - h - k) % 7;
    int m = (a + 11 * h + 22 * l) ~/ 451;
    int month = (h + l - 7 * m + 114) ~/ 31;
    int day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }
}
