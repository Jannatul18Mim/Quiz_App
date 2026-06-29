import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class MeetingRoomScreen extends StatefulWidget {
  final bool startAudio;
  final bool startVideo;
  const MeetingRoomScreen({
    super.key,
    required this.startAudio,
    required this.startVideo,
  });

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  CameraController? _roomCameraController;
  bool isMuted = false;
  bool isVideoOff = false;
  bool _isRoomCameraInitialized = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    isMuted = !widget.startAudio;
    isVideoOff = !widget.startVideo;
    _initRoomCamera();
  }

  Future<void> _initRoomCamera() async {
    try {
      debugPrint('Initializing room camera...');
      final cameras = await availableCameras();
      debugPrint('Available cameras: ${cameras.length}');

      if (cameras.isEmpty) {
        setState(() {
          _cameraError = 'No cameras found on device';
        });
        return;
      }

      CameraDescription frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _roomCameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _roomCameraController!.initialize();
      debugPrint('Camera initialized successfully');

      if (mounted) {
        setState(() {
          _isRoomCameraInitialized = true;
          _cameraError = null;
        });
      }
    } catch (e) {
      debugPrint("Room camera error: $e");
      if (mounted) {
        setState(() {
          _cameraError = 'Failed to initialize camera: $e';
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera Error: $e')));
    }
  }

  Future<void> _retryCamera() async {
    setState(() {
      _isRoomCameraInitialized = false;
      _cameraError = null;
    });
    _roomCameraController?.dispose();
    _roomCameraController = null;
    await _initRoomCamera();
  }

  @override
  void dispose() {
    _roomCameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D21),
      body: SafeArea(
        child: Column(
          children: [
            // টপ বার (image_ced1d4.png)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QuizAid',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E72ED),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // মেইন লাইভ ভিডিও ওয়ার্কস্পেস (image_ced1d4.png)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    if (_cameraError != null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.videocam_off,
                              color: Colors.white54,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _cameraError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _retryCamera,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (!isVideoOff &&
                        _isRoomCameraInitialized &&
                        _roomCameraController != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: AspectRatio(
                            aspectRatio:
                                _roomCameraController!.value.aspectRatio,
                            child: CameraPreview(_roomCameraController!),
                          ),
                        ),
                      )
                    else if (!isVideoOff && !_isRoomCameraInitialized)
                      const Center(child: CircularProgressIndicator())
                    else
                      const Center(
                        child: Text(
                          'Video is turned off',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),

                    // ইউজার নেম ট্যাগ (image_ced1d4.png অনুযায়ী বটম লেফট-এ)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black54,
                        child: const Text(
                          'Jannatul Mim',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // বটম কন্ট্রোল বার (image_ced1d4.png অনুযায়ী)
            Container(
              color: const Color(0xFF1A1D21),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildWorkspaceAction(
                      icon: isMuted ? Icons.mic_off : Icons.mic,
                      label: 'Audio',
                      color: isMuted ? Colors.red : Colors.white,
                      onTap: () => setState(() => isMuted = !isMuted),
                    ),
                    _buildWorkspaceAction(
                      icon: isVideoOff ? Icons.videocam_off : Icons.videocam,
                      label: 'Video',
                      color: isVideoOff ? Colors.red : Colors.white,
                      onTap: () => setState(() => isVideoOff = !isVideoOff),
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.people_outline,
                      label: 'Participants',
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat',
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.emoji_emotions_outlined,
                      label: 'React',
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.ios_share,
                      label: 'Share',
                      color: Colors.greenAccent,
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.security,
                      label: 'Host tools',
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.info_outline,
                      label: 'Meeting info',
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.more_horiz,
                      label: 'More',
                    ),
                    _buildWorkspaceAction(
                      icon: Icons.cancel,
                      label: 'End',
                      color: Colors.redAccent,
                      onTap: () => _showEndMeetingBottomSheet(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceAction({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndMeetingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF22252A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'End meeting for all',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3139),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Leave meeting',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
