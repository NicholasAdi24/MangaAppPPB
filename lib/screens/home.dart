// Import yang diperlukan
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ta_ppb_nicholas/screens/detail.dart';
import 'package:ta_ppb_nicholas/screens/profile.dart'; // Sertakan import untuk profile.dart
import 'topmanga.dart'; // Sertakan import untuk topmanga.dart

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> mangaList = [];
  int offset = 0;
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData({int limit = 10}) async {
    final response = await http.get(Uri.parse(
        'https://api.mangadex.org/manga?offset=$offset&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> mangaData = data['data'] ?? [];

      setState(() {
        mangaList.addAll(List<Map<String, dynamic>>.from(mangaData));
        offset += limit;
      });
    } else {
      print('Failed to load manga: ${response.statusCode}');
      throw Exception('Failed to load manga');
    }
  }

  Future<Map<String, dynamic>> fetchCoverArtDetails(String coverArtId) async {
    final response = await http.get(
      Uri.parse('https://api.mangadex.org/cover/$coverArtId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load cover art details');
    }
  }

  Future<void> _performSearch(String query) async {
    final response = await http
        .get(Uri.parse('https://api.mangadex.org/manga?title=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> mangaData = data['data'] ?? [];

      setState(() {
        mangaList.clear();
        mangaList.addAll(List<Map<String, dynamic>>.from(mangaData));
      });
    } else {
      print('Failed to search manga: ${response.statusCode}');
      throw Exception('Failed to search manga');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DBS_MANGA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromARGB(255, 243, 33, 61),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: const Color.fromARGB(255, 123, 16, 30),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search manga...',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  onPressed: () {
                    _performSearch(searchController.text);
                  },
                  icon: const Icon(Icons.search),
                  iconSize: 30.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: mangaList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: mangaList.length,
                    itemBuilder: (context, index) {
                      final mangaAttributes = mangaList[index]['attributes'];
                      final mangaTitle =
                          mangaAttributes['title']['en'] ?? 'No Title';
                      final coverArtRelationships =
                          mangaList[index]['relationships'] as List<dynamic>;

                      String coverArtId = '';
                      for (final relationship in coverArtRelationships) {
                        if (relationship['type'] == 'cover_art') {
                          coverArtId = relationship['id'];
                          break;
                        }
                      }

                      return FutureBuilder(
                        future: fetchCoverArtDetails(coverArtId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Card(
                              child: ListTile(
                                title: Text('Loading...'),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Card(
                              child: ListTile(
                                title: Text('Error loading data'),
                              ),
                            );
                          } else {
                            final Map<String, dynamic>? coverArtData =
                                snapshot.data as Map<String, dynamic>?;

                            final List<dynamic>? relationships =
                                (coverArtData?['relationships']
                                    as List<dynamic>?);
                            String mangaId = 'defaultMangaId';

                            if (relationships != null &&
                                relationships.isNotEmpty) {
                              for (final relationship in relationships) {
                                if (relationship['type'] == 'manga') {
                                  mangaId = relationship['id'];
                                  break;
                                }
                              }
                            }

                            return AspectRatio(
                              aspectRatio:
                                  0.75, // Sesuaikan dengan preferensi Anda
                              child: Card(
                                child: ListTile(
                                  title: Column(
                                    children: [
                                      Text(
                                        mangaTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      FutureBuilder(
                                        future:
                                            fetchCoverArtDetails(coverArtId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Text(
                                                'Loading fileName...');
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                                'Error loading fileName');
                                          } else {
                                            final Map<String, dynamic>?
                                                coverArtData = snapshot.data
                                                    as Map<String, dynamic>?;

                                            if (coverArtData != null &&
                                                coverArtData['attributes'] !=
                                                    null &&
                                                coverArtData['attributes']
                                                        ['fileName'] !=
                                                    null) {
                                              final String fileName =
                                                  coverArtData['attributes']
                                                      ['fileName'];
                                              return Image.network(
                                                'https://mangadex.org/covers/$mangaId/$fileName',
                                                width: 100,
                                                height: 150,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    color: Colors.grey,
                                                    child: const Center(
                                                      child: Icon(Icons.error),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              return const Text(
                                                  'FileName not found');
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    String fileName = '';

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          if (coverArtData != null &&
                                              coverArtData['attributes'] !=
                                                  null &&
                                              coverArtData['attributes']
                                                      ['fileName'] !=
                                                  null) {
                                            fileName =
                                                coverArtData['attributes']
                                                    ['fileName'];
                                          }

                                          return DetailPage(
                                            mangaId: mangaId,
                                            fileName: fileName,
                                            title: mangaTitle,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchData();
        },
        child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.red,
          ),
          child: const Center(
            child: Text(
              'Load More',
              style: TextStyle(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            } else if (_currentIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TopMangaPage()),
              );
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Top Manga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
