import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VideoCallScreen extends StatefulWidget {
  final VoidCallback onEndCall;

  const VideoCallScreen({super.key, required this.onEndCall});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _showChat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main video area
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.darkBlue, AppTheme.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('👩‍⚖️', style: TextStyle(fontSize: 120)),
                  SizedBox(height: 24),
                  Text(
                    'Dr. Sarah Johnson',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Criminal Law Specialist',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          // Timer
          Positioned(
            top: 48,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '32:45',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // User video (PiP)
          Positioned(
            top: 48,
            right: 16,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text('👤', style: TextStyle(fontSize: 40)),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic,
                            onPressed: () =>
                                setState(() => _isMuted = !_isMuted),
                            isActive: _isMuted,
                          ),
                          _buildControlButton(
                            icon: _isVideoOff
                                ? Icons.videocam_off
                                : Icons.videocam,
                            onPressed: () =>
                                setState(() => _isVideoOff = !_isVideoOff),
                            isActive: _isVideoOff,
                          ),
                          _buildControlButton(
                            icon: Icons.call_end,
                            onPressed: widget.onEndCall,
                            isActive: true,
                            size: 64,
                          ),
                          _buildControlButton(
                            icon: Icons.chat_bubble_outline,
                            onPressed: () =>
                                setState(() => _showChat = !_showChat),
                          ),
                          _buildControlButton(
                            icon: Icons.more_vert,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            _isMuted ? 'Muted' : 'Mute',
                            style: TextStyle(
                              color: _isMuted
                                  ? Colors.red[300]
                                  : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _isVideoOff ? 'Camera Off' : 'Camera',
                            style: TextStyle(
                              color: _isVideoOff
                                  ? Colors.red[300]
                                  : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 50),
                          const Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            'More',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Chat overlay
          if (_showChat)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 320,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Chat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _showChat = false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
