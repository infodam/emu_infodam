import 'package:emu_infodam/features/articles/articles_controller.dart';
import 'package:emu_infodam/features/auth/auth_controller.dart';
import 'package:emu_infodam/models/article.dart';
import 'package:emu_infodam/models/person.dart';
import 'package:emu_infodam/navigation.dart';
import 'package:emu_infodam/utility/error_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Color good = Colors.green;
Color bad = Colors.yellow; 

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Person _person;
  final List<String> _articlesViewed = [];
  void _unlockVoting(String articleId) {
    setState(() {
      _articlesViewed.add(articleId);
    });
  }

  @override
  void initState() {
    super.initState();
    _person = ref.read(personProvider)!;
    // colours = ref.read(colorChangerProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "info") {
                  GoTo.infoScreen(context);
                }
                if (value == "color") {
                  // GoTo.chooseColorPage(context);
                }
                if (value == "out") {
                  ref.read(authControllerProvider.notifier).signOut(context);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(value: "info", child: const Text('Info')),
                  PopupMenuItem(value: "color", child: const Text('Choose Colors')),
                  PopupMenuItem(value: "out", child: const Text('logOut(4testing)')),
                ];
              },
              child: const Icon(Icons.menu),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: GestureDetector(onTap: () => GoTo.createPostScreen(context), child: const Text("create")),
            ),
          ),
        ],
        centerTitle: true,
        //TODO leading menu for info and stuff
        title: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text("This is your username"),
                children: [ElevatedButton(onPressed: Navigator.of(context).pop, child: const Text('ok'))],
              ),
            );
          },
          child: Text(_person.alias),
        ),
      ),
      body: ref
          .watch(articleFeedProvider)
          .when(
            data: (listOfArticles) {
              return ListView.builder(
                itemCount: listOfArticles.length,
                itemBuilder: (context, index) {
                  final article = listOfArticles[index];
                  return _articleCard(article);
                },
              );
            },
            error: (error, stackTrace) => ErrorPage(error.toString()),
            loading: () => const Loader(),
          ),
    );
  }

  Widget _articleCard(Article article) {
    if (article.authorId == _person.uid) {
      return _authoredCard(article);
    }
    if (article.agreement.contains(_person.uid)) {
      return _votedCard(article, true);
    }
    if (article.disagreement.contains(_person.uid)) {
      return _votedCard(article, false);
    }

    if (_articlesViewed.contains(article.articleId)) {
      return _basicCard(
        article,
        locked: false,
        leading: IconButton(
          onPressed: () {
            ref.read(articlesControllerProvider.notifier).disagree(article.articleId, _person.uid);
            if (article.score < 0) {
              ref.read(articlesControllerProvider.notifier).delete(article.articleId);
            }
          },
          icon: const Icon(Icons.thumb_down),
        ),
        trailing: IconButton(
          onPressed: () {
            ref.read(articlesControllerProvider.notifier).agree(article.articleId, _person.uid);
          },
          icon: const Icon(Icons.thumb_up),
        ),
      );
    }
    return _basicCard(article, locked: true);
  }

  Widget _votedCard(Article article, bool isLiked) {
    return _basicCard(
      article,
      locked: false,
      trailing: Icon(isLiked ? Icons.child_care : Icons.broken_image),
      leading: IconButton(
        onPressed: () {
          if (isLiked) {
            ref.read(articlesControllerProvider.notifier).unAgree(article.articleId, _person.uid);
            _articlesViewed.remove(article.articleId);
          } else {
            ref.read(articlesControllerProvider.notifier).unDisagree(article.articleId, _person.uid);
            _articlesViewed.remove(article.articleId);
          }
        },
        icon: const Icon(Icons.undo),
      ),
      colour: isLiked ? good : bad, 
      // colour: isLiked ? colours.goodColor.withAlpha(80) : colours.badColor.withAlpha(80),
    );
  }

  Widget _authoredCard(Article article) {
    return _basicCard(
      isFlat: true,
      article,
      colour: good,
      // colour: colours.goodColor.withAlpha(40),
      locked: false,
      leading: Column(children: [const Text("agreement"), Text(article.scoreStr)]),
    );
  }

  Widget _basicCard(Article article, {Widget? leading, Widget? trailing, Color? colour, required bool locked, bool? isFlat}) {
    return GestureDetector(
      child: Card(
        color: colour,
        elevation: isFlat != null ? 0 : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: article.url == null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceEvenly,
            children: [
              leading ?? const SizedBox(width: 24),

              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    if (article.url != null) const Icon(Icons.link, size: 18),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          Text(article.title, textAlign: TextAlign.center),
                          Text("- ${article.authorAlias} -", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              trailing ?? const SizedBox(width: 24),
            ],
          ),
        ),
      ),
      // onTap: () => GoTo.articleDetails(context, article, _person, _unlockVoting),
    );
  }
}
