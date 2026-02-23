import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceNotePlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String? fileName;
  final num? durationSeconds;
  final bool isSender;

  const VoiceNotePlayerWidget({
    super.key,
    required this.audioUrl,
    this.fileName,
    this.durationSeconds,
    required this.isSender,
  });

  @override
  State<VoiceNotePlayerWidget> createState() => _VoiceNotePlayerWidgetState();
}

class _VoiceNotePlayerWidgetState extends State<VoiceNotePlayerWidget> {
  bool _isPlaying = false;
  double _progress = 0.0;
  Timer? _timer;
  late int _totalDuration;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _totalDuration = (widget.durationSeconds ?? 15).toInt();
    if (_totalDuration <= 0) _totalDuration = 15;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => _isPlaying = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) return;
      setState(() {
        _elapsed += 200;
        _progress = (_elapsed / 1000) / _totalDuration;
        if (_progress >= 1.0) {
          _progress = 0.0;
          _elapsed = 0;
          _isPlaying = false;
          t.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isSender ? Colors.white : Colors.white.withValues(alpha: 0.9);
    final subColor = widget.isSender ? Colors.white70 : Colors.white60;
    final activeColor = widget.isSender ? Colors.white : const Color(0xFF818CF8);

    final displayedSeconds = _isPlaying
        ? (_elapsed ~/ 1000)
        : _totalDuration;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isSender
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: widget.isSender ? const Color(0xFF4F46E5) : Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Progress Bar & Duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.mic_rounded,
                          size: 13,
                          color: subColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Voice Note",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDuration(displayedSeconds),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Progress Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// [mod:2026-02-23T17:30:00+05:30]
