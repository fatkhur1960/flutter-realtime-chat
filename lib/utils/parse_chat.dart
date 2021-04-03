import 'package:chatter/models/message.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as Type;

Type.Message parseChat(dynamic data) {
  final msg = Message.fromMap(data);
  if (msg.type == 'file') {
    final file = msg.file!;
    return Type.FileMessage(
      id: msg.id,
      author: Type.User.fromJson(msg.sender.toMap()),
      uri: file.uri,
      fileName: file.fileName,
      size: file.size,
      timestamp: (msg.date!.millisecondsSinceEpoch / 1000).floor(),
    );
  } else if (msg.type == 'image') {
    final image = msg.image!;
    return Type.ImageMessage(
      id: msg.id,
      author: Type.User.fromJson(msg.sender.toMap()),
      uri: image.uri,
      imageName: image.imageName,
      size: image.size,
      timestamp: (msg.date!.millisecondsSinceEpoch / 1000).floor(),
    );
  } else {
    return Type.TextMessage(
      id: msg.id,
      author: Type.User.fromJson(msg.sender.toMap()),
      text: msg.text!,
      timestamp: (msg.date!.millisecondsSinceEpoch / 1000).floor(),
    );
  }
}

Type.Message parseOwnMessage(Message msg) {
  Type.Message message;
  if (msg.type == 'file') {
    final file = msg.file!;
    message = Type.FileMessage(
      id: msg.id,
      author: Type.User.fromJson(msg.sender.toMap()),
      uri: file.uri,
      fileName: file.fileName,
      size: file.size,
      timestamp: (msg.date!.millisecondsSinceEpoch / 1000).floor(),
      mimeType: file.mimeType,
      status: Type.Status.sending,
    );
  } else if (msg.type == 'image') {
    final image = msg.image!;
    message = Type.ImageMessage(
      id: msg.id,
      author: Type.User.fromJson(msg.sender.toMap()),
      uri: image.uri,
      imageName: image.imageName,
      size: image.size,
      timestamp: (msg.date!.millisecondsSinceEpoch / 1000).floor(),
      width: image.width,
      status: Type.Status.sending,
    );
  } else {
    message = Type.TextMessage(
      id: msg.id,
      author: Type.User.fromJson(msg.sender.toMap()),
      text: msg.text!,
      timestamp: (msg.date!.millisecondsSinceEpoch / 1000).floor(),
      status: Type.Status.delivered,
    );
  }
  return message;
}
