// detail.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'language.dart';

class DetailPage extends StatefulWidget {
  final String mangaId;
  final String fileName;
  final String title;

  const DetailPage({super.key, 
    required this.mangaId,
    required this.fileName,
    required this.title,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String description = 'Loading description...';
  late List<Chapter> chapters = [];

  @override
  void initState() {
    super.initState();
    fetchDescription();
    fetchChapterList();
  }

  Future<void> fetchDescription() async {
    final response = await http.get(
      Uri.parse('https://api.mangadex.org/manga/${widget.mangaId}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String descriptionText =
          data['data']['attributes']['description']['en'];
      setState(() {
        description = descriptionText;
      });
    } else {
      setState(() {
        description = 'Failed to load description';
      });
    }
  }

  Future<void> fetchChapterList() async {
    final response = await http.get(
      Uri.parse('https://api.mangadex.org/manga/${widget.mangaId}/aggregate'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Chapter> chapterList = [];

      data['volumes'].forEach((volumeKey, volumeData) {
        volumeData['chapters'].forEach((chapterKey, chapterData) {
          final List<String> others = chapterData['others'] != null
              ? List<String>.from(chapterData['others'])
              : [];

          chapterList.add(
            Chapter(
              id: chapterData['id'],
              chapter: chapterData['chapter'],
              others: others,
            ),
          );
        });
      });

      setState(() {
        chapters = chapterList;
      });
    } else {
      // Handle error when fetching chapters
      print('Failed to load chapters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, // Adjust the font size as needed
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 243, 33, 61),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30, // Adjust the font size as needed
              ),
            ),
            const Text(''),
            // Text('Manga ID: ${widget.mangaId}'),
            Image.network(
              'https://mangadex.org/covers/${widget.mangaId}/${widget.fileName}',
              width: 500,
              height: 450,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey,
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(description),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Chapters:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: chapters.map((chapter) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to LanguagePage when a chapter is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguagePage(
                          chapterTitle: 'Chapter ${chapter.chapter}',
                          chapterIds: [chapter.id, ...chapter.others],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text('Chapter ${chapter.chapter}'),
                      // subtitle: Text('ID: ${chapter.id}'),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Add other details you want to display
          ],
        ),
      ),
    );
  }
}

class Chapter {
  final String id;
  final String chapter;
  final List<String> others;

  Chapter({
    required this.id,
    required this.chapter,
    required this.others,
  });
}
