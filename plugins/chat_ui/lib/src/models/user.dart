import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;

  User({required this.id, required this.name});

  static User fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      name: data['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = Map();
    data['id'] = this.id;
    data['name'] = this.name;

    return data;
  }

  @override
  List<Object?> get props => [id, name];
}
