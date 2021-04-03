import 'package:chatter/models/user.dart';
import 'package:equatable/equatable.dart';

class ImageMessage {
  final String uri;
  final String imageName;
  final int size;
  final double? width;

  ImageMessage({
    required this.uri,
    required this.imageName,
    required this.size,
    this.width,
  });

  static ImageMessage fromMap(Map<String, dynamic> data) {
    return ImageMessage(
      uri: data['uri'] as String,
      imageName: data['imageName'] as String,
      size: data['size'] as int,
      width: data['width'] != null ? data['width'] as double : null,
    );
  }

  ImageMessage copyWith({
    String? uri,
    String? imageName,
    int? size,
    double? width,
  }) {
    return ImageMessage(
      uri: uri ?? this.uri,
      imageName: imageName ?? this.imageName,
      size: size ?? this.size,
      width: width ?? this.width,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = Map();
    data['uri'] = this.uri;
    data['imageName'] = this.imageName;
    data['size'] = this.size;

    return data;
  }
}

class FileMessage {
  final String uri;
  final String fileName;
  final String? mimeType;
  final int size;

  FileMessage({
    required this.uri,
    required this.fileName,
    required this.size,
    this.mimeType,
  });

  static FileMessage fromMap(Map<String, dynamic> data) {
    return FileMessage(
      uri: data['uri'] as String,
      fileName: data['fileName'] as String,
      mimeType: data['mimeType'] != null ? data['mimeType'] as String? : null,
      size: data['size'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = Map();
    data['uri'] = this.uri;
    data['fileName'] = this.fileName;
    data['size'] = this.size;

    return data;
  }
}

class Message extends Equatable {
  final String id;
  final User sender;
  final String? text;
  final String? type;
  final DateTime? date;
  final ImageMessage? image;
  final FileMessage? file;

  Message({
    required this.id,
    required this.sender,
    this.text,
    this.type,
    this.date,
    this.image,
    this.file,
  });

  static Message fromMap(Map<String, dynamic> data) {
    return Message(
      id: data['id'] as String,
      sender: User.fromMap(data['sender']),
      text: data['text'] as String?,
      type: data['type'] as String?,
      date: DateTime.tryParse(data['date']),
      image: data['image'] != null ? ImageMessage.fromMap(data['image']) : null,
      file: data['file'] != null ? FileMessage.fromMap(data['file']) : null,
    );
  }

  Message copyWith({
    ImageMessage? image,
    FileMessage? file,
  }) {
    return Message(
      id: this.id,
      sender: this.sender,
      text: this.text,
      type: this.type,
      date: this.date,
      image: image ?? this.image,
      file: file ?? this.file,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = Map();
    data['id'] = this.id;
    data['sender'] = this.sender.toMap();
    data['text'] = this.text;
    data['type'] = this.type;
    data['date'] = this.date.toString();
    data['image'] = this.image != null ? this.image!.toMap() : null;
    data['file'] = this.file != null ? this.file!.toMap() : null;

    return data;
  }

  @override
  List<Object?> get props => [id, sender, type, date];
}
