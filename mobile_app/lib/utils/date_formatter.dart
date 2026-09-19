class DateFormatter {
  /// Converts UTC / ISO / DB timestamps to Indian Standard Time (IST, UTC+5:30)
  static String formatToIST(dynamic dateInput) {
    if (dateInput == null) return "";
    final str = dateInput.toString().trim();
    if (str.isEmpty) return "";

    try {
      DateTime dt;
      if (str.endsWith("Z") || str.contains("Z")) {
        dt = DateTime.parse(str).toUtc();
      } else if (str.contains("T")) {
        dt = DateTime.parse("${str}Z").toUtc();
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}').hasMatch(str)) {
        dt = DateTime.parse("${str.replaceAll(' ', 'T')}Z").toUtc();
      } else {
        dt = DateTime.parse(str).toUtc();
      }

      // Add 5 Hours 30 Minutes for IST
      final ist = dt.add(const Duration(hours: 5, minutes: 30));

      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final monthStr = months[ist.month - 1];
      int hour = ist.hour;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final minuteStr = ist.minute.toString().padLeft(2, '0');

      return "${ist.day.toString().padLeft(2, '0')} $monthStr ${ist.year}, ${hour.toString().padLeft(2, '0')}:$minuteStr $ampm";
    } catch (_) {
      return str;
    }
  }
}
