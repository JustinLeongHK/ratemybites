import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String sortOption = 'Rating High to Low';
  String sortObject = "rating";
  bool sortOrder = true;

  @override
  void initState() {
    super.initState();
    // Initialize sorting logic
    _setSortOptions();
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

  double _ratingSliderValue = 5;
  double _priceSliderValue = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                            child: Scaffold(
                              appBar: const TabBar(tabs: [
                                Tab(icon: Icon(Icons.sort)),
                                Tab(icon: Icon(Icons.filter_alt)),
                              ]),
                              body: TabBarView(children: [
                                Container(
                                  width: 200, // Adjust the width as needed
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: DropdownButtonFormField<String>(
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
                                                _ratingSliderValue = value;
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
                                                _priceSliderValue = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ]),
                            ),
                          ),
                          actions: [
                            // Cancel button
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            // Apply button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _setSortOptions();
                                });
                                print(_ratingSliderValue);
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
              pinned: false,
              floating: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Posts')
                        .where('rating',
                            isLessThanOrEqualTo: _ratingSliderValue)
                        .where('price', isLessThanOrEqualTo: _priceSliderValue)
                        .orderBy(sortObject, descending: sortOrder)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No data available"),
                        );
                      }

                      final documents = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: documents.length,
                        itemBuilder: (context, index) =>
                            PostCard(snap: documents[index].data()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
