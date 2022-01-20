import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../components.dart';

const snowflakeSize = 10.0, velocity = 10;
final snowflake = Image.asset(
  "assets/images/snowflake.png",
  width: snowflakeSize,
);

class Snowfall extends StatefulWidget {
  const Snowfall({Key? key}) : super(key: key);

  @override
  _SnowfallState createState() => _SnowfallState();
}

class _SnowfallState extends State<Snowfall>
    with SingleTickerProviderStateMixin {
  final GlobalKey _stackKey = GlobalKey();
  final Random _random = Random();
  late AnimationController _animationController;
  final Size containerSize = const Size(800, 400);
  final Size containerTwoSize = const Size(400, 400);
  Size screenSize = const Size(720, 720);
  bool screenResized = false;
  Timer? timer, lastTimer;
  List<Snowflake> snowflakes = [];
  List<BarrierLayer> barriers = [];
  List<Snowflake> grounded = [];
  Offset positionOne = const Offset(250, 350);
  Offset positionTwo = const Offset(0, 0);

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(hours: 50));
    super.initState();
    _animationController.addListener(() {
      if (screenResized) {
        barrierRefresh();
      }
      // grounded = snowflakes.where((value) => value.grounded).toList();
      snowflakes.removeWhere((element) => element.groundedSeconds > 150);
      snowflakes = snowflakes.map<Snowflake>((element) {
        try {
          BarrierLayer barrierLayer = barriers.firstWhere((barrierElement) =>
              element.position.dx >= barrierElement.from &&
              element.position.dx <= barrierElement.to);
          final double finalBarrierGroundPosition =
              barrierLayer.yPosition - snowflakeSize;
          if (element.position.dy < finalBarrierGroundPosition) {
            double newY = (element.position.dy + velocity)
                .clamp(element.position.dy, finalBarrierGroundPosition);
            final bool isGrounded = newY == finalBarrierGroundPosition;
            return Snowflake(
                Offset(element.position.dx,
                    isGrounded ? barrierLayer.yPosition : newY),
                isGrounded,
                0);
          } else {
            return Snowflake(
                Offset(element.position.dx, barrierLayer.yPosition),
                true,
                element.groundedSeconds + 1);
          }
        } catch (e) {
          debugPrint(e.toString());
        }
        return element;
      }).toList();
      setState(() {});
    });

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      screenSize = MediaQuery.of(context).size;
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        for (int number = 0; number < _random.nextInt(20); number++) {
          double nextDouble = _random.nextDouble();
          snowflakes.add(Snowflake(
              Offset(_random.nextInt(screenSize.width.toInt()).toDouble(),
                  -nextDouble * 100),
              false,
              0));
        }
      });
      barrierRefresh();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    timer?.cancel();
    super.dispose();
  }

  barrierRefresh() {
    barriers = [
      BarrierLayer(0, screenSize.width, screenSize.height - snowflakeSize)
    ];
    _stackKey.currentContext?.visitChildElements((element) {
      RenderBox renderBox = element.renderObject! as RenderBox;
      Offset position = renderBox.localToGlobal(Offset.zero);
      barriers.add(BarrierLayer(
          position.dx,
          position.dx + renderBox.paintBounds.width,
          position.dy - snowflakeSize));
    });
    barriers.sort((BarrierLayer a, BarrierLayer b) {
      return a.yPosition > b.yPosition ? 1 : -1;
    });
    screenResized = false;
  }

  positionOneChange(dynamic panDetails) {
    if (panDetails is DragStartDetails || panDetails is DragUpdateDetails) {
      positionOne = Offset(
          panDetails.globalPosition.dx - containerSize.width / 2,
          panDetails.globalPosition.dy - containerSize.height / 2);
    }
    barrierRefresh();
  }

  positionTwoChange(dynamic panDetails) {
    if (panDetails is DragStartDetails || panDetails is DragUpdateDetails) {
      positionTwo = Offset(
          panDetails.globalPosition.dx - containerTwoSize.width / 2,
          panDetails.globalPosition.dy - containerTwoSize.height / 2);
    }
    barrierRefresh();
  }

  setScreenSize(BoxConstraints boxConstraints) {
    Size size = Size(boxConstraints.maxWidth, boxConstraints.maxHeight);
    if (size != screenSize) {
      screenSize = size;
      screenResized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          setScreenSize(constraints);
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                        Image.asset("assets/images/walle_background.jpg").image,
                    fit: BoxFit.cover)),
            child: Stack(
              children: [
                Stack(
                  key: _stackKey,
                  children: [
                    Positioned(
                        left: positionOne.dx,
                        top: positionOne.dy,
                        child: GestureDetector(
                          onPanStart: positionOneChange,
                          onPanEnd: positionOneChange,
                          onPanUpdate: positionOneChange,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white38,
                                border:
                                    Border.all(color: Colors.white, width: 4.0),
                                borderRadius: BorderRadius.circular(20.0)),
                            width: containerSize.width,
                            height: containerSize.height,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                              child: Center(
                                child: Image.asset(
                                    "assets/images/flutter_logo.png"),
                              ),
                            ),
                          ),
                        )),
                    Positioned(
                        left: positionTwo.dx,
                        top: positionTwo.dy,
                        child: GestureDetector(
                          onPanStart: positionTwoChange,
                          onPanUpdate: positionTwoChange,
                          onPanEnd: positionTwoChange,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white38,
                                border:
                                    Border.all(color: Colors.white, width: 4.0),
                                borderRadius: BorderRadius.circular(20.0)),
                            width: containerTwoSize.width,
                            height: containerTwoSize.height,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                              child: Center(
                                child:
                                    Image.asset("assets/images/dart_logo.png"),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
                ...snowflakes
                    .map((flake) => Positioned(
                        left: flake.position.dx,
                        top: flake.position.dy,
                        child: snowflake))
                    .toList(),
                // ...grounded
                //     .map((flake) => Positioned(
                //         left: flake.position.dx,
                //         top: flake.position.dy,
                //         child: rainStrike))
                //     .toList()
              ],
            ),
          );
        },
      ),
    );
  }
}
