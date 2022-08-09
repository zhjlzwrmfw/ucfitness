import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class CustomDotSwiperPaginationBuilder extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color color;

  ///Size of the dot when activate
  final double activeSize;

  ///Size of the dot
  final double size;

  /// Space between dots
  final double space;

  final Key key;

  const CustomDotSwiperPaginationBuilder(
      {this.activeColor,
        this.color,
        this.key,
        this.size: 14.0,
        this.activeSize: 14.0,
        this.space: 4.0});

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    Color activeColor = this.activeColor;
    Color color = this.color;

    if (activeColor == null || color == null) {
      final ThemeData themeData = Theme.of(context);
      activeColor = this.activeColor ?? themeData.primaryColor;
      color = this.color ?? themeData.scaffoldBackgroundColor;
    }

    if (config.indicatorLayout != PageIndicatorLayout.NONE &&
        config.layout == SwiperLayout.DEFAULT) {
      return PageIndicator(
        count: config.itemCount,
        controller: config.pageController,
        layout: config.indicatorLayout,
        size: size,
        activeColor: activeColor,
        color: color,
        space: space,
      );
    }

    final List<Widget> list = [];

    final int itemCount = config.itemCount;
    final int activeIndex = config.activeIndex;

    for (int i = 0; i < itemCount; ++i) {
      final bool active = i == activeIndex;
      list.add(Row(
        children: <Widget>[
          Container(
            width: active ? activeSize : size,
            height: active ? activeSize : size,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
                color: active ? activeColor : color,
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(active ? activeSize / 2 : size / 2,))
            ),
          ),
          if(i != itemCount - 1)
            Container(
              width: space,
              height: 1,
              color: Colors.black38,
              margin: const EdgeInsets.only(bottom: 24),
            )
        ],
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        key: key,
        children: list,
      ),
    );
  }
}