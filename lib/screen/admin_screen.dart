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
  
  // Controllers for Broadcast
  late TextEditingController _titleController;
  late TextEditingController _messageController;

  static const String adminEmail = "admin.candle@gmail.com";
  static const String adminPassword = "Sid@dev*";

  bool get _isAdminSession {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.email?.toLowerCase() == adminEmail;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _titleController = TextEditingController();
    _messageController = TextEditingController();
    _checkAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _isLoggingIn = false;
  String? _loginError;

  void _checkAccess() {
    if (_isAdminSession) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _performQuickAdminLogin();
      return;
    }

    // If user is logged in but NOT the specific admin email, redirect them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => const ScreenSignIn());
      Get.snackbar(
        "Access Denied",
        "You do not have permission to access the Admin Portal.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  Future<void> _performQuickAdminLogin() async {
    if (_isLoggingIn) return;
    
    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    const adminEmail = "admin.candle@gmail.com";
    const adminPassword = "Sid@dev*";

    try {
      debugPrint("Attempting admin auto-login...");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      // ✅ Always ensure the admin role is set in Firestore on login
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'uid': currentUser.uid,
          'email': adminEmail,
          'role': 'admin',
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      debugPrint("Admin auto-login and role sync successful");
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      // If the user doesn't exist or credential is invalid, attempt to create the account (Self-Healing)
      if (errorStr.contains('user-not-found') || errorStr.contains('invalid-credential')) {
        try {
          debugPrint("Admin account not found. Attempting auto-creation...");
          final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          
          // Tag this user as an admin in Firestore
          await _firestore.collection('users').doc(credential.user?.uid).set({
            'uid': credential.user?.uid,
            'email': adminEmail,
            'name': "System Admin",
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          debugPrint("Admin account auto-created and tagged as admin");
          if (mounted) setState(() => _loginError = null);
        } catch (innerE) {
          debugPrint("Admin account auto-creation failed: $innerE");
          if (mounted) setState(() => _loginError = innerE.toString());
        }
      } else {
        debugPrint("Admin auto-login failed: $e");
        if (mounted) {
          setState(() {
            _loginError = e.toString();
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
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
    final isBypassMode = !_isAdminSession;

    if (_isLoggingIn) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purpleAccent),
            SizedBox(height: 20),
            Text(
              "Authenticating Admin...",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isBypassMode || _loginError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.orangeAccent.withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _loginError != null
                            ? "Authentication Failed: $_loginError"
                            : "Restricted Mode: Data access requires real Firebase Authentication.",
                        style: GoogleFonts.outfit(
                          color: Colors.orangeAccent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_loginError != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _performQuickAdminLogin,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text("Retry Login", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
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
                            onPressed: _performQuickAdminLogin,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("Try Re-Authenticating"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent.withValues(alpha: 0.2),
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
    final isBypassMode = !_isAdminSession;

    if (_isLoggingIn) {
      return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
    }

    if (isBypassMode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white10, size: 64),
              const SizedBox(height: 16),
              Text(
                "Authentication Required",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Please sign in with a valid admin account to see live status.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _performQuickAdminLogin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent.withValues(alpha: 0.1)),
                child: const Text("Admin Login"),
              ),
            ],
          ),
        ),
      );
    }

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
    final isBypassMode = !_isAdminSession;

    if (_isLoggingIn) {
      return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
    }

    if (isBypassMode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.send_time_extension_rounded, color: Colors.white10, size: 64),
              const SizedBox(height: 16),
              Text(
                "Admin Access Required",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "You must be logged in as an administrator to send global broadcasts.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _performQuickAdminLogin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent.withValues(alpha: 0.1)),
                child: const Text("Admin Login"),
              ),
            ],
          ),
        ),
      );
    }

    // Controllers are now part of the State class

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
            _titleController,
            "Notification Title (e.g. Market Alert)",
          ),
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
              onPressed: () {
                // Implementation for sending notification would go here
                // Usually via a Cloud Function call
                _sendNotification(_titleController.text, _messageController.text);
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
