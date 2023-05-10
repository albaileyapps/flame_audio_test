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
  bool appleTimerHasStarted = false;
  late TappableSprite bagSpriteComponent; // bag plays a one-time sound when it is pressed - FlameAudio.play()
  late TappableSprite catSpriteComponent; // cat starts a 2 sec timer, onTick plays sound - FlameAudio.play()
  late TappableSprite appleSpriteComponent; // apple starts a 2 sec timer, onTick plays a sound - AudioPool
  late TappableSprite bananaSpriteComponent; // banana toggles FlameAudio.bgm

  late AudioPool pool;

  @override
  FutureOr<void> onLoad() async{
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(['bag.mp3', 'cat.mp3', 'apple.mp3']);
    pool = await FlameAudio.createPool('apple.mp3', maxPlayers: 3);
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
      FlameAudio.play('cat.mp3');
      catSpriteComponent.pulse();
      add(TimerComponent(period: 2.0, repeat: true, onTick: (){
        FlameAudio.play('cat.mp3');
        catSpriteComponent.pulse();
      }));
    });
    catSpriteComponent.position = Vector2(150, 20);

    final appleSprite = await Sprite.load('apple.png');
    appleSpriteComponent = TappableSprite(Vector2(100, 100), appleSprite, onTap: () {
      if (appleTimerHasStarted) return;
      appleTimerHasStarted = true;
      pool.start();
      appleSpriteComponent.pulse();
      add(TimerComponent(period: 2.0, repeat: true, onTick: (){
        pool.start();
        appleSpriteComponent.pulse();
      }));
    });
    appleSpriteComponent.position = Vector2(150, 300);

    final bananaSprite = await Sprite.load('banana.png');
    bananaSpriteComponent = TappableSprite(Vector2(100, 100), bananaSprite, onTap: () {
      bananaSpriteComponent.pulse();
      if(FlameAudio.bgm.isPlaying){
        FlameAudio.bgm.pause();
      }else {
        FlameAudio.bgm.play('music.mp3', volume: 1.0);
      }
    });
    bananaSpriteComponent.position = Vector2(20, 300);

    add(bananaSpriteComponent);
    add(appleSpriteComponent);
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