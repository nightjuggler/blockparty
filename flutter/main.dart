import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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
  final bool Function(ShapeButtonState, BuildContext) toggle;

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
      onPressed: () { if (widget.toggle(this, context)) toggle(); },
      child: widget.child,
    );
  }
}

class Block {
  final int index;
  int face, rotation;
  int? selectedShapeIndex;
  ShapeButtonState? selectedShapeState;

  Block(this.index, this.face, this.rotation);

  List<List<int>> shapes() => blockSpec[index][face];
  List<int> selectedShape() => shapes()[selectedShapeIndex!];

  static void toggle(final Block? block) => block?.selectedShapeState?.toggle();
}

class GameTimer extends StatefulWidget {
  final void Function() gameStart, gameOver;

  const GameTimer(this.gameStart, this.gameOver, {super.key});

  @override
  State<GameTimer> createState() => GameTimerState();
}

class GameTimerState extends State<GameTimer> {
  static const _gameDuration = Duration(minutes: 5, seconds: 1);
  DateTime _endTime = DateTime.now();
  Timer? _timer;

  void onPressed() {
    if (_timer != null) return;
    widget.gameStart();
    setState(() {
      _endTime = DateTime.now().add(_gameDuration);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
    });
  }

  void onLongPress() {
    if (_timer == null || !_timer!.isActive) return;
    setState(() {
      _endTime = DateTime.now();
      _timer!.cancel();
    });
  }

  void showGameOver(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'Verdana',
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color.fromARGB(255,255,228,225),
        content: Center(child: Text('Game Over!', style: textStyle)),
        duration: Duration(seconds: 4),
      )
    ).closed.then((SnackBarClosedReason reason) {
      widget.gameOver();
      setState(() { _timer = null; });
    });
  }

  @override
  Widget build(BuildContext context) {
    Duration timeLeft = Duration.zero;
    if (_timer != null) {
      final now = DateTime.now();
      if (now.isBefore(_endTime)) {
        timeLeft = _endTime.difference(now);
      } else {
        _timer!.cancel();
        Timer.run(() => showGameOver(context));
      }
    }
    return TextButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: Text(
        _timer == null ? ' Start' : ' ${timeLeft.toString().substring(2, 7)}',
        style: const TextStyle(color: Colors.black, fontFamily: 'Verdana', fontSize: 18),
      ),
    );
  }
}

class JsonFile {
  final String name;
  File? file;

  JsonFile(this.name);

  Future<File> getFile() async {
    // https://pub.dev/packages/path_provider
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/$name.json';
    return File(path);
  }

  Future<dynamic> read() async {
    try {
      file = await getFile();
      final string = await file?.readAsString();
      return jsonDecode(string ?? 'null');
    } catch (e) {
      return null;
    }
  }

