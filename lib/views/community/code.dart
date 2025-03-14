import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'add_post.dart';
import 'comments.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community")),
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('community_posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No posts yet"));
              }
              return ListView(
                padding: const EdgeInsets.only(bottom: 80), // To prevent FAB from overlapping posts
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['question'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(data['description']),
                          const SizedBox(height: 8),
                          if (data['image_url'] != null && data['image_url'].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['image_url'],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up_alt_outlined),
                                    onPressed: () {
                                      _likePost(doc.id, data['likes'] ?? 0);
                                    },
                                  ),
                                  Text("${data['likes'] ?? 0}"),
                                ],
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('community_posts')
                                    .doc(doc.id)
                                    .collection('comments')
                                    .snapshots(),
                                builder: (context, commentSnapshot) {
                                  int commentCount = commentSnapshot.data?.docs.length ?? 0;
                                  return TextButton(
                                    onPressed: () {
                                      _showCommentsSheet(context, doc.id, data['question'], data['description'], data['image_url']);
                                    },
                                    child: Text("Comments ($commentCount)"),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70, right: 16), // Adjust for bottom nav bar
              child: FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPostPage()),
                ),
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _likePost(String postId, int currentLikes) {
    FirebaseFirestore.instance
        .collection('community_posts')
        .doc(postId)
        .update({'likes': currentLikes + 1});
  }
  void _showCommentsSheet(BuildContext context, String postId, String question, String description, String? imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentSection(
          postId: postId,
          question: question,
          description: description,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

}
