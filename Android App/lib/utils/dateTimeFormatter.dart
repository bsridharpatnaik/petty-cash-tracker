
import 'package:intl/intl.dart';

class DateTimeFormatter{
  String formatTime(String dateTime) {
    try {
      // Parse the input date-time string
      DateTime parsedDate = DateFormat("dd-MM-yyyy hh:mm:ss a").parse(dateTime);

      // Format the time portion as 'hh:mm a'
      String formattedTime = DateFormat("hh:mm a").format(parsedDate);
      return formattedTime;
    } catch (e) {
      print("Error parsing date-time: $e");
      return "";
    }
  }
  DateTime parseDate(String dateString) {
    try {
      DateFormat format = DateFormat("dd-MM-yyyy");
      return format.parse(dateString);
    } catch (e) {
      throw FormatException("Invalid date format: $dateString");
    }
  }
}