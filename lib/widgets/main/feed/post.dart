import 'package:didula_api/models/postmodel.dart';
import 'package:didula_api/services/feed/feedservices.dart';
import 'package:didula_api/utils/function.dart';
import 'package:didula_api/utils/moods.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostWidget extends StatefulWidget {
  final PostModel post; // ඔබේ PostModel එක
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String CurrentUserId;

  const PostWidget({
    super.key,
    required this.post,
    required this.onEdit,
    required this.onDelete,
    required this.CurrentUserId,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;

  Future<void> _checkIfUserLiked() async {
    final hasLiked = await Feedservices().hasUserLikedPost(
      postId: widget.post.postId,
      userId: widget.CurrentUserId,
    );
    setState(() {
      _isLiked = hasLiked;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkIfUserLiked();
  }

  void _likeOrDisLikePost() async {
    try {
      if (_isLiked) {
        await Feedservices().disLikePost(
          postId: widget.post.postId,
          userId: widget.CurrentUserId,
        );
        setState(() {
          _isLiked = false;
        });
      } else {
        await Feedservices().likePost(
          postId: widget.post.postId,
          userId: widget.CurrentUserId,
        );
        setState(() {
          _isLiked = true;
        });
      }
    } catch (e) {
      UtileFunctions().showSnackBar(context, "Fail to like or unlike");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatedDate = DateFormat(
      "dd-MM-yyyy HH:mm",
    ).format(widget.post.datePublished);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), // Glass Look එක
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    widget.post.profileImage.isEmpty
                        ? "https://ui-avatars.com/api/?name=User&background=random&color=fff&size=256"
                        : widget.post.profileImage,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formatedDate,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (widget.post.userId == widget.CurrentUserId)
                  IconButton(
                    onPressed: () => _showOptionsDialog(context),
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            // Mood Chip
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                "Feeling ${widget.post.mood.name} ${widget.post.mood.Emogi}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.post.postCaption,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            // Image
            if (widget.post.postUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  widget.post.postUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              ),
            const SizedBox(height: 12),
            // Like Row
            Row(
              children: [
                IconButton(
                  onPressed: _likeOrDisLikePost,
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                  ),
                ),
                Text(
                  "${widget.post.like} likes",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          children: [
            _buildDialogOptions(
              icon: Icons.delete,
              text: "Delete",
              onTap: () {
                widget.onDelete();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOptions({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
