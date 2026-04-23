
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:training_app/presentation/screens/auth/login_screen.dart';
import 'package:training_app/presentation/screens/auth/register_screen.dart';

class AuthContainer extends StatefulWidget {
  const AuthContainer({super.key});

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/bg_video.mp4')
      ..initialize().then((_) {
        _videoController.setVolume(0.0);
        _videoController.setLooping(true);
        _videoController.play();
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void switchMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Container(color: Colors.black),
          Container(
            color: Colors.black.withOpacity(0.75),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isLogin
                ? LoginForm(onSwitchMode: switchMode)
                : RegisterForm(onSwitchMode: switchMode),
          ),
        ],
      ),
    );
  }
}
