class IPomodoro {
  String? name;
  String? description;
  int time;
  int short;
  int long;
  int period;

  IPomodoro({
    required this.name,
    required this.description,
    required this.time,
    required this.short,
    required this.long,
    required this.period,
  });

  factory IPomodoro.fromJson(Map<String, dynamic> item) {
    return IPomodoro(
      name: item['name'],
      description: item['description'],
      time: item['time'],
      short: item['short'],
      long: item['long'],
      period: item['period'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "name": this.name,
      "description": this.description,
      "time": this.time,
      "short": this.short,
      "long": this.long,
      "period": this.period,
    };
  }
}
