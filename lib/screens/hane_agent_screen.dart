import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';

// =====================================================================
// Hane AI Agent Chat Ekranı
// Gemini REST API v1 – direkt HTTP çağrısı (SDK bağımsız)
// Desteklenen modeller: gemini-2.5-flash, gemini-2.0-flash, gemini-1.5-flash vb.
// =====================================================================

class HaneAgentScreen extends StatefulWidget {
  const HaneAgentScreen({super.key});

  @override
  State<HaneAgentScreen> createState() => _HaneAgentScreenState();
}

class _HaneAgentScreenState extends State<HaneAgentScreen>
    with TickerProviderStateMixin {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;
  late AnimationController _dotAnimCtrl;

  // ⚠️ Buraya kendi Gemini API key'inizi girin → https://aistudio.google.com/apikey
  static const String _apiKey = 'AQ.Ab8RN6I0JihPhUu1SZINZM7-1QVjeN8x2KEPGZBNEPeGhR8WvA';

  // Gemini REST API v1beta — SDK kullanmadan doğrudan HTTP
  // Bu endpoint tüm yeni modelleri destekler (gemini-2.5-flash dahil)
  static const String _model = 'gemini-1.5-flash';
  static String get _endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  static const String _systemPrompt =
      'Sen Hane AI kurumsal asistanısın. İHH İnsani Yardım Vakfı çalışanlarına '
      'yardım etmek için buradasın. Kurumsal güvenlik ve KVKK protokolleri gereğince '
      'Rol Tabanlı Erişim Kontrolü (RBAC) uygulamakla yükümlüsün.\n\n'
      'Görevlerin:\n'
      '- Bordro, izin, sağlık randevusu gibi İK sorularına yardımcı olmak\n'
      '- CRM ve saha entegrasyonu konularında bilgi vermek\n'
      '- Aktif projeleri (Somali Su Kuyusu PRJ-AFRIKA-2026, Bursa Lojistik PRJ-BURSA-DESTEK) takip etmek\n'
      '- Tükenmişlik belirtilerini tespit edip kurum psikoloğuna yönlendirmek\n'
      '- Anlaşmalı firmalar ve sosyal kulüpler hakkında bilgi vermek\n'
      '- İş yeri hekimi Salı/Perşembe 10:00–15:00, Psikolog Pzt/Çarş 09:00–17:00\n\n'
      'Yanıtlarını kısa, sıcak ve kurumsal tonda tut. Türkçe yanıt ver. '
      'Hassas kişisel verileri paylaşma.';

  // Sohbet geçmişi (çok turlu konuşma için)
  final List<Map<String, dynamic>> _history = [];

  final List<Map<String, String>> _quickActions = [
    {'icon': '💰', 'label': 'Bordro Sorgula', 'msg': 'Bu ayki maaş bordromu görebilir miyim?'},
    {'icon': '🌴', 'label': 'İzin Talebi', 'msg': 'Yıllık izin talebinde bulunmak istiyorum.'},
    {'icon': '🏥', 'label': 'Randevu Al', 'msg': 'İş yeri hekimine randevu almak istiyorum.'},
    {'icon': '📍', 'label': 'Aktif Projeler', 'msg': 'Şu an aktif olan sahalar ve projeler neler?'},
  ];

  @override
  void initState() {
    super.initState();
    _dotAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Karşılama mesajı
    _messages.add(_ChatMessage(
      text: 'Merhaba! 👋 Ben **Hane AI** kurumsal asistanınızım.\n\n'
          'Bordro, izin, sağlık randevusu veya proje bilgisi için size '
          'yardımcı olmaya hazırım. Aşağıdaki hızlı butonları kullanabilir '
          'ya da doğrudan sorabilirsiniz.',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_apiKey == 'GEMINI_API_KEY_BURAYA') {
      setState(() {
        _messages.add(_ChatMessage(
          text: '🔑 **API Key eksik!**\n\n'
              '1. https://aistudio.google.com/apikey adresine gidin\n'
              '2. "Create API Key" butonuna tıklayın\n'
              '3. Key\'i kopyalayıp hane_agent_screen.dart dosyasındaki '
              '`_apiKey` alanına yapıştırın',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      });
      return;
    }

    final userMsg = text.trim();
    _inputCtrl.clear();

    // Geçmişe ekle
    _history.add({
      'role': 'user',
      'parts': [{'text': userMsg}],
    });

    setState(() {
      _messages.add(_ChatMessage(
        text: userMsg,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // Gemini REST API v1 çağrısı
      final body = jsonEncode({
        'systemInstruction': {
          'parts': [{'text': _systemPrompt}],
        },
        'contents': _history,
        'generationConfig': {
          'maxOutputTokens': 1024,
          'temperature': 0.7,
        },
      });

      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String? ??
            'Üzgünüm, bir yanıt oluşturulamadı.';

        // Cevabı da geçmişe ekle
        _history.add({
          'role': 'model',
          'parts': [{'text': reply}],
        });

        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(_ChatMessage(
              text: reply,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          _scrollToBottom();
        }
      } else {
        // HTTP hata kodu
        final errBody = jsonDecode(response.body);
        final errMsg = errBody['error']?['message'] ?? 'HTTP ${response.statusCode}';
        throw Exception(errMsg);
      }
    } on TimeoutException {
      _addError('⏱️ Yanıt süresi aşıldı. Lütfen tekrar deneyin.');
    } catch (e) {
      _addError('⚠️ Hata: ${e.toString().substring(0, e.toString().length.clamp(0, 120))}');
    }
  }

  void _addError(String msg) {
    // Hata durumunda history'den son user mesajını temizle
    if (_history.isNotEmpty && _history.last['role'] == 'user') {
      _history.removeLast();
    }
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: msg,
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _history.clear();
    });
    _messages.add(_ChatMessage(
      text: 'Sohbet sıfırlandı. 👋 Yeni bir konuda yardımcı olabilir miyim?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    setState(() {});
  }

  @override
  void dispose() {
    _dotAnimCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_messages.length <= 1) _buildQuickActions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.buttonDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(76),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/agent.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hane AI',
                style: TextStyle(
                  fontFamily: 'DINPro',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _dotAnimCtrl,
                    builder: (_, __) => Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          const Color(0xFF6EE7B7),
                          const Color(0xFF34D399),
                          _dotAnimCtrl.value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Gemini $_model · Aktif',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _resetChat,
          tooltip: 'Sohbeti Sıfırla',
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.buttonDark,
                border: Border.all(
                  color: AppColors.accent.withAlpha(77),
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/agent.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppColors.buttonDark
                    : msg.isError
                        ? const Color(0xFFFEF2F2)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: msg.isError
                    ? Border.all(color: const Color(0xFFFCA5A5))
                    : !msg.isUser
                        ? Border.all(color: AppColors.surfaceLight)
                        : null,
              ),
              child: _buildMessageText(msg),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageText(_ChatMessage msg) {
    final text = msg.text;
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: msg.isUser ? Colors.white : AppColors.textPrimary,
        ),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.buttonDark,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/agent.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _dotAnimCtrl,
                  builder: (_, __) {
                    final delay = i * 0.3;
                    final progress = ((_dotAnimCtrl.value + delay) % 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          AppColors.textMuted,
                          AppColors.accent,
                          progress,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HIZLI ERİŞİM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickActions.map((action) {
              return GestureDetector(
                onTap: () => _sendMessage(action['msg']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withAlpha(77),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(action['icon']!,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        action['label']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    hintStyle:
                        TextStyle(color: AppColors.textMuted, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_inputCtrl.text),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.buttonDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(89),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Mesaj Modeli
// ─────────────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
