import 'package:chatter/models/room.dart';
import 'package:chatter/models/user.dart';
import 'package:chatter/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:avatars/avatars.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final IO.Socket socketIO;

  const HomeScreen({Key? key, required this.username, required this.socketIO})
      : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Room> rooms = [];
  User? currentUser;
  bool connected = true;

  @override
  void initState() {
    super.initState();
    widget.socketIO.emit("register", widget.username);
    widget.socketIO.on("registered", (data) {
      setState(() {
        rooms = (data['rooms'] as List<dynamic>)
            .map(
              (e) => Room(
                id: e,
                messages: [],
                users: [],
              ),
            )
            .toList();
        currentUser = User.fromMap(data['user']);
      });
    });
    widget.socketIO.onReconnect((data) {
      setState(() => connected = true);
      widget.socketIO.emit("register", widget.username);
    });
    widget.socketIO.onReconnecting((_) => setState(() => connected = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F6FB),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool scroll) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 130.0,
              toolbarHeight: 73,
              pinned: true,
              elevation: 0,
              backgroundColor: Color(0xFFF1F6FB),
              title: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "Chats",
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      color: Color(0xFF2D3748),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: LineIcon.bellAlt(
                          color: Colors.grey[700],
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {},
                        child: LineIcon.userCog(
                          color: Colors.grey[700],
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {},
                        child: LineIcon.verticalEllipsis(
                          color: Colors.grey[700],
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                )
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Cari mata pelajaran...",
                      prefixIcon: LineIcon.search(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Stack(
          children: [
            Visibility(
              visible: !connected,
              child: Positioned(
                height: 24.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  color: Color(0xFFEE4400),
                  child: Center(
                    child: Text("Reconnecting..."),
                  ),
                ),
              ),
            ),
            _buildChatList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(18),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Card(
          elevation: 0.1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    room: room,
                    socketIO: widget.socketIO,
                    currentUser: currentUser!,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Avatar(
                      name: room.id,
                      shape: AvatarShape.circle(100),
                      textStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: 12.0, right: 5),
                      title: Text(
                        "${room.id}",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Color(0xFF2D3748),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        "Lorem ipsum sit, lorem ipsum...",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Color(0x9F2D3748),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "08.00",
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                color: Color(0x9F2D3748),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.fiber_new,
                            color: Colors.green[600],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
