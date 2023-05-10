import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GameWidget(game: game)
    );
  }

  var game = MyGame();
}

class MyGame extends FlameGame with HasTappables{

  bool catTimerHasStarted = false;
  late TappableSprite catSpriteComponent;
  late TappableSprite bagSpriteComponent;

  @override
  FutureOr<void> onLoad() async{
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(['bag.mp3', 'cat.mp3', 'music.mp3']);
    final bagSprite = await Sprite.load('bag.png');
    bagSpriteComponent = TappableSprite(Vector2(100, 100), bagSprite, onTap: () {
      bagSpriteComponent.pulse();
      FlameAudio.play('bag.mp3');
    });
    bagSpriteComponent.position = Vector2(10, 20);

    final catSprite = await Sprite.load('cat.png');
    catSpriteComponent = TappableSprite(Vector2(100, 100), catSprite, onTap: () {
      if (catTimerHasStarted) return;
      catTimerHasStarted = true;
      add(TimerComponent(period: 2.0, repeat: true, onTick: (){
        FlameAudio.play('cat.mp3');
        catSpriteComponent.pulse();
      }));
    });
    catSpriteComponent.position = Vector2(150, 20);

    var btn = TappableSprite(Vector2(100, 100), catSprite, onTap: () {
      FlameAudio.bgm.play('music.mp3', volume: 1.0);
    });
    btn.position = Vector2(20, 300);
    add(btn);

    add(bagSpriteComponent);
    add(catSpriteComponent);
    return super.onLoad();
  }


  @override
  Color backgroundColor() {
    return Colors.white;
  }
}

class TappableSprite extends SpriteComponent with Tappable {

  Function onTap;
  TappableSprite(Vector2 size, Sprite sprite, {required this.onTap}): super(size: size, sprite: sprite);

  @override
  bool onTapDown(TapDownInfo info) {
    onTap();
    return super.onTapDown(info);
  }

  pulse(){
    ScaleEffect scaleEffect = ScaleEffect.by(Vector2.all(1.15),
      EffectController(
        duration: 0.15,
        reverseDuration: 0.15,
        startDelay: 0,
        atMinDuration: 0,
        curve: Curves.easeInOut,
        infinite: false,
      ),);
    add(scaleEffect);
  }
}