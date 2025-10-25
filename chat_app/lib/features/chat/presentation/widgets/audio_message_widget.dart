import 'package:flutter/material.dart';

enum AudioPlayerState {
  stopped,
  loading,
  playing,
  paused,
  error,
}

class AudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final int duration;
  final bool isMe;
  final AudioPlayerState playerState;
  final String currentlyPlayingUrl;
  final VoidCallback onTap;

  const AudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.duration,
    required this.isMe,
    required this.playerState,
    required this.currentlyPlayingUrl,
    required this.onTap,
  });

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  @override
  Widget build(BuildContext context) {
    final isCurrentlyPlaying = widget.currentlyPlayingUrl == widget.audioUrl && 
        (widget.playerState == AudioPlayerState.playing || widget.playerState == AudioPlayerState.loading);
    final isCurrentlyPaused = widget.currentlyPlayingUrl == widget.audioUrl && widget.playerState == AudioPlayerState.paused;
    
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying 
              ? (widget.isMe ? Colors.blue.shade600 : Colors.grey[500])
              : isCurrentlyPaused
                  ? (widget.isMe ? Colors.blue.shade700 : Colors.grey[600])
                  : (widget.isMe ? Colors.blue.shade800 : Colors.grey[400]),
          borderRadius: BorderRadius.circular(20),
          border: (isCurrentlyPlaying || isCurrentlyPaused)
              ? Border.all(color: widget.isMe ? Colors.white : Colors.black, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getAudioIcon(),
              color: widget.isMe ? Colors.white : Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _getAudioText(),
              style: TextStyle(
                color: widget.isMe ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: (isCurrentlyPlaying || isCurrentlyPaused) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _formatDuration(widget.duration),
              style: TextStyle(
                color: widget.isMe ? Colors.white70 : Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAudioIcon() {
    if (widget.currentlyPlayingUrl != widget.audioUrl) {
      return Icons.play_arrow;
    }
    
    switch (widget.playerState) {
      case AudioPlayerState.loading:
        return Icons.hourglass_empty;
      case AudioPlayerState.playing:
        return Icons.pause;
      case AudioPlayerState.paused:
        return Icons.play_arrow;
      case AudioPlayerState.stopped:
      case AudioPlayerState.error:
        return Icons.play_arrow;
    }
  }

  String _getAudioText() {
    if (widget.currentlyPlayingUrl != widget.audioUrl) {
      return 'Voice message';
    }
    
    switch (widget.playerState) {
      case AudioPlayerState.loading:
        return 'Loading...';
      case AudioPlayerState.playing:
        return 'Playing...';
      case AudioPlayerState.paused:
        return 'Paused';
      case AudioPlayerState.stopped:
        return 'Voice message';
      case AudioPlayerState.error:
        return 'Error - Tap to retry';
    }
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
