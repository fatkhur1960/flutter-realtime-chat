import 'package:equatable/equatable.dart';
import 'user.dart';

class Message extends Equatable {
  final String id;
  final User sender;
  final String text;
  final String? type;
  final DateTime? date;

  // ignore: sort_constructors_first
  const Message({
    required this.id,
    required this.sender,
    required this.text,
    this.type,
    this.date,
  });

  static Message fromMap(Map<String, dynamic> data) {
    return Message(
      id: data['id'] as String,
      sender: User.fromMap(data['sender'] as Map<String, dynamic>),
      text: data['text'] as String,
      type: data['type'] as String?,
      date: DateTime.tryParse(data['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['sender'] = sender.toMap();
    data['text'] = text;
    data['type'] = type;
    data['date'] = date.toString();

    return data;
  }

  @override
  List<Object?> get props => [id, sender, type, date];
}
