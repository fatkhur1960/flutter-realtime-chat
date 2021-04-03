import 'dart:io';

import 'package:chatter/models/message.dart';
import 'package:chatter/models/room.dart';
import 'package:chatter/models/user.dart';
import 'package:chatter/utils/parse_chat.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
// import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as Type;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as UI;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatScreen extends StatefulWidget {
  final Room room;
  final User currentUser;
  final Socket socketIO;

  const ChatScreen({
    Key? key,
    required this.room,
    required this.socketIO,
    required this.currentUser,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<User> users = [];
  List<Type.Message> messages = [];

  @override
  void initState() {
    super.initState();
    widget.socketIO.emit("join", widget.room.id);

    widget.socketIO.on("joined", (data) {
      if (!mounted) return;
      setState(() {
        users = (data['users'] as List<dynamic>)
            .map((e) => User.fromMap(e))
            .toList();
        messages = (data['messages'] as List<dynamic>).map(parseChat).toList();
      });
    });
    widget.socketIO.on("message", (data) {
      if (!mounted) return;
      _addMessage(Message.fromMap(data));
    });
    widget.socketIO.onReconnect((data) {
      widget.socketIO.emit("register", widget.currentUser.name);
      widget.socketIO.emit("join", widget.room.id);
    });
  }

  @override
  void dispose() {
    widget.socketIO.emit('leave', widget.room.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.room.id, style: GoogleFonts.roboto()),
      ),
      body: _buildChatList(context),
    );
  }

  void _addMessage(Message msg) {
    Type.Message message = parseOwnMessage(msg);
    setState(() {
      messages.add(message);
    });
  }

  void _onSendMessage(Type.PartialText message) {
    final msg = Message(
      id: Uuid().v4(),
      sender: widget.currentUser,
      text: message.text,
      date: DateTime.now(),
      type: 'text',
    );
    widget.socketIO.emit('sendMessage', {
      'message': msg.toMap(),
      'roomId': widget.room.id,
    });
    setState(() {
      _addMessage(msg);
    });
  }

  void _handleFilePressed(Type.FileMessage message) async {
    await OpenFile.open(message.uri);
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text("Photo"),
              leading: LineIcon.imageFile(),
              onTap: () {
                Navigator.pop(context);
                _handleImageSelection();
              },
            ),
            ListTile(
              title: Text("File"),
              leading: LineIcon.fileAlt(),
              onTap: () {
                Navigator.pop(context);
                _handleFileSelection();
              },
            ),
            ListTile(
              leading: LineIcon.times(),
              onTap: () => Navigator.pop(context),
              title: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _handleFileSelection() async {
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.any,
    // );

    // if (result != null) {
    //   _addMessage(Message(
    //     id: Uuid().v4(),
    //     sender: widget.currentUser,
    //     date: DateTime.now(),
    //     type: 'file',
    //     file: FileMessage(
    //       fileName: result.files.single.name ?? '',
    //       mimeType: lookupMimeType(result.files.single.path ?? ''),
    //       size: result.files.single.size ?? 0,
    //       uri: result.files.single.path ?? '',
    //     ),
    //   ));
    // }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().getImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final imageName = result.path.split('/').last;

      final msg = Message(
        id: Uuid().v4(),
        sender: widget.currentUser,
        date: DateTime.now(),
        type: 'image',
        image: ImageMessage(
          imageName: imageName,
          size: bytes.length,
          uri: result.path,
          width: image.width.toDouble(),
        ),
      );

      _addMessage(msg);

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('images/$imageName');
      UploadTask uploadTask = firebaseStorageRef.putFile(File(result.path));
      await uploadTask.whenComplete(() {
        TaskSnapshot taskSnapshot = uploadTask.snapshot;
        taskSnapshot.ref.getDownloadURL().then((value) {
          final index = messages.indexWhere((element) => element.id == msg.id);
          final updatedMsg =
              msg.copyWith(image: msg.image!.copyWith(uri: value));

          widget.socketIO.emit('sendMessage', {
            'message': updatedMsg.toMap(),
            'roomId': widget.room.id,
          });

          WidgetsBinding.instance?.addPostFrameCallback((_) {
            setState(() {
              messages.removeAt(index);
            });
            _addMessage(updatedMsg);
          });
        });
      });
    }
  }

  Widget _buildChatList(BuildContext context) {
    return UI.Chat(
      messages: messages.reversed.toList(),
      onAttachmentPressed: _handleAtachmentPressed,
      onSendPressed: _onSendMessage,
      onFilePressed: _handleFilePressed,
      user: Type.User.fromJson(widget.currentUser.toMap()),
      l10n: UI.ChatL10nId(),
      showName: true,
      theme: UI.DefaultChatTheme(
        backgroundColor: Color(0xFFE5E5E5),
        inputBackgroundColor: Colors.white,
        inputBorderRadius: BorderRadius.all(Radius.circular(300)),
        inputTextColor: Colors.black45,
        secondaryColor: Colors.white,
        messageBorderRadius: 12,
        body1: GoogleFonts.roboto(fontSize: 16),
        body2: GoogleFonts.roboto(fontSize: 16),
        caption: GoogleFonts.roboto(fontSize: 12, height: 1.4),
      ),
    );
  }
}
