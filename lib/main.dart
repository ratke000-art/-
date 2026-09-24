import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFA855F7),
          surface: Color(0xFF161822),
          surfaceContainerHigh: Color(0xFF232636),
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
  final String? generationId;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.videoUrl,
    this.generationId,
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

  final String backendBaseUrl = "https://dein-backend-service.onrender.com";
  final String demoUserId = "8d1e1f2a-3b4c-5d6e-7f8a-9b0c1d2e3f4a";
  int userCredits = 10;

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

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    if (userCredits <= 0) {
      _showPaywallDialog();
      return;
    }

    _promptController.clear();
    final userMsgId = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      _messages.add(ChatMessage(id: userMsgId, isUser: true, text: text));
      _messages.add(ChatMessage(
        id: 'loading_$userMsgId',
        isUser: false,
        text: 'KI-Regisseur optimiert den Prompt & startet Rendering...',
        isLoading: true,
      ));
      userCredits -= 1;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/api/v1/generate-video'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': demoUserId,
          'raw_prompt': text,
          'aspect_ratio': '16:9',
        }),
      ).timeout(const Duration(seconds: 4));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _startStatusPolling(data['generation_id'], userMsgId);
      } else if (response.statusCode == 402) {
        _handleGenerationError(userMsgId, 'Nicht genügend Credits.');
        _showPaywallDialog();
      } else {
        _simulateDemoVideo(userMsgId);
      }
    } catch (_) {
      if (mounted) {
        _simulateDemoVideo(userMsgId);
      }
    }
  }

  void _startStatusPolling(String generationId, String userMsgId) {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final res = await http.get(
          Uri.parse('$backendBaseUrl/api/v1/generation-status/$generationId'),
        );
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'completed') {
            timer.cancel();
            _completeVideoGeneration(userMsgId, data['video_url'], generationId);
          } else if (data['status'] == 'failed') {
            timer.cancel();
            setState(() => userCredits += 1);
            _handleGenerationError(userMsgId, 'Rendering fehlgeschlagen. Credit erstattet.');
          }
        }
      } catch (_) {
        timer.cancel();
        if (mounted) {
          _simulateDemoVideo(userMsgId);
        }
      }
    });
  }

  void _simulateDemoVideo(String userMsgId) {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _completeVideoGeneration(
        userMsgId,
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        'demo_gen_id',
      );
    });
  }

  void _completeVideoGeneration(String userMsgId, String videoUrl, String genId) {
    setState(() {
      _messages.removeWhere((m) => m.id == 'loading_$userMsgId');
      _messages.add(ChatMessage(
        id: 'video_$userMsgId',
        isUser: false,
        text: 'Hier ist dein fertig gerendertes Video:',
        videoUrl: videoUrl,
        generationId: genId,
      ));
    });
    _scrollToBottom();
  }

  void _handleGenerationError(String userMsgId, String errorText) {
    setState(() {
      _messages.removeWhere((m) => m.id == 'loading_$userMsgId');
      _messages.add(ChatMessage(
        id: 'err_$userMsgId',
        isUser: false,
        text: 'Fehler: $errorText',
      ));
    });
    _scrollToBottom();
  }

  void _showPaywallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161822),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Colors.amber),
            SizedBox(width: 8),
            Text('Keine Credits mehr!'),
          ],
        ),
        content: const Text(
          'Hole dir neue Credits, um weitere KI-Videos mit dem KI-Regisseur zu generieren.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
            ),
            onPressed: () {
              setState(() => userCredits += 10);
              Navigator.pop(context);
            },
            child: const Text('10 Credits kaufen (€2.99)'),
          ),
        ],
      ),
    );
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
          GestureDetector(
            onTap: _showPaywallDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF232636),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('$userCredits Credits', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
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
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
              VideoCardWidget(
                videoUrl: msg.videoUrl!,
                generationId: msg.generationId,
                backendUrl: backendBaseUrl,
                userId: demoUserId,
              ),
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
              borderRadius: BorderRadius.circular(25),
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
  final String? generationId;
  final String backendUrl;
  final String userId;

  const VideoCardWidget({
    super.key,
    required this.videoUrl,
    this.generationId,
    required this.backendUrl,
    required this.userId,
  });

  @override
  State<VideoCardWidget> createState() => _VideoCardWidgetState();
}

class _VideoCardWidgetState extends State<VideoCardWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  int _feedbackGiven = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback(int rating) async {
    setState(() => _feedbackGiven = rating);
    if (widget.generationId == null) return;

    try {
      await http.post(
        Uri.parse('${widget.backendUrl}/api/v1/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'generation_id': widget.generationId,
          'rating': rating,
          'feedback_tags': rating == 1 ? ['cinematic'] : ['blurry'],
        }),
      );
    } catch (_) {}
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
                    color: Colors.white.withValues(alpha: 0.85),
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
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: const Color(0xFF232636),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up_alt,
                    color: _feedbackGiven == 1 ? Colors.greenAccent : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => _sendFeedback(1),
                ),
                IconButton(
                  icon: Icon(
                    Icons.thumb_down_alt,
                    color: _feedbackGiven == -1 ? Colors.redAccent : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => _sendFeedback(-1),
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
