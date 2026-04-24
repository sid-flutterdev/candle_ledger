import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/screen/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAccess();
  }

  void _checkAccess() {
    final user = FirebaseAuth.instance.currentUser;
    // Allow if it's the real firebase user OR if we're bypassing for admin@tester
    if (user != null && user.email == "admin@tester") return;

    // If not authenticated as admin, kick out
    if (user == null) {
      // In bypass mode, user might be null, but we'll let them stay for now
      // to see the screen UI. But data will fail if rules are active.
      return;
    }

    if (user.email != "admin@tester") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => const ScreenSignIn());
        Get.snackbar(
          "Access Denied",
          "You do not have permission to access the Admin Portal.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Admin Portal",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => const ScreenSignIn());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.outfit(),
          tabs: const [
            Tab(text: "Users"),
            Tab(text: "Online"),
            Tab(text: "Broadcast"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersList(),
          _buildOnlineUsers(),
          _buildBroadcastTab(),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    final user = FirebaseAuth.instance.currentUser;
    final isBypassMode = user == null || user.email != "admin@tester";

    return Column(
      children: [
        if (isBypassMode)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orangeAccent.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orangeAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Restricted Mode: Data access requires real Firebase Authentication.",
                    style: GoogleFonts.outfit(
                      color: Colors.orangeAccent,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_person_rounded,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Access Denied",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Firestore security rules are blocking access. Please apply the required rules in your Firebase Console to view user data.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                        ),
                        const SizedBox(height: 32),
                        if (isBypassMode)
                          ElevatedButton.icon(
                            onPressed: () => Get.to(() => const ScreenSignIn()),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text("Go to Sign In"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          "Error: ${snapshot.error}",
                          style: GoogleFonts.outfit(color: Colors.white10, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                );
              }

              final users = snapshot.data?.docs ?? [];

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        color: Colors.white10,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No users found in database",
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Users will appear here once they log in.",
                        style: GoogleFonts.outfit(
                          color: Colors.white10,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  return _buildUserCard(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineUsers() {
    // Note: This requires a 'lastActive' field in Firestore updated frequently
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where(
            'lastActive',
            isGreaterThan: Timestamp.fromDate(fiveMinutesAgo),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error checking status: ${snapshot.error}",
              style: GoogleFonts.outfit(color: Colors.redAccent),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          );
        }

        final onlineUsers = snapshot.data?.docs ?? [];

        if (onlineUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_off_rounded, color: Colors.white10, size: 48),
                const SizedBox(height: 12),
                Text(
                  "No users online currently",
                  style: GoogleFonts.outfit(color: Colors.white38),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: onlineUsers.length,
          itemBuilder: (context, index) {
            final user = onlineUsers[index].data() as Map<String, dynamic>;
            return _buildUserCard(user, isOnline: true);
          },
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, {bool isOnline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                  child: Text(
                    (user['name'] ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'No Name',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user['email'] ?? 'No Email',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (user['lastActive'] != null)
                  Text(
                    isOnline ? "ACTIVE NOW" : "LAST SEEN",
                    style: GoogleFonts.outfit(
                      color: isOnline ? Colors.green : Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                if (user['lastActive'] != null)
                  Text(
                    isOnline
                        ? "Online"
                        : DateFormat(
                            'dd MMM, HH:mm',
                          ).format((user['lastActive'] as Timestamp).toDate()),
                    style: GoogleFonts.outfit(
                      color: isOnline ? Colors.green : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastTab() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Send Broadcast Message",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This will be sent to all users instantly via real-time sync and push notifications.",
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildAdminTextField(
            titleController,
            "Notification Title (e.g. Market Alert)",
          ),
          const SizedBox(height: 16),
          _buildAdminTextField(
            messageController,
            "Detailed Message...",
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Implementation for sending notification would go here
                // Usually via a Cloud Function call
                _sendNotification(titleController.text, messageController.text);
              },
              child: Text(
                "SEND BROADCAST",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _sendNotification(String title, String message) async {
    if (title.isEmpty || message.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // 1. Create a broadcast document in Firestore
      // A Firebase Cloud Function should listen to this collection and send the FCM
      await _firestore.collection('broadcasts').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': FirebaseAuth.instance.currentUser?.email,
      });

      Get.snackbar(
        "Broadcast Sent",
        "Your message has been queued for delivery to all users.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send broadcast: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
