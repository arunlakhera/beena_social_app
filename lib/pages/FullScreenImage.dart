import 'package:beena_social_app/constants.dart';
import 'package:beena_social_app/widgets/HeaderWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  String screenType;
  String imageUrl;
  String imageUrl2;
  String imageUrl3;

  FullScreenImage(
      {this.screenType, this.imageUrl, this.imageUrl2, this.imageUrl3});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      appBar: header(context, isAppTitle: true, hideBackButton: false),
      body: SafeArea(
        child: InteractiveViewer(
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Carousel(
                  images: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.fill,
                    ),
                    if (imageUrl2 != 'NA')
                      CachedNetworkImage(
                        imageUrl: imageUrl2,
                        fit: BoxFit.fill,
                      ),
                    if (imageUrl3 != 'NA')
                      CachedNetworkImage(
                        imageUrl: imageUrl3,
                        fit: BoxFit.fill,
                      ),
                  ],
                  dotSize: 4.0,
                  dotSpacing: 15.0,
                  dotColor: Colors.lightGreenAccent,
                  indicatorBgPadding: 5.0,
                  dotBgColor: Colors.black87.withOpacity(0.5),
                  borderRadius: true,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
