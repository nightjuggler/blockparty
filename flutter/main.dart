import 'dart:math';
import 'package:flutter/material.dart';
import './blocks.dart';

void main() => runApp(const GameApp());

enum Fill { empty, solid, half, grid }

final circle = Path()
  ..addOval(const Rect.fromLTWH(10, 10, 120, 120));

final heart = Path()
  ..moveTo(70, 46)
  ..cubicTo( 60,  10,  10,  10,  10,  46)
  ..cubicTo( 10,  72,  70, 130,  70, 130)
  ..cubicTo( 70, 130, 130,  72, 130,  46)
  ..cubicTo(130,  10,  80,  10,  70,  46)
  ..close();

final square = Path()
  ..addRect(const Rect.fromLTWH(10, 10, 120, 120));

final triangle = Path()
  ..moveTo(70, 20)
  ..lineTo(130, 130)
  ..lineTo(10, 130)
  ..close();

class ShapePainter extends CustomPainter {
  static final gridPath = Path()
    ..moveTo( 40,  10)..lineTo( 40, 130)
    ..moveTo( 70,  10)..lineTo( 70, 130)
    ..moveTo(100,  10)..lineTo(100, 130)
    ..moveTo( 10,  40)..lineTo(130,  40)
    ..moveTo( 10,  70)..lineTo(130,  70)
    ..moveTo( 10, 100)..lineTo(130, 100);

  static final shapePaths = [heart, circle, square, triangle];
  static const shapeColors = [Colors.red, Colors.blue, Colors.black, Colors.orange];

  final Path shape;
  final Color color;
  final Fill fill;

  ShapePainter(List<int> spec) :
    shape = shapePaths[spec[0]],
    color = shapeColors[spec[1]],
    fill = Fill.values[spec[2]];

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = fill == Fill.solid ? PaintingStyle.fill : PaintingStyle.stroke;
    paint.strokeWidth = 10;
    canvas.drawPath(shape, paint);
    if (fill == Fill.grid) {
      canvas.clipPath(shape);
      paint.strokeWidth = 4;
      canvas.drawPath(gridPath, paint);
    } else if (fill == Fill.half) {
      canvas.clipPath(shape);
      paint.style = PaintingStyle.fill;
      paint.strokeWidth = 2;
      canvas.drawRect(const Rect.fromLTWH(70, 0, 70, 140), paint);
    }
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) => false;
}

class ShapeButton extends StatefulWidget {
  static const size = 60.0;
  static const borderWidth = 2.0;
  final Widget child;
  final bool Function(ShapeButtonState) toggle;

  ShapeButton(spec, this.toggle, {super.key}) :
    child = SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        child: CustomPaint(
          painter: ShapePainter(spec),
          size: const Size.square(140),
        ), // CustomPaint
      ), // FittedBox
    ); // SizedBox

  @override
  State<ShapeButton> createState() => ShapeButtonState();
}

class ShapeButtonState extends State<ShapeButton> {
  bool selected = false;

  void toggle() {
    setState(() { selected = !selected; });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
        side: BorderSide(
          width: ShapeButton.borderWidth,
          color: selected ? Colors.indigo : Colors.transparent,
        ),
      ),
      onPressed: () { if (widget.toggle(this)) toggle(); },
      child: widget.child,
    );
  }
}

class Block {
  final int index, face, rotation;
  int? selectedShapeIndex;
  ShapeButtonState? selectedShapeState;

  Block(this.index, this.face, this.rotation);

  List<List<int>> shapes() => blockSpec[index][face];
  List<int> selectedShape() => shapes()[selectedShapeIndex!];

  static void toggle(final Block? block) => block?.selectedShapeState?.toggle();
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late List<Block> _blocks;
  late List<Block> _blocksShuffled;
  late UniqueKey _blocksKey;
  final _selectedBlocks = List<Block?>.filled(4, null, growable: false);
  int _numSelected = 0;
  final _faceCache = <int, Widget>{};

  void shuffle() {
    final random = Random();
    _blocks = List<Block>.generate(blockSpec.length,
      (int index) => Block(index, random.nextInt(6), random.nextInt(4)), growable: false);
    _blocksShuffled = List<Block>.of(_blocks, growable: false)..shuffle(random);
    _blocksKey = UniqueKey();
    _selectedBlocks.forEach(Block.toggle);
    _selectedBlocks.fillRange(0, 4);
    _numSelected = 0;
  }

  _MainState() {
    shuffle();
  }

