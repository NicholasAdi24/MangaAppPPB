import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ReadPage extends StatefulWidget {
  final String baseUrl;
  final String chapterHash;
  final List<String> chapterData;

  const ReadPage({
    Key? key,
    required this.baseUrl,
    required this.chapterHash,
    required this.chapterData,
  }) : super(key: key);

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  bool isVertical = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isVertical ? buildVerticalView() : buildHorizontalView(),
          Positioned(
            top: 40,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isVertical = !isVertical;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(10),
                child: isVertical
                    ? const Icon(Icons.swap_horiz)
                    : const Icon(Icons.swap_vert),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerticalView() {
    return ListView.builder(
      itemCount: widget.chapterData.length,
      itemBuilder: (context, index) {
        final imageUrl =
            '${widget.baseUrl}/data/${widget.chapterHash}/${widget.chapterData[index]}';
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(imageUrl),
        );
      },
    );
  }

  Widget buildHorizontalView() {
    return PhotoViewGallery.builder(
      itemCount: widget.chapterData.length,
      builder: (context, index) {
        final imageUrl =
            '${widget.baseUrl}/data/${widget.chapterHash}/${widget.chapterData[index]}';
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      scrollPhysics: BouncingScrollPhysics(),
      backgroundDecoration: BoxDecoration(
        color: Colors.black,
      ),
      pageController: PageController(),
      onPageChanged: (index) {},
    );
  }
}
