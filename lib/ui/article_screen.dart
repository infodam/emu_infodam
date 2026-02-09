import 'package:emu_infodam/features/colour_changer.dart';
import 'package:emu_infodam/features/comments/comments_controller.dart';
import 'package:emu_infodam/features/comments/comments_repository.dart';
import 'package:emu_infodam/models/article.dart';
import 'package:emu_infodam/models/person.dart';
import 'package:emu_infodam/ui/custom_widgets.dart';
import 'package:emu_infodam/utility/text_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment.dart';
import '../utility/show_messages.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  final Article article;
  final Person person;
  const ArticleScreen(this.article, this.person, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  final _commentController = TextEditingController();
  String? _originalLikedCommentId;
  String? _likedCommentId;
  bool _showingComments = false;
  List<Comment>? _listOfComments;

  @override
  void initState() {
    super.initState();
    _getUserComment();
  }

  void _getUserComment() async {
    await ref.read(commentsControllerProvider(widget.article.articleId)).getUserComment().then((comment) {
      if (comment != "") {
        _commentController.text = comment;
      }
    });
  }

  Future<void> _populateList() async {
    final isFirstTime = _listOfComments == null;

    await ref.read(commentsRepositoryProvider(widget.article.articleId)).getArticleComments().first.then((value) {
      setState(() {
        _listOfComments = value;
        if (isFirstTime) {
          for (final comment in _listOfComments!) {
            if (comment.agreement.contains(widget.person.uid)) {
              _likedCommentId = comment.commentId;
              _originalLikedCommentId = comment.commentId;
              break;
            }
          }
        }
      });
    });
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        constraints: BoxConstraints(maxHeight: 240),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("limit one comment per article"),
                TextField(controller: _commentController, maxLength: 140, textAlign: TextAlign.center),
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(onPressed: Navigator.of(context).pop, child: const Text('cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (_commentController.text.trim() == "") {
                          ref.read(commentsControllerProvider(widget.article.articleId)).deleteComment(widget.person.uid);
                          setState(() {
                            _likedCommentId = null;
                            _populateList();
                          });
                          Navigator.pop(context);
                        } else if (isValidTextValue(_commentController)) {
                          ref
                              .read(commentsControllerProvider(widget.article.articleId))
                              .addComment(context, validTextValueReturner(_commentController));
                          _populateList();
                          setState(() {
                            _likedCommentId = widget.person.uid;
                          });

                          Navigator.pop(context);
                        } else {
                          showSnackyBar(context, 'invalid input');
                        }
                      },
                      child: const Text('comment'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //TODO delete comments at zero
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (_likedCommentId == _originalLikedCommentId) {
          //Do nothing
        } else {
          final commentController = ref.read(commentsControllerProvider(widget.article.articleId));
          if (_originalLikedCommentId != null) {
            commentController.unAgree(_originalLikedCommentId!, widget.person.uid);
          }
          if (_likedCommentId != null) {
            commentController.agree(_likedCommentId!, widget.person.uid);
          }
        }
      },
      child: Scaffold(
        // floatingActionButton: _showingComments ? FloatingActionButton(onPressed: _showCommentDialog, child: const Icon(Icons.edit_square)) : null,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.article.authorAlias),
          actions: _showingComments ? [GestureDetector(onTap: _showCommentDialog, child: const Text('comment'))] : null,
        ),
        body: Column(
          children: [
            Flexible(
              flex: _showingComments ? 6 : 8,
              child: Column(
                children: [
                  ArticleStyles.titleText(widget.article.title),
                  const Divider(indent: 60, endIndent: 60),
                  if (widget.article.url != null) ArticleStyles.urlButton(widget.article.url!, context),
                  const Divider(indent: 60, endIndent: 60),
                  if (widget.article.content != null)
                    Expanded(child: SingleChildScrollView(child: ArticleStyles.contentText(widget.article.content!))),
                ],
              ),
            ),
            !_showingComments
                ? Flexible(
                    flex: 2,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _populateList().then((value) {
                            setState(() {
                              _showingComments = !_showingComments;
                            });
                          });
                        },
                        child: const Text("show comments"),
                      ),
                    ),
                  )
                : Flexible(
                    flex: 6,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _showingComments = !_showingComments;
                            },
                            child: const Text('hide comments'),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _listOfComments!.length,
                            itemBuilder: (context, index) {
                              final comment = _listOfComments![index];
                              return _commentTile(comment);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _commentTile(Comment comment) {
    if (_likedCommentId == comment.commentId) {
      return _basicTile(comment, true);
    } else {
      return _basicTile(comment, false);
    }
  }

  Widget _basicTile(Comment comment, bool isLiked) {
    return ListTile(
      trailing: widget.person.uid == comment.commentId ? Text('agreement: ${comment.scoreStr}') : null,
      tileColor: isLiked ? ref.watch(colorChangerProvider).goodColor.withAlpha(100) : null,
      title: Center(child: Text(comment.commentText)),
      subtitle: Center(child: Text(comment.authorAlias)),
      onTap: isLiked
          ? () {
              setState(() {
                _likedCommentId = null;
              });
            }
          : () {
              setState(() {
                _likedCommentId = comment.commentId;
              });
            },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }
}
