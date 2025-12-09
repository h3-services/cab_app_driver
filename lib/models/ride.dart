class Ride {
  final String id;
  final String pickup;
  final String drop;
  final String timeText;
  final String passengerName;
  final String passengerPhone;
  bool isAccepted;

  Ride({
    required this.id,
    required this.pickup,
    required this.drop,
    required this.timeText,
    required this.passengerName,
    required this.passengerPhone,
    this.isAccepted = false,
  });
}
