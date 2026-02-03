import 'package:emu_infodam/features/comments/comments_controller.dart';
import 'package:emu_infodam/features/comments/comments_repository.dart';
import 'package:emu_infodam/models/comment.dart';
import 'package:emu_infodam/ui/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';
import '../models/person.dart';

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

  //TODO figure out cheepest way to do this
  void _populateOnFirstShow() {
    final list = ref.read(articleCommentsProvider(widget.article.articleId)).value ?? [];
    setState(() {
      _listOfComments = list;
      for (final comment in _listOfComments!) {
        if (comment.commentId == widget.person.uid) {
          _likedCommentId = comment.commentId;
          break;
        }
        if (comment.agreement.contains(widget.person.uid)) {
          _likedCommentId = comment.commentId;
          _originalLikedCommentId = comment.commentId;
          break;
        }
      }
    });
  }
@override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (_likedCommentId != _originalLikedCommentId) {
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
        appBar: AppBar(
          actions: _showingComments
              ? [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showingComments = !_showingComments;
                      });
                    },
                    icon: const Icon(Icons.document_scanner),
                  ),
                ]
              : null,
          title: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text("This is the author"),
                  children: [ElevatedButton(onPressed: Navigator.of(context).pop, child: const Text('ok'))],
                ),
              );
            },
            child: Text(widget.article.authorAlias),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Flexible(
                  flex: _showingComments ? 8 : 8,
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
                        flex: 3,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_listOfComments == null) {
                                _populateOnFirstShow();
                              }
                              setState(() {
                                _showingComments = !_showingComments;
                              });
                            },
                            child: const Text("show comments"),
                          ),
                        ),
                      )
                    : Flexible(flex: 6, child: Column(children: [],)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }
}
