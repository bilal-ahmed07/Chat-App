import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});
  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  List<String> pendingRequestIds = [];
  String? currentRecordId;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: currentUid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final doc = query.docs.first;
    currentRecordId = doc.id;

    setState(() {
      pendingRequestIds = List<String>.from(doc['friendRequests'] ?? []);
    });
  }

  Future<void> _confirmRequest(String requesterId) async {
  if (currentRecordId == null) return;

  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final users = FirebaseFirestore.instance.collection('users');

  // Fetch requester user document by UID
  final requesterDocSnapshot = await users.where('uid', isEqualTo: requesterId).limit(1).get();
  if (requesterDocSnapshot.docs.isEmpty) return;
  final requesterDoc = requesterDocSnapshot.docs.first;
  final requesterData = requesterDoc.data();
  final requesterUsername = requesterData['username'];

  // Fetch current user document by currentRecordId
  final currentUserDoc = await users.doc(currentRecordId!).get();
  final currentUserData = currentUserDoc.data();
  final currentUsername = currentUserData?['username'];

  final batch = FirebaseFirestore.instance.batch();

  // Update friend lists and remove request
  batch.update(users.doc(currentRecordId!), {
    'friends': FieldValue.arrayUnion([requesterUsername]),
    'friendRequests': FieldValue.arrayRemove([requesterUsername]),
  });
  batch.update(requesterDoc.reference, {
    'friends': FieldValue.arrayUnion([currentUsername]),
  });

  // Sorted chat ID based on usernames
  final sortedUsernames = [currentUsername, requesterUsername]..sort();
  final chatId = sortedUsernames.join('_');

  final chatDocRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

  final chatSnapshot = await chatDocRef.get();
  if (!chatSnapshot.exists) {
    batch.set(chatDocRef, {
      'participants': sortedUsernames,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();

  setState(() => pendingRequestIds.remove(requesterId));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Friend request accepted')),
  );
}


  Future<void> _cancelRequest(String requesterId) async {
    if (currentRecordId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentRecordId!)
        .update({
          'friendRequests': FieldValue.arrayRemove([requesterId]),
        });

    setState(() => pendingRequestIds.remove(requesterId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Requests')),
      body: pendingRequestIds.isEmpty
          ? const Center(child: Text('No pending requests'))
          : ListView.builder(
              itemCount: pendingRequestIds.length,
              itemBuilder: (ctx, i) {
                final requesterId = pendingRequestIds[i];
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('uid', isEqualTo: requesterId)
                      .limit(1)
                      .get(),
                  builder: (ctx, snapU) {
                    if (!snapU.hasData || snapU.data!.docs.isEmpty) {
                      return const SizedBox();
                    }
                    final doc = snapU.data!.docs.first;
                    final d = doc.data() as Map<String, dynamic>;
                    final name = d['name'] ?? 'Unknown';
                    final username = d['username'] ?? '';
                    final dp = d['dp'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: dp.isNotEmpty
                            ? NetworkImage(dp)
                            : const AssetImage('assets/noProfilePic.jpg')
                                  as ImageProvider,
                      ),
                      title: Text(name),
                      subtitle: Text('@$username'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _confirmRequest(requesterId),
                            icon: const Icon(Icons.check, color: Colors.blue),
                            label: const Text('Confirm'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _cancelRequest(requesterId),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}