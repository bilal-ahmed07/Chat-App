import 'package:chatapp/pages/Auth/login_page.dart';
import 'package:chatapp/pages/chat-and-home-page/chat_screen.dart';
import 'package:chatapp/pages/chat-and-home-page/pending_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'new_friend_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  String currentUserName = '';
  String currentUserUsername = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();
  }

  Future<void> _loadCurrentUserInfo() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: u.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        setState(() {
          currentUserName = data['name'] ?? '';
          currentUserUsername = data['username'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Could not find user document for UID: ${u.uid}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occured')));
    }
  }

  String _getChatId(String friendUsername) {
    final users = [currentUserUsername, friendUsername]..sort();
    return users.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    // print(u);
    if (u == null) {
      Future.microtask(
        () => Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage())),
      );
      return const Scaffold(body: SizedBox());
    }

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              // iconTheme: const IconThemeData(color: Colors.blue),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text(''),
              actions: [],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              left: _isSearching ? 56 : screenWidth - 56,
              top: 32,
              child: SizedBox(
                height: kToolbarHeight - 16,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 23,
              left: _isSearching ? 100 : screenWidth,
              right: 48,
              child: AnimatedOpacity(
                opacity: _isSearching ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isSearching)
              Positioned(
                right: 0,
                top: 23,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Container(
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@$currentUserUsername',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search a friend'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchFriendPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Friend Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PendingRequestsPage(),
                  ),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: currentUserUsername.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: currentUserUsername)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No chats yet.'));
                }

                final chatDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    final chatData =
                        chatDocs[index].data() as Map<String, dynamic>;
                    final participants = List<String>.from(
                      chatData['participants'] ?? [],
                    );

                    final friendUsername = participants.firstWhere(
                      (username) => username != currentUserUsername,
                      orElse: () => '',
                    );

                    if (friendUsername.isEmpty) return const SizedBox();

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where('username', isEqualTo: friendUsername)
                          .limit(1)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData ||
                            userSnapshot.data!.docs.isEmpty) {
                          return const SizedBox();
                        }

                        final userData =
                            userSnapshot.data!.docs.first.data()
                                as Map<String, dynamic>;

                        final dp = userData['dp'] ?? '';
                        final displayName = userData['name'] ?? friendUsername;
                        final friendUid = userData['uid'] ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 35,
                            backgroundImage: dp.isNotEmpty
                                ? NetworkImage(dp)
                                : const AssetImage('assets/noProfilePic.jpg')
                                      as ImageProvider,
                          ),
                          title: Text(displayName,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                          subtitle: Text('@$friendUsername',style: TextStyle(fontSize: 14),),
                          onTap: () {
                            if (friendUid.isNotEmpty) {
                              final chatId = _getChatId(friendUsername);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    receiverName: displayName,
                                    receiverUsername: friendUsername,
                                    receiverId: friendUid,
                                    chatId: chatId,
                                    receiverDp: dp,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error: Could not find user UID.',
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
