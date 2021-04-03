import 'package:meta/meta.dart';

/// A class that represents user.
@immutable
class User {
  /// Creates a user.
  const User({
    this.avatarUrl,
    required this.name,
    required this.id,
  });

  /// Remote image URL representing user's avatar
  final String? avatarUrl;

  /// First name of the user
  final String name;

  /// Unique ID of the user
  final String id;

  static User fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] as String,
      name: data['name'] as String,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }
}
