import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marvel_challenge/services/characters.dart';
import 'package:marvel_challenge/utils/colors.dart';

class CharacterDetail extends StatefulWidget {
  final int uniqueId;
  final String text;
  final String imageUrl;

  const CharacterDetail(
      {Key? key,
      required this.uniqueId,
      required this.text,
      required this.imageUrl})
      : super(key: key);

  @override
  State<CharacterDetail> createState() => _CharacterDetailState();
}

class _CharacterDetailState extends State<CharacterDetail> {
  bool isLoaded = false;
  dynamic characterDetail;
  List<dynamic> characterComics = [];
  String image = "";

  @override
  void initState() {
    super.initState();
    characterComics = List.empty(growable: true);
    getData();
  }

  getData() async {
    var response = await CharactersService.getCharacterById(widget.uniqueId);

    if (response != null && response['code'] == 200) {
      characterDetail = response['data']['results'][0];

      var comicResponse =
          await CharactersService.characterComics(widget.uniqueId);

      if (comicResponse != null && comicResponse['code'] == 200) {
        DateTime year = DateTime.parse('2005-01-01 00:01:00Z');
        int leng = comicResponse['data']['results'].length;

        for (int i = 0; i < leng; i++) {
          bool isAfter = year.isBefore(DateTime.parse(
              comicResponse['data']['results'][i]['dates'][0]['date']));
          if (isAfter) {
            characterComics.add(comicResponse['data']['results'][i]);
          }
        }
        if (characterComics.length > 9) {
          characterComics = characterComics.sublist(0, 10);
        }
        setState(() {
          isLoaded = true;
        });
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.4,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          blurRadius: 15.0,
                        ),
                      ]),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      )),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: GestureDetector(
                    onTap: () {
                      BigImage.showAlertDialog(
                        context,
                        widget.imageUrl,
                      );
                    },
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
          ];
        },
        body: isLoaded
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: const Divider(
                        thickness: 2,
                        color: CustomTheme.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        characterDetail["description"] != ""
                            ? characterDetail["description"]
                            : "There is no description!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    characterComics.isNotEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ScrollConfiguration(
                                behavior: const ScrollBehavior()
                                    .copyWith(overscroll: false),
                                child: ListView.builder(
                                    itemCount: characterComics.length > 9
                                        ? 10
                                        : characterComics.length,
                                    shrinkWrap: false,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          BigImage.showAlertDialog(
                                            context,
                                            characterComics[index]['thumbnail']
                                                    ['path'] +
                                                '.' +
                                                characterComics[index]
                                                    ['thumbnail']['extension'],
                                          );
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(
                                                  15,
                                                ),
                                                topRight: Radius.circular(
                                                  15,
                                                ),
                                              ),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  characterComics[index]
                                                              ['thumbnail']
                                                          ['path'] +
                                                      '.' +
                                                      characterComics[index]
                                                              ['thumbnail']
                                                          ['extension'],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              child: Banner(
                                                message: DateFormat(
                                                        'dd-MM-yyyy')
                                                    .format(DateTime.parse(
                                                        characterComics[index]
                                                                ["dates"][0]
                                                            ["date"])),
                                                location: BannerLocation.topEnd,
                                                color: CustomTheme.mainColor,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      height: 45,
                                                      width: double.infinity,
                                                      child: ClipRect(
                                                        child: BackdropFilter(
                                                          filter:
                                                              ImageFilter.blur(
                                                                  sigmaX: 10.0,
                                                                  sigmaY: 10.0),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              characterComics[
                                                                      index]
                                                                  ['title'],
                                                              style: const TextStyle(
                                                                  color:
                                                                      CustomTheme
                                                                          .white,
                                                                  shadows: <
                                                                      Shadow>[
                                                                    Shadow(
                                                                      offset: Offset(
                                                                          2.0,
                                                                          1.0),
                                                                      blurRadius:
                                                                          8.0,
                                                                      color: CustomTheme
                                                                          .black,
                                                                    ),
                                                                  ]),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )),
                                      );
                                    }),
                              ),
                            ),
                          )
                        : const Text(
                            "There is no comics!",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              )
            : Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset("assets/img/loader.gif"),
                ),
              ),
      ),
    );
  }
}

class BigImage {
  static showAlertDialog(
    BuildContext context,
    String image,
  ) {
    AlertDialog customLoader = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      contentPadding: EdgeInsets.all(0),
      title: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: CustomTheme.mainColor,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
        ),
        child: const Icon(
          Icons.close,
          // size: 50,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      content: Image.network(
        image,
        fit: BoxFit.cover,
      ),
      actionsAlignment: MainAxisAlignment.center,
    );

    // show the dialog
    showDialog(
      useSafeArea: true,
      barrierColor: Colors.black54,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: customLoader);
      },
    );
  }
}
