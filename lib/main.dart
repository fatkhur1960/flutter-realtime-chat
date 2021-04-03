import 'package:chatter/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      appId: '1:553845154498:web:9045ad142313d8685c515b',
      apiKey: 'AIzaSyCL6TKrmXzfAZ_cwzGwrZsoz5DC8FwWQAg',
      projectId: 'satir-784ca',
      messagingSenderId: '553845154498',
      storageBucket: 'gs://satir-784ca.appspot.com',
    ),
  );

  Socket socket = io('http://192.168.0.113:8888/', <String, dynamic>{
    'transports': ['websocket'],
  });

  socket.connect();

  socket.onConnect((_) {
    print('connected');
  });
  socket.onConnectError((data) => print(data));
  socket.onError((data) => print(data));

  initializeDateFormatting().then((_) => runApp(ChatterApp(socketIO: socket)));
}

class ChatterApp extends StatelessWidget {
  final Socket socketIO;

  const ChatterApp({Key? key, required this.socketIO}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(socketIO: socketIO),
    );
  }
}