  void printReason(String trait, int length) {
    if (length == 1) {
      print('The $trait are all the same.');
    } else if (length == 4) {
      print('The $trait are all different.');
    } else {
      print('There are $length different $trait.');
    }
  }

  void checkParty() {
    final shapes = <int>{};
    final colors = <int>{};
    final fills = <int>{};
    for (final List<int> shape in _selectedBlocks.map((block) => block!.selectedShape())) {
      shapes.add(shape[0]);
      colors.add(shape[1]);
      fills.add(shape[2]);
    }
    final lengths = [shapes.length, colors.length, fills.length]..sort();
    final points = <String, int>{
      '111': 1,
      '114': 2,
      '144': 3,
      '444': 4,
    }[lengths.join()];
    print(points == null ? 'No Party!' : 'Party!');
    printReason('shapes', shapes.length);
    printReason('colors', colors.length);
    printReason('fills', fills.length);
  }

  bool toggle(final ShapeButtonState shapeState, final int blockIndex, final int shapeIndex) {
    final block = _blocks[blockIndex];
    if (block.selectedShapeIndex == shapeIndex) {
      block.selectedShapeIndex = null;
      block.selectedShapeState = null;
      _numSelected -= 1;
      for (int i = 0; i < 4; i++) {
        if (_selectedBlocks[i] == block) {
          _selectedBlocks[i] = null;
          break;
        }
      }
      return true;
    }
    if (block.selectedShapeState != null) {
      block.selectedShapeState!.toggle();
    } else if (_numSelected == 4) {
      return false;
    } else {
      _numSelected += 1;
      for (int i = 0; i < 4; i++) {
        if (_selectedBlocks[i] == null) {
          _selectedBlocks[i] = block;
          break;
        }
      }
    }
    block.selectedShapeIndex = shapeIndex;
    block.selectedShapeState = shapeState;
    if (_numSelected == 4) checkParty();
    return true;
  }

  Widget buildFaceFromShapes(final List<ShapeButton> shapes) => Container(
    margin: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      border: Border.all(
        color: const Color.fromARGB(255,204,204,204),
      ), // Border
      boxShadow: const [BoxShadow(
        blurRadius: 20,
        blurStyle: BlurStyle.normal,
        color: Color.fromRGBO(0,0,0,0.5),
      )], // BoxShadow
      color: const Color.fromARGB(255,255,235,205), // BlanchedAlmond
    ), // BoxDecoration
    child: GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 36,
      mainAxisSpacing: 36,
      children: [
        shapes[0],
        RotatedBox(quarterTurns: 1, child: shapes[1]),
        RotatedBox(quarterTurns: 3, child: shapes[3]),
        RotatedBox(quarterTurns: 2, child: shapes[2]),
      ],
    ), // GridView
  ); // Container

  Widget buildFaceFromBlock(final Block block) {
    final face = _faceCache.putIfAbsent(
      10 * (block.index + 1) + block.face + 1,
      () {
        final shapes = block.shapes();
        return buildFaceFromShapes(
          List<ShapeButton>.generate(
            shapes.length,
            (final int shapeIndex) => ShapeButton(
              shapes[shapeIndex],
              (shapeState) => toggle(shapeState, block.index, shapeIndex),
            ),
            growable: false,
          ),
        );
      },
    );
    return block.rotation == 0 ? face :
      RotatedBox(quarterTurns: block.rotation, child: face);
  }

  @override
  Widget build(BuildContext context) {
    final faces = List<Widget>.unmodifiable(_blocksShuffled.map(buildFaceFromBlock));

    var timeLeft = '00:00';
    var score = 0;
    var playLabel = 'PLAY';
    final portrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
        appBar: portrait ? AppBar(
          title: const Text('Block Party'),
        ) : null,
        backgroundColor: const Color.fromARGB(255,222,184,135), // BurlyWood
        body: portrait ? GridView.count(
          key: _blocksKey,
          crossAxisCount: 2,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 26),
          children: faces,
        ) : GridView.count(
          key: _blocksKey,
          crossAxisCount: 4,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 80),
          children: faces,
        ), // GridView
        bottomSheet: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Verdana',
            fontSize: 20,
          ), // TextStyle
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color.fromARGB(255,124,252,0), Color.fromARGB(255,255,215,0)]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(' Time: $timeLeft'),
                ElevatedButton(
                  onPressed: () => setState(shuffle),
                  child: Text(playLabel),
                ),
                Text('Score: $score '),
              ],
            ), // Row
          ), // Container
        ), // DefaultTextStyle
    ); // Scaffold
  }
}
