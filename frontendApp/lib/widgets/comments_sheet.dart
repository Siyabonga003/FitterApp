import 'package:flutter/material.dart';
import 'package:frontend_app/theme/app_theme.dart';
import 'package:frontend_app/services/social_service.dart';
import 'package:frontend_app/utils/image_url.dart';

class CommentsSheet extends StatefulWidget {
  final String activityId;
  final VoidCallback? onCommentAdded;

  const CommentsSheet({required this.activityId, this.onCommentAdded, super.key});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  Future<List<CommentModel>>? _commentsFuture;
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _commentsFuture = ActivitySocialService.getComments(widget.activityId);
    });
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final comment = await ActivitySocialService.addComment(widget.activityId, text);
      if (comment != null) {
        _controller.clear();
        _load();
        widget.onCommentAdded?.call();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Comments', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<CommentModel>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text('Could not load comments.', style: TextStyle(color: AppTheme.textLight)),
                      );
                    }

                    final comments = snapshot.data!;
                    if (comments.isEmpty) {
                      return const Center(
                        child: Text('No comments yet. Be the first!', style: TextStyle(color: AppTheme.textLight)),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white10,
                                backgroundImage: resolveImageUrl(c.profilePicUrl) != null
                                    ? NetworkImage(resolveImageUrl(c.profilePicUrl)!)
                                    : null,
                                child: resolveImageUrl(c.profilePicUrl) == null
                                    ? Text(c.displayName.isNotEmpty ? c.displayName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 12))
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(c.displayName,
                                            style: const TextStyle(
                                                color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Text(c.timeAgo, style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(c.content, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
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
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: const TextStyle(color: AppTheme.textLight),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSubmitting
                            ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryOrange),
                        )
                            : const Icon(Icons.send_rounded, color: AppTheme.primaryOrange),
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}