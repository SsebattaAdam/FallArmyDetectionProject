import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentSection extends StatefulWidget {
  final String postId;
  final String question;
  final String description;
  final String? imageUrl;

  const CommentSection({
    super.key,
    required this.postId,
    required this.question,
    required this.description,
    this.imageUrl,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // Define green color constants
  final Color primaryGreen = Color(0xFF2E7D32); // Dark green
  final Color lightGreen = Color(0xFFE8F5E9); // Light green background
  final Color mediumGreen = Color(0xFF81C784); // Medium green for accents

  void _addComment() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a comment"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    String commentText = _commentController.text.trim();
    String username = user?.displayName ?? "Anonymous";

    FirebaseFirestore.instance
        .collection('community_posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'text': commentText,
      'username': username,
      'userId': user?.uid,
      'userPhotoUrl': user?.photoURL,
      'timestamp': FieldValue.serverTimestamp(),
    })
        .then((_) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("Comment added successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add comment: $error"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
        backgroundColor: lightGreen.withOpacity(0.3),
        appBar: AppBar(
          title: Text(
            "Post & Comments",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // Use resizeToAvoidBottomInset to prevent overflow
        resizeToAvoidBottomInset: true,
        // Use a SingleChildScrollView as the main container
        body: SafeArea(
          child: Column(
              children: [
          // Make the main content scrollable
          Expanded(
          child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
              children: [
          // Post details card
          Card(
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: primaryGreen.withOpacity(0.2), width: 1),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header
              Container(
                decoration: BoxDecoration(
                  color: lightGreen.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.question_answer,
                      color: primaryGreen,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Discussion",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Post content
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Post image
              if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      widget.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              color: primaryGreen,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Comments header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.comment,
                color: primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Comments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              SizedBox(width: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Comments list
        StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('community_posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Container(
    height: 200,
    child: Center(
    child: CircularProgressIndicator(
    color: primaryGreen,
    ),
    ),
    );
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Container(
    height: 200,
    child: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.chat_bubble_outline,
    size: 64,
    color: primaryGreen.withOpacity(0.3),
    ),
    SizedBox(height: 16),
    Text(
    "No comments yet",
    style: TextStyle(
    fontSize: 16,
    color: Colors.grey[600],
    ),
    ),
    SizedBox(height: 8),
    Text(
    "Be the first to comment!",
    style: TextStyle(
    fontSize: 14,
    color: Colors.grey[500],
    ),
    ),
    ],
    ),
    ),
    );
    }

    // Use a non-scrollable ListView inside the SingleChildScrollView
    return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16),
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: snapshot.data!.docs.length,
    itemBuilder: (context, index) {
    var doc = snapshot.data!.docs[index];
    var data = doc.data() as Map<String, dynamic>;
    bool isCurrentUserComment = user != null &&
    data['userId'] == user.uid;

    String timeAgo = '';
    if (data['timestamp'] != null) {
    DateTime commentTime = (data['timestamp'] as Timestamp).toDate();
    timeAgo = timeago.format(commentTime);
    }

    return Container(
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
    color: isCurrentUserComment
    ? lightGreen.withOpacity(0.5)
        : Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 3,
    offset: Offset(0, 1),
    ),
    ],
    ),
    child: Padding(
    padding: EdgeInsets.all(12),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    CircleAvatar(
    radius: 16,
    backgroundColor: primaryGreen.withOpacity(0.2),
    backgroundImage: data['userPhotoUrl'] != null
    ? NetworkImage(data['userPhotoUrl'])
        : null,
    child: data['userPhotoUrl'] == null
    ? Text(
    data['username'] != null
    ? data['username'][0].toUpperCase()
        : "A",
    style: TextStyle(
    color: primaryGreen,
    fontWeight: FontWeight.bold,
    ),
    )
        : null,
    ),
    SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Text(
    data['username'] ?? "Anonymous",
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: primaryGreen,
    ),
    ),
    Spacer(),
    Text(
    timeAgo,
    style: TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    fontStyle: FontStyle.italic,
    ),
    ),
    ],
    ),
    SizedBox(height: 6),
    Text(
      data['text'] ?? "",
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[800],
      ),
    ),
    ],
    ),
    ),
    ],
    ),

      // Delete option for user's own comments
      if (isCurrentUserComment)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete Comment"),
                  content: Text("Are you sure you want to delete this comment?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        FirebaseFirestore.instance
                            .collection('community_posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .doc(doc.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Comment deleted"),
                            backgroundColor: Colors.red[400],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(
              Icons.delete_outline,
              size: 16,
              color: Colors.red[400],
            ),
            label: Text(
              "Delete",
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 12,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size(0, 30),
            ),
          ),
        ),
    ],
    ),
    ),
    );
    },
    );
    },
        ),
                // Add padding at the bottom to ensure content isn't hidden behind the input field
                SizedBox(height: 80),
              ],
          ),
          ),
          ),

                // Comment input field - fixed at the bottom
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: Offset(0, -2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryGreen.withOpacity(0.2),
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Icon(
                          Icons.person,
                          color: primaryGreen,
                          size: 18,
                        )
                            : null,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Material(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(50),
                        child: InkWell(
                          onTap: _isSubmitting ? null : _addComment,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: _isSubmitting
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ),
        ),
    );
  }
}
