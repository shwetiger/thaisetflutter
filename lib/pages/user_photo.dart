// @dart=2.9
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserPhoto extends StatelessWidget {
  const UserPhoto(
      {Key key,
      this.name,
      this.imageurl,
      this.width = 120,
      this.height = 120,
      this.borderColor = Colors.white})
      : super(key: key);
  final String name;
  final String imageurl;
  final double width, height;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return imageurl != null && imageurl != ""
        ? CachedNetworkImage(
            width: width,
            height: height,
            imageUrl: imageurl,
            httpHeaders: const <String, String>{
              "Access-Control-Allow-Origin": "*",
            },
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.colorBurn)),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(
              color: Colors.blue,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        : Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              // color: Theme.of(context).primaryColor,
              color: Colors.pink[200],
              // border: Border.all(
              //     color: Colors.white, width: 3.0),
              borderRadius: const BorderRadius.all(Radius.circular(100.0)),
            ),
            child: Center(
              child: Text(
                getFirstCOfName(name),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          );
  }

  String getFirstCOfName(String name) {
    if (name == null || name == "") {
      return "A";
    } else {
      return name.substring(0, 1);
    }
  }
}
