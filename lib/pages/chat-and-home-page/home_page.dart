import 'package:chatapp/pages/Auth/login_page.dart';
import 'package:chatapp/pages/chat%20and%20home%20page/pending_request.dart';
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

  List<QueryDocumentSnapshot> allChats = [];
  List<QueryDocumentSnapshot> chatList = [];

  final List<String> tabs = ['All', 'Unread', 'Read'];
  int selectedIndex = 0;

  String currentUserName = '';
  String currentUserUsername = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserInfo();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        setState(() {
          chatList = List.from(allChats);
        });
      } else {
        setState(() {
          chatList = allChats.where((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            final friendName = (data['friendName'] ?? '')
                .toString()
                .toLowerCase();
            final lastMessage = (data['lastMessage'] ?? '')
                .toString()
                .toLowerCase();
            return friendName.contains(query) || lastMessage.contains(query);
          }).toList();
        });
      }
    });
  }

  Future<void> _loadCurrentUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Get user info from users collection
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            currentUserName = userDoc.data()?['name'] ?? 'User';
            currentUserUsername = userDoc.data()?['username'] ?? 'username';
          });
        }
      } catch (e) {
        print('Error loading user info: $e');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return const Scaffold(body: SizedBox());
    }

    final currentUser = FirebaseAuth.instance.currentUser!;
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
              iconTheme: const IconThemeData(color: Colors.blue),
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.blue),
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
                    icon: const Icon(Icons.search, color: Colors.blue),
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
                      icon: const Icon(Icons.close, color: Colors.blue),
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
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                future: () {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) {
                    return Future.value(null);
                  }
                  return FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();
                }(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'User not found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final data = snapshot.data!.data();

                  if (data == null) {
                    return const Center(
                      child: Text(
                        'No user data',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final imageUrl = (data['profilePicUrl'] ?? '') as String;
                  final name = (data['name'] ?? 'User') as String;
                  final username = (data['username'] ?? 'username') as String;

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage('assets/noProfilePic.jpg')
                                  as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@$username',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            ListTile(
              leading: const Icon(Icons.search, color: Colors.blue),
              title: const Text("Search a friend"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchFriendPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text("Friend Requests"),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PendingRequestsPage()),
              ),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 30),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage())
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  bool isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: currentUser.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No chats yet"));
                }

                allChats = snapshot.data!.docs;

                if (!_isSearching || _searchController.text.isEmpty) {
                  chatList = List.from(allChats);
                }

                return ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final data =
                        chatList[index].data()! as Map<String, dynamic>;
                    final friendName = data['friendName'] ?? 'Friend';
                    final lastMessage = data['lastMessage'] ?? '';
                    final time = (data['lastMessageTime'] as Timestamp)
                        .toDate();

                    return ListTile(
                      leading: const CircleAvatar(),
                      title: Text(friendName),
                      subtitle: Text(lastMessage),
                      trailing: Text(
                        TimeOfDay.fromDateTime(time).format(context),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
