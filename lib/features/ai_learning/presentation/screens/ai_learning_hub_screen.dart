import 'package:flutter/material.dart';
import 'package:bim/core/theme/app_colors.dart'; // Import theme của bạn
import 'package:bim/core/theme/gradient_background.dart';
import '../../data/ai_learning_service.dart';
import '../../domain/models/chat_message.dart';

class AiLearningHubScreen extends StatefulWidget {
  final String studentId;
  const AiLearningHubScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  State<AiLearningHubScreen> createState() => _AiLearningHubScreenState();
}

class _AiLearningHubScreenState extends State<AiLearningHubScreen> with SingleTickerProviderStateMixin {
  final AiLearningService _service = AiLearningService();
  late TabController _tabController;
  bool _isLoading = false;

  // --- Chat state ---
  final List<ChatMessage> _messages = [];
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Tin nhắn chào mừng ban đầu
    _messages.add(ChatMessage(
      text: 'Xin chào! Mình là trợ lý AI học tiếng Nhật. Bạn muốn hỏi gì nào?',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground( // Sử dụng theme đồng nhất
      child: Scaffold(
        backgroundColor: Colors.transparent, // Để gradient làm nền
        appBar: AppBar(
          title: const Text('AI Learning Hub', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [Tab(text: 'Challenge'), Tab(text: 'Chatbot')],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : TabBarView(
          controller: _tabController,
          children: [
            _buildChallengeTab(),
            _buildChatTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeTab() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            final res = await _service.generateChallenge(widget.studentId);
            _showMsg("Đã tạo Challenge: #${res['result']['sessionId']}");
          } catch (e) {
            _showMsg(e.toString().replaceAll('Exception: ', ''));
          } finally {
            setState(() => _isLoading = false);
          }
        },
        child: const Text('Bắt đầu Challenge mới', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ================== CHAT TAB ==================

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length + (_isSendingMessage ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isSendingMessage && index == _messages.length) {
                return _buildTypingIndicator();
              }
              return _buildChatBubble(_messages[index]);
            },
          ),
        ),
        _buildChatInputBar(),
      ],
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade600 : Colors.grey.shade800,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 14),
          ),
        ),
        child: Text(
          msg.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const SizedBox(
          width: 24,
          height: 12,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatInputController,
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi của bạn...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendChatMessage(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isSendingMessage ? null : _sendChatMessage,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendChatMessage() async {
    final text = _chatInputController.text.trim();
    if (text.isEmpty || _isSendingMessage) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isSendingMessage = true;
      _chatInputController.clear();
    });
    _scrollToBottom();

    try {
      final res = await _service.chatWithAi(widget.studentId, text);
      final aiMessage = res['result']?['message'] ?? 'Xin lỗi, mình chưa có câu trả lời.';
      setState(() {
        _messages.add(ChatMessage(text: aiMessage, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Lỗi: ${e.toString().replaceAll('Exception: ', '')}',
          isUser: false,
        ));
      });
    } finally {
      setState(() => _isSendingMessage = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}