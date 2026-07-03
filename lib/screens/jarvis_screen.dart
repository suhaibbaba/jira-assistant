import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../services/jarvis_controller.dart';

class JarvisScreen extends StatefulWidget {
  const JarvisScreen({super.key});
  @override
  State<JarvisScreen> createState() => _JarvisScreenState();
}

class _JarvisScreenState extends State<JarvisScreen> {
  late JarvisController jarvis;
  final _input = TextEditingController();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    jarvis = JarvisController(
      getTickets: () => app.allTickets,
      getLists: () => app.lists,
      getTracker: () => app.tracker,
      getSettings: () => app.settings,
      getAiKey: () => app.aiApiKey,
      persistLists: () => app.persistLists(),
    );
    jarvis.init().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    jarvis.dispose();
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    jarvis.handle(text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: jarvis,
      child: Scaffold(
        backgroundColor: AppColors.bgContent,
        appBar: AppBar(
          backgroundColor: AppColors.bgSidebar,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Row(children: [
            Text('🦾 Jarvis',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(width: 6),
            Text('· your Jira assistant',
                style: TextStyle(fontSize: 12, color: AppColors.text2)),
          ]),
          shape: const Border(
              bottom: BorderSide(color: AppColors.separator, width: 0.5)),
        ),
        body: Column(
          children: [
            _quickChips(),
            const Divider(height: 0.5, color: AppColors.separator),
            Expanded(child: _transcript()),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _quickChips() {
    final examples = [
      'Organize my day',
      "What did I forget?",
      'Show my Follow Up list',
      'What have I logged today?',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.bgSidebar,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in examples)
            GestureDetector(
              onTap: () => jarvis.handle(e),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.separator),
                ),
                child: Text(e,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.accent)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _transcript() {
    return Consumer<JarvisController>(
      builder: (_, j, __) {
        final lines = j.transcript;
        if (lines.isEmpty && j.partialTranscript.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🦾', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text('Tap the mic and ask me anything',
                    style: TextStyle(fontSize: 14, color: AppColors.text2)),
                const SizedBox(height: 4),
                Text(
                    'e.g. “organize my day”, “log 2 hours on ABC-1 for development”',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.text3)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          itemCount: lines.length + (j.partialTranscript.isNotEmpty ? 1 : 0),
          itemBuilder: (_, i) {
            if (i < lines.length) {
              final line = lines[i];
              return _bubble(line.text, line.fromUser);
            }
            return _bubble(j.partialTranscript, true, partial: true);
          },
        );
      },
    );
  }

  Widget _bubble(String text, bool fromUser, {bool partial = false}) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: fromUser
              ? (partial ? AppColors.accent.withOpacity(0.5) : AppColors.accent)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: fromUser
              ? null
              : Border.all(color: AppColors.separator, width: 0.5),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: fromUser ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Consumer<JarvisController>(
      builder: (_, j, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.bgSidebar,
            border:
                Border(top: BorderSide(color: AppColors.separator, width: 0.5)),
          ),
          child: Row(
            children: [
              // Mic button — tap to start, tap to stop.
              GestureDetector(
                onTap: _ready ? () => j.toggleListening() : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: j.listening ? const Color(0xFFFF3B30) : AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: j.listening
                        ? [
                            BoxShadow(
                                color: const Color(0xFFFF3B30).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2)
                          ]
                        : null,
                  ),
                  child: Icon(j.listening ? Icons.stop : Icons.mic,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _input,
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: j.listening
                        ? 'Listening…'
                        : 'Type a command or question…',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide:
                          const BorderSide(color: AppColors.separator),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.accent),
                onPressed: _send,
              ),
            ],
          ),
        );
      },
    );
  }
}
