import 'package:chatter/models/message.dart';
import 'package:chatter/models/user.dart';
import 'package:equatable/equatable.dart';

class Room extends Equatable {
  final String id;
  final User? creator;
  final List<User> users;
  final List<Message> messages;

  Room({
    required this.id,
    this.creator,
    required this.users,
    required this.messages,
  });

  static Room fromMap(Map<String, dynamic> data) {
    return Room(
      id: data['id'] as String,
      creator: User.fromMap(data['creator']),
      users: data['users']
          ? (data['users'] as List<dynamic>)
              .map((e) => User.fromMap(e))
              .toList()
          : [],
      messages: data['messages']
          ? (data['messages'] as List<dynamic>)
              .map((e) => Message.fromMap(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = Map();
    data['id'] = this.id;
    data['creator'] = this.creator;
    data['users'] = this.users.map((e) => e.toMap());
    data['messages'] = this.messages.map((e) => e.toMap());
    return data;
  }

  @override
  List<Object?> get props => [id, creator, users, messages];
}
