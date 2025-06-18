import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.blue,weight: 95,),
          // onPressed: () => Navigator.of(context).pop(),
          onPressed: () {},
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/noProfile.jpg'),
              radius: 22,
            ),

            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bilal Ahmed',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'bilalahmed',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Colors.blue),
            onPressed: () {
              // Add call action
            },
          ),
        ],
      ),
    );
  }
}
