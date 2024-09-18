import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/screens/bio_screen.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 50),
              child: const Center(
                child: Text(
                  "Rate My Bites",
                  style: TextStyle(fontSize: 25),
                ),
              )),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).highlightColor,
            ),
            child: const Center(
              child: Text(
                "🌟 Key Features 🌟",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          CarouselSlider(
            options: CarouselOptions(
                height: 280,
                aspectRatio: 4 / 3,
                viewportFraction: 0.8,
                autoPlay: true,
                enlargeFactor: 0.1),
            items: [
              {
                'title': 'Discover Hidden Gems',
                'desc':
                    'Explore curated lists and recommendations from fellow foodies.',
                'icon': Icons.explore
              },
              {
                'title': "Share Your Favorites",
                'desc':
                    'Spread the love for your beloved eateries and dishes with our community.',
                'icon': Icons.share
              },
              {
                'title': 'Find Your Perfect Bite',
                'desc':
                    'Filter out the noise and discover top-rated restaurants tailored to your tastes.',
                'icon': Icons.search
              },
              {
                'title': 'Connect with Food Lovers',
                'desc':
                    'Engage in lively discussions, swap tips, and connect with like-minded individuals.',
                'icon': Icons.connect_without_contact_rounded
              }
            ].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).secondaryHeaderColor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${i['title']}',
                            style: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            ' "${i['desc']} "',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 100, top: 20),
                            child: Icon(
                              i["icon"] as IconData,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Container(
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).highlightColor,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const BioScreen()));
                    },
                    icon: const Icon(Icons.navigate_next_outlined),
                    label: const Text("Continue")),
              ],
            ),
          )
        ],
      ))),
    ));
  }
}
