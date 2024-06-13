import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimationContainer extends StatefulWidget {
  final String text;
  final Function()? onPressedController;

  const AnimationContainer({
    Key? key,
    required this.text,
    required this.onPressedController,
  }) : super(key: key);

  @override
  State<AnimationContainer> createState() => _AnimationContainerState();
}

class _AnimationContainerState extends State<AnimationContainer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  var currentValue = 0.0;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    _animation = IntTween(begin: 0, end: 100).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        // This will be called every time the value of the animation changes
        currentValue = _animation.value / 100;
        // Use the animationValue as needed in your code
      });

    // _animation.addStatusListener((status) {
    //   // if (status == AnimationStatus.completed) {
    //   //   _animationController.reverse();
    //   // }
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white, // Color for the left 40%
                Colors.grey, // Color for the remaining 60%
              ],
              stops: [currentValue, 0], // Define the stop points (40% and 60%)
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black, // Change text color as needed
              ),
            ),
          ),
        ),
      ),
    );
  }
}
