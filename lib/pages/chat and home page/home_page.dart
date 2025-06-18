import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List chatList = [];

  final List<String> tabs = ['All', 'Unread', 'Read', 'Groups'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            // Base AppBar with drawer icon only
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.blue),
              title: Text(''),
              actions: [],
            ),

            // Sliding search icon
            AnimatedPositioned(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              left: _isSearching ? 56 : screenWidth - 56,
              top: 32,

              child: SizedBox(
                height: kToolbarHeight - 16,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Search field (fades in)
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 23,
              left: _isSearching ? 100 : screenWidth,
              right: 48,
              child: AnimatedOpacity(
                opacity: _isSearching ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
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

            // Close icon to cancel search
            if (_isSearching)
              Positioned(
                right: 0,
                top: 23,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.blue),
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
            DrawerHeader(child: Text("Header")),

            ListTile(
              title: Text("Search a friend"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: Text("Friend Requests"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            Spacer(),

            Divider(),

            ListTile(
              leading: Icon(Icons.logout, color: Colors.red, size: 30),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
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
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding: EdgeInsets.symmetric(
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
            child: ListView.builder(
              itemCount: 15, //Chat Count
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(),
                  title: Text('Username $index'),
                  subtitle: Text('Last message preview...'),
                  trailing: Text('12:45 PM'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
