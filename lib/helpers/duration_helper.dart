class DurationHelper {
  static String videoPlayerTimerString(double milliseconds) {
    int hoursInt = milliseconds ~/ 3600000;
    int minutesInt = (milliseconds ~/ 60000) - (hoursInt * 60);
    int secondsInt = (milliseconds ~/ 1000) - (minutesInt * 60);

    String hoursString = hoursInt > 0
        ? hoursInt < 10
            ? "0$hoursInt:"
            : "$hoursInt:"
        : "";
    String minutesString =
        hoursInt > 0 && minutesInt < 10 ? "0$minutesInt:" : "$minutesInt:";
    String secondsString = secondsInt < 10 ? "0$secondsInt" : "$secondsInt";

    return "$hoursString$minutesString$secondsString";
  }
}
