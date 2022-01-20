import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../components.dart';

const double rainStrikeSize = 20, rainDropSize = 20, velocity = 50;
const rainDrop = RainDrop(width: rainDropSize);
const rainStrike = RainStrike(width: rainStrikeSize);


class Rainfall extends StatefulWidget {
  const Rainfall({Key? key}) : super(key: key);

  @override
  _RainfallState createState() => _RainfallState();
}

class _RainfallState extends State<Rainfall>
    with SingleTickerProviderStateMixin {
  final GlobalKey _stackKey = GlobalKey();
  final Random _random = Random();
  late AnimationController _animationController;
  final Size containerSize = const Size(800, 400);
  final Size containerTwoSize = const Size(400, 400);
  Size screenSize = const Size(720, 720);
  bool screenResized = false;
  Timer? timer, lastTimer;
  List<Raindrop> rainDrops = [];
  List<BarrierLayer> barriers = [];
  List<Raindrop> grounded = [];
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
      grounded = rainDrops.where((value) => value.grounded).toList();
      rainDrops.removeWhere((element) => element.grounded);
      rainDrops = rainDrops.map<Raindrop>((element) {
        try {
          BarrierLayer barrierLayer = barriers.firstWhere((barrierElement) =>
          element.position.dx >= barrierElement.from &&
              element.position.dx <= barrierElement.to);
          final double finalBarrierGroundPosition =
              barrierLayer.yPosition - rainDropSize;
          if (element.position.dy < finalBarrierGroundPosition) {
            double newY = (element.position.dy + velocity)
                .clamp(element.position.dy, finalBarrierGroundPosition);
            final bool isGrounded = newY == finalBarrierGroundPosition;
            return Raindrop(
                Offset(element.position.dx,
                    isGrounded ? barrierLayer.yPosition : newY),
                isGrounded);
          } else {
            return Raindrop(
                Offset(element.position.dx, barrierLayer.yPosition), true);
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
      timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        for (int number = 0; number < _random.nextInt(2000); number++) {
          double nextDouble = _random.nextDouble();
          rainDrops.add(Raindrop(
              Offset(_random.nextInt(screenSize.width.toInt()).toDouble(),
                  -nextDouble * 100),
              false));
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
      BarrierLayer(0, screenSize.width, screenSize.height - rainStrikeSize)
    ];
    _stackKey.currentContext?.visitChildElements((element) {
      RenderBox renderBox = element.renderObject! as RenderBox;
      Offset position = renderBox.localToGlobal(Offset.zero);
      barriers.add(BarrierLayer(
          position.dx,
          position.dx + renderBox.paintBounds.width,
          position.dy - rainStrikeSize));
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
                ...rainDrops
                    .map((flake) => Positioned(
                    left: flake.position.dx,
                    top: flake.position.dy,
                    child: rainDrop))
                    .toList(),
                ...grounded
                    .map((flake) => Positioned(
                    left: flake.position.dx,
                    top: flake.position.dy,
                    child: rainStrike))
                    .toList()
              ],
            ),
          );
        },
      ),
    );
  }
}

class RainDrop extends StatelessWidget {
  final double width;

  const RainDrop({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, (width * 1).toDouble()),
      //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
      painter: RainDropCustomPainter(),
    );
  }
}

class RainDropCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(0, size.height);
    path0.close();

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RainStrike extends StatelessWidget {
  final double width;

  const RainStrike({Key? key, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, (width * 1).toDouble()),
      //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
      painter: RainStrikeCustomPainter(),
    );
  }
}

class RainStrikeCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(size.width * 0.5000000, size.height);
    path0.lineTo(size.width, 0);

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
