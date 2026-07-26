import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    required this.controller,
    required this.onQueryChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final FocusNode _focusNode = FocusNode();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _focusNode.addListener(() => setState(() {}));
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'ar_SA',
          onResult: (val) {
            setState(() {
              widget.controller.text = val.recognizedWords;
              widget.onQueryChanged(val.recognizedWords);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;

    // Choose border color based on state
    final Color borderColor = _isListening
        ? Colors.redAccent
        : (isFocused ? AppColors.primary : Colors.transparent);

    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      onChanged: widget.onQueryChanged,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        hintText: _isListening ? 'جاري الاستماع...' : '...ابحث عن مطعم',
        hintStyle: TextStyle(
          color: _isListening ? Colors.redAccent : AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none_rounded,
            color: _isListening ? Colors.redAccent : AppColors.textSecondary,
          ),
          onPressed: _listen,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),

        // 🚀 Native OutlineInputBorder handles background fill + rounded border perfectly together without gaps!
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
    );
  }
}
