class Helper {

  String dateHelper(String date) {
    String finalDate;
    if (date != null) {
      DateTime newDate = DateTime.parse(date);

      String formatDate = newDate.day.toString() +'-'+ newDate.month.toString() +'-'+ newDate.year.toString();
      String currentDate = DateTime.now().day.toString() +'-'+ DateTime.now().month.toString() +'-'+ DateTime.now().year.toString();
      if (formatDate == currentDate) {
        finalDate = newDate.hour.toString() + ':' + newDate.minute.toString();
      } else {
        finalDate = formatDate;
      }
    }

    return finalDate;
  }
}