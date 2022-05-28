import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:marvel_challenge/screens/detail.dart';
import 'package:marvel_challenge/services/characters.dart';
import 'package:marvel_challenge/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _charactersList = [];
  List<dynamic> firstList = [];
  List<dynamic> secondList = [];
  bool isLoaded = false;
  ScrollController? controller;
  int pageNo = 0;
  int offset = 0;
  bool isNewPage = true;

  @override
  void initState() {
    super.initState();
    _charactersList = List.empty(growable: true);
    firstList = List.empty(growable: true);
    secondList = List.empty(growable: true);
    controller = ScrollController()..addListener(_scrollListener);
    getCharacters(offset);
  }

  getCharacters(int offset) async {
    var response = await CharactersService.charactersList(offset);

    if (response != null && response['code'] == 200) {
      firstList.clear();
      firstList = response['data']['results'];
      _charactersList = _charactersList + firstList;
      isLoaded = true;
      isNewPage = true;
      setState(() {
        pageNo++;
      });
    }
  }

  void _scrollListener() {
    final maxScroll = controller!.position.maxScrollExtent;
    final currentScroll = controller!.position.pixels;

    if (maxScroll - currentScroll <= 0 &&
        controller!.position.outOfRange &&
        isNewPage) {
      setState(() {
        isNewPage = false;

        offset = offset + 30;
        getCharacters(offset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: CustomTheme.black.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: CustomTheme.mainColor,
          elevation: 0,
          title: Image.asset(
            'assets/img/logo.png',
            fit: BoxFit.fitWidth,
            height: MediaQuery.of(context).size.height * 0.06,
          ),
          centerTitle: true,
        ),
        body: isLoaded
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.count(
                          physics: BouncingScrollPhysics(),
                          controller: controller,
                          crossAxisCount: 2,
                          childAspectRatio: 1 / 1,
                          shrinkWrap: false,
                          children:
                              List.generate(_charactersList.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    transitionDuration:
                                        Duration(milliseconds: 1000),
                                    pageBuilder: (BuildContext context,
                                        Animation<double> animation,
                                        Animation<double> secondaryAnimation) {
                                      return CharacterDetail(
                                        uniqueId: _charactersList[index]['id'],
                                        text: _charactersList[index]['name'],
                                        imageUrl: _charactersList[index]
                                                ['thumbnail']['path'] +
                                            '.' +
                                            _charactersList[index]['thumbnail']
                                                ['extension'],
                                      );
                                    },
                                    transitionsBuilder: (BuildContext context,
                                        Animation<double> animation,
                                        Animation<double> secondaryAnimation,
                                        Widget child) {
                                      return Align(
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(
                                        15,
                                      ),
                                      topRight: Radius.circular(
                                        15,
                                      ),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        _charactersList[index]['thumbnail']
                                                ['path'] +
                                            '.' +
                                            _charactersList[index]['thumbnail']
                                                ['extension'],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: ClipRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 10.0, sigmaY: 10.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                _charactersList[index]['name'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: CustomTheme.white,
                                                    shadows: <Shadow>[
                                                      Shadow(
                                                        offset:
                                                            Offset(2.0, 1.0),
                                                        blurRadius: 8.0,
                                                        color:
                                                            CustomTheme.black,
                                                      ),
                                                    ]),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            );
                          }),
                        ),
                      ),
                      Visibility(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: CircularProgressIndicator(
                              color: CustomTheme.mainColor,
                            ),
                          ),
                          visible: !isNewPage),
                    ],
                  ),
                ),
              )
            : Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Image.asset("assets/img/loader.gif"),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          backgroundColor: CustomTheme.mainColor,
          child: Text("P.${pageNo}"),
        ),
      ),
    );
  }
}
