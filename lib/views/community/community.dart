import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../auth/login_registerwidget.dart';
import '../../auth/registerpage.dart';
import '../../main.dart';
import '../main_page.dart';
import 'add_post.dart';
import 'comments.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  // Define green color constants
  final Color primaryGreen = Color(0xFF2E7D32); // Dark green
  final Color lightGreen = Color(0xFFE8F5E9); // Light green background
  final Color mediumGreen = Color(0xFF81C784); // Medium green for accents

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showFab) {
          setState(() {
            _showFab = false;
          });
        }
      }
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showFab) {
          setState(() {
            _showFab = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
        backgroundColor: lightGreen.withOpacity(0.3),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Community Forum",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryGreen,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Search feature coming soon!"),
                      backgroundColor: primaryGreen,
                    )
                );
              },
            ),
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Text(
                    user.displayName?.isNotEmpty == true
                        ? user.displayName![0].toUpperCase()
                        : "U",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
              ),
            if (user != null)
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthWrapper(defaultHome: main_page()),
                    ),
                  );
                },
              ),
          ],
        ),
        body: Stack(
            children: [
            RefreshIndicator(
            onRefresh: () async {
    await Future.delayed(Duration(milliseconds: 1500));
    setState(() {});
    },
        color: primaryGreen,
        child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
    child: CircularProgressIndicator(
    color: primaryGreen,
    ),
    );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.forum_outlined,
    size: 80,
    color: primaryGreen.withOpacity(0.5),
    ),
    SizedBox(height: 16),
    Text(
    "No posts yet",
    style: TextStyle(
    fontSize: 18,
    color: primaryGreen,
    fontWeight: FontWeight.w500,
    ),
    ),
    SizedBox(height: 8),
    Text(
    "Be the first to start a discussion!",
    style: TextStyle(
    color: Colors.grey[600],
    ),
    ),
    SizedBox(height: 24),
    ElevatedButton.icon(
    onPressed: () {
    if (user != null) {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AddPostPage()),
    );
    } else {
    showDialog(
    context: context,
    builder: (context) => AuthPopup(
    onRegisterPressed: () {
    Navigator.pop(context);
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => RegisterPage()),
    );
    },
    ),
    );
    }
    },
    icon: Icon(Icons.add),
    label: Text("Create Post"),
    style: ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    ),
    ],
    ),
    );
    }

    return ListView.builder(
    controller: _scrollController,
    padding: EdgeInsets.only(
    top: 12,
    bottom: 100,
    left: 12,
    right: 12,
    ),
    itemCount: snapshot.data!.docs.length,
    itemBuilder: (context, index) {
    var doc = snapshot.data!.docs[index];
    var data = doc.data() as Map<String, dynamic>;

    String timeAgo = '';
    if (data['timestamp'] != null) {
    DateTime postTime = (data['timestamp'] as Timestamp).toDate();
    timeAgo = timeago.format(postTime);
    }

    return Card(
    margin: EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: primaryGreen.withOpacity(0.2), width: 1),
    ),
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.1),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Post header with author info
    Container(
    decoration: BoxDecoration(
    color: lightGreen.withOpacity(0.5),
    borderRadius: BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
    ),
    ),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
    children: [
    CircleAvatar(
    radius: 20,
    backgroundColor: primaryGreen.withOpacity(0.2),
    child: Icon(
    Icons.person,
    color: primaryGreen,
    ),
    ),
    SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    data['user_name'] ?? 'Anonymous',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: primaryGreen,
    ),
    ),
    Row(
    children: [
    Text(
    timeAgo,
    style: TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    ),
    ),
    if (data['location'] != null && data['location'].isNotEmpty)
    Row(
    children: [
    Text(
    " • ",
    style: TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    ),
    ),
    Icon(
    Icons.location_on,
    size: 12,
    color: Colors.grey[600],
    ),
    Text(
    data['location'],
    style: TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    ),
    ),
    ],
    ),
    ],
    ),
    ],
    ),
    ),
    ],
    ),
    ),

    // Post content
    Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    data['question'] ?? '',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: Colors.black87,
    ),
    ),
    SizedBox(height: 8),
    Text(
    data['description'] ?? '',
    style: TextStyle(
    fontSize: 15,
    height: 1.4,
    color: Colors.grey[800],
    ),
    ),
    ],
    ),
    ),

    // Post image
    if (data['image_url'] != null && data['image_url'].isNotEmpty)
    Container(
    decoration: BoxDecoration(
    border: Border(
    top: BorderSide(color: Colors.grey.withOpacity(0.2)),
    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
    ),
    ),
    child: GestureDetector(
    onTap: () {
    // Show full image
    },
    child: Hero(
    tag: 'post_image_${doc.id}',
    child: CachedNetworkImage(
    imageUrl: data['image_url'],
    width: double.infinity,
    height: 220,
    fit: BoxFit.cover,
    placeholder: (context, url) => Container(
    height: 220,
    color: Colors.grey[300],
    child: Center(
    child: CircularProgressIndicator(
    strokeWidth: 2,
    color: primaryGreen,
    ),
    ),
    ),
    errorWidget: (context, url, error) => Container(
    height: 220,
    color: Colors.grey[200],
    child: Center(
    child: Icon(
    Icons.error_outline,
    color: Colors.grey[400],
    size: 40,
    ),
    ),
    ),
    ),
    ),
    ),
    ),

    // Post actions
    Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
    // Like button
    TextButton.icon(
    onPressed: () {
    _likePost(context, doc.id, data['likes'] ?? 0);
    },
    icon: Icon(
    Icons.thumb_up_alt_outlined,
    color: primaryGreen,
    size: 20,
    ),
    label: Text(
    "${data['likes'] ?? 0}",
    style: TextStyle(
    color: primaryGreen,
    fontWeight: FontWeight.bold,
    ),
    ),
    style: TextButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    ),
    ),
    ),

    // Comment button
    StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('community_posts')
        .doc(doc.id)
        .collection('comments')
        .snapshots(),
    builder: (context, commentSnapshot) {
    int commentCount = commentSnapshot.data?.docs.length ?? 0;
    return TextButton.icon(
    onPressed: () {
    _showCommentsSheet(
    context,
    doc.id,
    data['question'],
    data['description'],
    data['image_url']
    );
    },
    icon: Icon(
    Icons.chat_bubble_outline,
    color: primaryGreen,
    size: 20,
    ),
    label: Text(
    "$commentCount",
    style: TextStyle(
    color: primaryGreen,
    fontWeight: FontWeight.bold,
    ),
    ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
    },
    ),

      // Share button
      TextButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Sharing coming soon!"),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        icon: Icon(
          Icons.share_outlined,
          color: primaryGreen,
          size: 20,
        ),
        label: Text(
          "Share",
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ],
    ),
    ),
    ],
    ),
    );
    },
    );
    },
        ),
            ),

              // Floating Action Button
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: 16,
                bottom: _showFab ? 16 : -70, // Hide below the screen when not visible
                child: user == null
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Sign in to post",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    FloatingActionButton.extended(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AuthPopup(
                            onRegisterPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterPage()),
                              );
                            },
                          ),
                        );
                      },
                      icon: Icon(Icons.login),
                      label: Text("Sign In"),
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                  ],
                )
                    : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPostPage()),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text("New Post"),
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 4,
                ),
              ),
            ],
        ),
      bottomSheet: user == null ? _buildLoginPrompt(context) : null,
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: primaryGreen.withOpacity(0.7),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Sign in to like posts and join the conversation",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AuthPopup(
                  onRegisterPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text("Sign In"),
          ),
        ],
      ),
    );
  }

  void _likePost(BuildContext context, String postId, int currentLikes) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Show a more attractive auth dialog
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: primaryGreen,
                ),
                SizedBox(height: 16),
                Text(
                  "Authentication Required",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "You need to be signed in to like posts.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AuthPopup(
                            onRegisterPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterPage()),
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Sign In"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text("Processing..."),
          ],
        ),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Check if the user has already liked the post
    FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        // User has already liked the post
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You've already liked this post"),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        // User has not liked the post yet, add the like
        FirebaseFirestore.instance
            .collection('community_posts')
            .doc(postId)
            .collection('likes')
            .doc(user.uid)
            .set({
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonymous',
        }).then((_) {
          // Update the total likes count
          FirebaseFirestore.instance
              .collection('community_posts')
              .doc(postId)
              .update({'likes': currentLikes + 1}).then((_) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Post liked!"),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
        });
      }
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${error.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  void _showCommentsSheet(BuildContext context, String postId, String question, String description, String? imageUrl) {
    // Add a nice transition to the comments page
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CommentSection(
          postId: postId,
          question: question,
          description: description,
          imageUrl: imageUrl,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}

