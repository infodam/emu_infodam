import 'package:emu_infodam/models/article.dart';
import 'package:emu_infodam/models/person.dart';
import 'package:emu_infodam/ui/article_screen.dart';
import 'package:emu_infodam/ui/create_article_screen.dart';
import 'package:emu_infodam/ui/info_page.dart';
import 'package:flutter/material.dart';

class GoTo {
  static infoScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InfoPage()));
  }

  static createPostScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateArticleScreen("RiffRaff")));
  }

  static articleScreen(BuildContext context, Article article, Person person, Function? unlockVoting) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ArticleScreen(article, person))).then((value) {
      if (unlockVoting != null) {
        unlockVoting(article.articleId);
      }
    });
  }


  // static chooseColorPage(BuildContext context) {
  //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ColoursPage()));
  // }
}
