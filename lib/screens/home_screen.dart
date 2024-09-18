import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/models/user.dart' as model;

import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/widgets/post_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String sortOption = 'Rating High to Low';
  String sortObject = "rating";
  bool sortOrder = true;

  double _ratingSliderValue = 5;
  double _priceSliderValue = 80;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _setSortOptions();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _setSortOptions() {
    switch (sortOption) {
      case "Rating High to Low":
        sortObject = "rating";
        sortOrder = true;
        break;
      case "Rating Low to High":
        sortObject = "rating";
        sortOrder = false;
        break;
      case "Price High to Low":
        sortObject = "price";
        sortOrder = true;
        break;
      case "Price Low to High":
        sortObject = "price";
        sortOrder = false;
        break;
      case "Likes High to Low":
        sortObject = "likes";
        sortOrder = true;
        break;
      case "Likes Low to High":
        sortObject = "likes";
        sortOrder = false;
        break;
      default:
        sortObject = "rating";
        sortOrder = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text("Rate My Bites"),
                actions: [
                  InkWell(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Sort & Filter'),
                            content: DefaultTabController(
                              length: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const TabBar(
                                    tabs: [
                                      Tab(icon: Icon(Icons.sort)),
                                      Tab(icon: Icon(Icons.filter_alt)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 300,
                                    width: 500,
                                    child: TabBarView(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 200,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child:
                                              DropdownButtonFormField<String>(
                                            value: sortOption,
                                            onChanged: (String? value) {
                                              if (value != null) {
                                                setState(() {
                                                  sortOption = value;
                                                });
                                              }
                                            },
                                            items: [
                                              'Rating High to Low',
                                              'Rating Low to High',
                                              'Price High to Low',
                                              'Price Low to High',
                                              'Likes High to Low',
                                              'Likes Low to High'
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return Container(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Rating'),
                                                  Slider(
                                                    value: _ratingSliderValue,
                                                    min: 1,
                                                    max: 5,
                                                    divisions: 4,
                                                    label: _ratingSliderValue
                                                        .round()
                                                        .toString(),
                                                    onChanged: (double value) {
                                                      setState(() {
                                                        _ratingSliderValue =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                  const Text("Price"),
                                                  Slider(
                                                    value: _priceSliderValue,
                                                    max: 100,
                                                    divisions: 10,
                                                    label: _priceSliderValue
                                                        .round()
                                                        .toString(),
                                                    onChanged: (double value) {
                                                      setState(() {
                                                        _priceSliderValue =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _setSortOptions();
                                  });
                                },
                                child: const Text('Apply'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.more_vert),
                  )
                ],
                pinned: true,
                floating: true,
                snap: true,
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Explore"),
                    Tab(text: "Following"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildExploreContent(),
              _buildFollowingContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreContent() {
    return CustomScrollView(
      slivers: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Posts')
              .where('rating', isLessThanOrEqualTo: _ratingSliderValue)
              .where('price', isLessThanOrEqualTo: _priceSliderValue)
              .orderBy(sortObject, descending: sortOrder)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const SliverToBoxAdapter(
            //     child: Center(
            //       child: CircularProgressIndicator(),
            //     ),
            //   );
            // }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Text("No data available"),
                ),
              );
            }

            final documents = snapshot.data!.docs;

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(snap: documents[index].data()),
                childCount: documents.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFollowingContent() {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    return CustomScrollView(
      slivers: [
        StreamBuilder(
          stream: user.following.isNotEmpty
              ? FirebaseFirestore.instance
                  .collection('Posts')
                  .where('userID', whereIn: user.following)
                  .where('rating', isLessThanOrEqualTo: _ratingSliderValue)
                  .where('price', isLessThanOrEqualTo: _priceSliderValue)
                  .orderBy(sortObject, descending: sortOrder)
                  .snapshots()
              : null,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const SliverToBoxAdapter(
            //     child: Center(
            //       child: CircularProgressIndicator(),
            //     ),
            //   );
            // }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Text("No data available"),
                ),
              );
            }

            final documents = snapshot.data!.docs;

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(snap: documents[index].data()),
                childCount: documents.length,
              ),
            );
          },
        ),
      ],
    );
  }
}
