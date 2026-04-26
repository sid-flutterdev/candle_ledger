import 'package:candle_ledger/core/widgets/glass_container.dart';
import 'package:candle_ledger/core/widgets/app_loading_dialog.dart';
import 'package:candle_ledger/screen/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  final bool isBackdoor;
  const AdminScreen({super.key, this.isBackdoor = false});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _titleController;
  late TextEditingController _messageController;

  bool _isCheckingRole = true;
  bool _hasAdminRole = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _titleController = TextEditingController();
    _messageController = TextEditingController();
    _checkAdminRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminRole() async {
    if (widget.isBackdoor) {
      if (mounted) {
        setState(() {
          _hasAdminRole = true;
          _isCheckingRole = false;
        });
      }
      return;
    }

    setState(() => _isCheckingRole = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _redirectToLogin();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        if (mounted) {
          setState(() {
            _hasAdminRole = true;
            _isCheckingRole = false;
          });
        }
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      debugPrint("Error checking admin role: $e");
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    if (_isCheckingRole) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.purpleAccent),
        ),
      );
    }

    if (!_hasAdminRole) {
      return const SizedBox.shrink(); // Should have redirected
    }

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
              AppLoadingDialog.show("Logging Out", subtitle: "Closing Admin Portal...");
              await FirebaseAuth.instance.signOut();
              AppLoadingDialog.hide();
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
    if (user == null) {
      return _buildEmptyState(
        "Please Log In\nData access requires authentication even in Backdoor mode.",
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          );
        }

        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) return _buildEmptyState("No users found");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildOnlineUsers() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _buildEmptyState(
        "Please Log In\nData access requires authentication even in Backdoor mode.",
      );
    }
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
          return _buildErrorState(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          );
        }

        final onlineUsers = snapshot.data?.docs ?? [];
        if (onlineUsers.isEmpty) {
          return _buildEmptyState("No users online currently");
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

  Widget _buildBroadcastTab() {
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
          _buildAdminTextField(_titleController, "Notification Title"),
          const SizedBox(height: 16),
          _buildAdminTextField(
            _messageController,
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
              onPressed: FirebaseAuth.instance.currentUser == null
                  ? null
                  : () => _sendNotification(
                      _titleController.text,
                      _messageController.text,
                    ),
              child: Text(
                FirebaseAuth.instance.currentUser == null
                    ? "LOGIN TO SEND"
                    : "SEND BROADCAST",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Error",
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline_rounded,
            color: Colors.white10,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, {bool isOnline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.purple.withValues(alpha: 0.2),
              child: Text(
                (user['name'] ?? 'U')[0].toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    ),
                  ),
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
            if (isOnline)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
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
    if (title.isEmpty || message.isEmpty) return;
    try {
      AppLoadingDialog.show("Sending Broadcast", subtitle: "Syncing message to all users...");
      await _firestore.collection('broadcasts').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': FirebaseAuth.instance.currentUser?.email,
      });
      AppLoadingDialog.hide();
      Get.snackbar(
        "Success",
        "Broadcast sent",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _titleController.clear();
      _messageController.clear();
    } catch (e) {
      AppLoadingDialog.hide();
      Get.snackbar(
        "Error",
        "Failed to send: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
