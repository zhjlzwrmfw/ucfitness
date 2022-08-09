import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:running_app/common/requesrUrl.dart';
import 'package:running_app/model/newMedal.dart';

class AnimationMedal extends StatefulWidget {

  final int itemCount;
  final NewMedal medal;
  final double width;

  const AnimationMedal({Key key, this.itemCount, this.medal, this.width}) : super(key: key);


  @override
  _AnimationMedalState createState() => _AnimationMedalState();
}

class _AnimationMedalState extends State<AnimationMedal> with SingleTickerProviderStateMixin{

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black12,
      child: Swiper(
        loop: widget.medal.data.length != 1,
        itemCount: widget.itemCount,
        itemBuilder: (BuildContext context, int index){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RotationTransition(
                  turns: animation,
                  child: Container(
                    width: widget.width / 2,
                    height: widget.width / 2,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Image.network(
                      RequestUrl.getUserPictureUrl + widget.medal.data[index].image,
                      fit: BoxFit.fill,
                      headers: {'app_pass': RequestUrl.appPass},
                      color: const Color.fromRGBO(249, 122, 53, 1),
                    ),
                  ),
                ),
                FlatButton(
                  child: Icon(Icons.cancel, color: Colors.grey,size: widget.width / 10,),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
        pagination: SwiperPagination(
            builder: FractionPaginationBuilder(
              color: Colors.black54,
              activeColor: Colors.white70,
            )
        ),
      ),
    );
  }
}