  void write(object) {
    file?.writeAsString(jsonEncode(object));
  }
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
  bool _disabled = false;
  final _faceCache = <int, Widget>{};
  int? _gameScore;
  GameTimer? _timer;
  final _scoresFile = JsonFile('scores');
  List<dynamic>? _scores;

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
    _scoresFile.read().then((scores) {
      _scores = scores ?? List<dynamic>.generate(10, (int index) => [0, '', '']);
    });
  }

  void checkParty(final BuildContext context) {
    _disabled = true;
    final shapes = <int>{};
    final colors = <int>{};
    final fills = <int>{};

    for (int i = 0; i < 4; i++) {
      final List<int> shape = _selectedBlocks[i]!.selectedShape();
      shapes.add(shape[0]);
      colors.add(shape[1]);
      fills.add(shape[2]);
    }

    final lengths = ([shapes.length, colors.length, fills.length]..sort()).join();
    final points = <String, int>{'111': 1, '114': 2, '144': 3, '444': 4}[lengths];
    final party = points != null;
    if (party && _gameScore != null) {
      setState(() { _gameScore = _gameScore! + points; });
    }

    const boldRed = TextStyle(color: Color.fromARGB(255,255,0,0), fontWeight: FontWeight.bold);
    const boldGreen = TextStyle(color: Color.fromARGB(255,0,170,0), fontWeight: FontWeight.bold);
    const defaultStyle = TextStyle(color: Colors.black, fontFamily: 'Verdana', fontSize: 16);
    const checkMark = Text('\u2713 ', style: boldGreen);
    const xMark = Text('\u00D7 ', style: boldRed);

    Widget reasonRow(mark, text) => Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [mark, Text(text)]);
    Widget reason(String trait, int length) =>
      length == 1 ? reasonRow(checkMark, 'Same $trait') :
      length == 4 ? reasonRow(checkMark, 'Unique ${trait}s') :
      reasonRow(xMark, '$length ${trait}s');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: party ?
          const Color.fromARGB(255,255,240,0) :
          const Color.fromARGB(255,255,228,225),
        content: DefaultTextStyle(
          style: defaultStyle,
          child: Column(
            children: [
              party ? Text('Party!!! ($points points)', style: boldGreen) :
                const Text('Not a Party!', style: boldRed),
              reason('shape', shapes.length),
              reason('color', colors.length),
              reason('fill', fills.length),
            ],
          ), // Column
        ), // DefaultTextStyle
        duration: const Duration(seconds: 4),
      )
    ).closed.then((SnackBarClosedReason reason) {
      if (party) {
        void rotate(final Block block, final Map<int, int> rotateMap) {
          final int position = rotateMap[10 * block.face + block.rotation]!;
          block.face = position ~/ 10;
          block.rotation = position % 10;
          block.selectedShapeState!.toggle();
          block.selectedShapeIndex = null;
          block.selectedShapeState = null;
        }
        rotate(_selectedBlocks[0]!, rotateLeft);
        rotate(_selectedBlocks[1]!, rotateRight);
        rotate(_selectedBlocks[2]!, rotateLeft);
        rotate(_selectedBlocks[3]!, rotateRight);
        setState(() {
          _blocksKey = UniqueKey();
          _selectedBlocks.fillRange(0, 4);
          _numSelected = 0;
        });
      }
      _disabled = false;
    });
  }

  bool toggle(
    final ShapeButtonState shapeState,
    final BuildContext context,
    final int blockIndex,
    final int shapeIndex)
  {
    if (_disabled) return false;

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
    if (_numSelected == 4) checkParty(context);
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
      physics: const NeverScrollableScrollPhysics(),
      primary: false,
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
              (shapeState, context) => toggle(shapeState, context, block.index, shapeIndex),
            ),
            growable: false,
          ),
        );
      },
    );
    return block.rotation == 0 ? face :
      RotatedBox(quarterTurns: 4 - block.rotation, child: face);
  }

  void gameStart() {
    _gameScore = 0;
    setState(shuffle);
  }

  void gameOver() {
    if (_scores != null) {
      List<dynamic> scores = _scores!;
      int i = scores.length;
      while (i > 0 && _gameScore! > scores[i-1][0]) { --i; }
      if (i < scores.length) {
        scores.insert(i, [_gameScore, DateTime.now().toString(), '']);
        scores.removeLast();
        _scoresFile.write(scores);
      }
    }
    setState(() { _gameScore = null; });
  }

  Widget buildScoresTable(List<dynamic> scores) {
    const textStyle = TextStyle(inherit: false, color: Colors.black, fontFamily: 'Verdana', fontSize: 15);
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ListView.separated(
        itemCount: scores.length + 1,
        itemBuilder: (BuildContext context, int i) {
          if (i == 0) {
            return Container(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 6.0, bottom: 6.0),
              color: const Color.fromARGB(255,222,184,135),
              child: const Center(child: Text('High Scores', style: textStyle)),
            );
          }
          final int score = scores[i-1][0];
          final String date = scores[i-1][1];
          return ListTile(
            leading: Text('$i.'),
            leadingAndTrailingTextStyle: textStyle,
            tileColor: const Color.fromARGB(255,222,184,135),
            title: Text(score == 0 ? '\u2014' : score.toString(), textAlign: TextAlign.right),
            titleAlignment: ListTileTitleAlignment.center,
            titleTextStyle: textStyle,
            trailing: Text(date.isEmpty ? '\u2014' : date.substring(0, 10)),
          );
        },
        separatorBuilder: (BuildContext context, int i) => const Divider(height: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final portrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final faces = List<Widget>.unmodifiable(_blocksShuffled.map(buildFaceFromBlock));
    const bgColor = Color.fromARGB(255,222,184,135); // BurlyWood
    const textStyle = TextStyle(color: Colors.black, fontFamily: 'Verdana', fontSize: 18);
    const toolbarHeight = 35.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.black,
        flexibleSpace: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color.fromARGB(255,124,252,0), Color.fromARGB(255,255,215,0)]),
          ),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.paddingOf(context).top + toolbarHeight,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _timer ??= GameTimer(gameStart, gameOver),
            if (_gameScore != null) Text('Score: $_gameScore  '),
          ],
        ),
        titleSpacing: 0.0,
        titleTextStyle: textStyle,
        toolbarHeight: toolbarHeight,
      ),
      backgroundColor: bgColor,
      body: portrait ? GridView.count(
        key: _blocksKey,
        crossAxisCount: 2,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 26),
        children: faces,
      ) : GridView.count(
        key: _blocksKey,
        crossAxisCount: 4,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 80),
        children: faces,
      ), // GridView
      drawer: _scores == null ? null : buildScoresTable(_scores!),
    ); // Scaffold
  }
}
