import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const AiVideoApp());
}

class AiVideoApp extends StatelessWidget {
  const AiVideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KI-Regisseur Video App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        primaryColor: const Color(0xFF7C3AED),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFA855F7),
          surface: Color(0xFF161822),
        ),
      ),
      home: const ChatDirectorScreen(),
    );
  }
}

class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final String? videoUrl;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.videoUrl,
    this.isLoading = false,
  });
}

class ChatDirectorScreen extends StatefulWidget {
  const ChatDirectorScreen({super.key});

  @override
  State<ChatDirectorScreen> createState() => _ChatDirectorScreenState();
}

class _ChatDirectorScreenState extends State<ChatDirectorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: 'welcome',
        isUser: false,
        text: 'Willkommen! Ich bin dein KI-Regisseur. Beschreibe mir deine Idee und ich erstelle ein hochauflösendes Video für dich.',
      ),
    );
  }

  void _sendMessage() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    _promptController.clear();
    final userMsgId = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      _messages.add(ChatMessage(id: userMsgId, isUser: true, text: text));
      _messages.add(ChatMessage(
        id: 'loading_$userMsgId',
        isUser: false,
        text: 'KI-Regisseur optimiert den Prompt & rendert das Video...',
        isLoading: true,
      ));
    });

    _scrollToBottom();

    // Simulation der KI-Video-Generierung
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == 'loading_$userMsgId');
        _messages.add(ChatMessage(
          id: 'video_$userMsgId',
          isUser: false,
          text: 'Hier ist dein fertig gerendertes Video:',
          videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF161822),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.movie_creation, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KI-Regisseur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('GPT-4o + MiniMax Video', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF232636),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF7C3AED).withAlpha(100)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text('10 Credits', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF7C3AED) : const Color(0xFF161822),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.isLoading) ...[
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA855F7)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'KI-Regisseur generiert Video...',
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                msg.text,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              ),
            ],
            if (msg.videoUrl != null) ...[
              const SizedBox(height: 10),
              VideoCardWidget(videoUrl: msg.videoUrl!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF161822),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFFA855F7)),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Beschreibe deine Szene...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFF0D0E15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoCardWidget extends StatefulWidget {
  final String videoUrl;
  const VideoCardWidget({super.key, required this.videoUrl});

  @override
  State<VideoCardWidget> createState() => _VideoCardWidgetState();
}

class _VideoCardWidgetState extends State<VideoCardWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                IconButton(
                  iconSize: 48,
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                    color: Colors.white.withAlpha(220),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF232636),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.greenAccent, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.thumb_down_alt_outlined, color: Colors.redAccent, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.white70, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
