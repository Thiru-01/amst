import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String url;
  const ImageViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Image"),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: CachedNetworkImage(imageUrl: url),
      ),
    );
  }
}
