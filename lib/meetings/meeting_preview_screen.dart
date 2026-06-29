import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'meeting_room_screen.dart';

class MeetingPreviewScreen extends StatefulWidget {
  const MeetingPreviewScreen({super.key});

  @override
  State<MeetingPreviewScreen> createState() => _MeetingPreviewScreenState();
}

class _MeetingPreviewScreenState extends State<MeetingPreviewScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool isAudioEnabled = true;
  bool isVideoEnabled = true;
  bool alwaysShowPreview = true;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        CameraDescription frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset
              .high, // রেজোলিউশন হাই করে দেওয়া হলো যাতে ক্রপিং ক্লিয়ার থাকে
          enableAudio: true,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    setState(() {
      isVideoEnabled = !isVideoEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // --- টপ বার ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue,
                    child: Text(
                      'QuizAid',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Meeting Room",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // --- ভিডিও প্রিভিউ এরিয়া (OverflowBox দিয়ে ফিক্সড করা) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors
                        .black, // যেকোনো অবিরত ব্যাকগ্রাউন্ড পিওর ব্ল্যাক রাখবে
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ক্যামেরা উইন্ডো সলিউশন
                      if (isVideoEnabled &&
                          _isCameraInitialized &&
                          _cameraController != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: _cameraController!.value.aspectRatio,
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      else
                        const Center(
                          child: Text(
                            'Video Paused',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // অডিও এবং ভিডিও ফ্লোটিং কন্ট্রোলস
                      Positioned(
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildPreviewToggleButton(
                                icon: isAudioEnabled
                                    ? Icons.mic
                                    : Icons.mic_off,
                                label: 'Audio',
                                isActive: isAudioEnabled,
                                onTap: () => setState(
                                  () => isAudioEnabled = !isAudioEnabled,
                                ),
                              ),
                              const SizedBox(width: 24),
                              _buildPreviewToggleButton(
                                icon: isVideoEnabled
                                    ? Icons.videocam
                                    : Icons.videocam_off,
                                label: 'Video',
                                isActive: isVideoEnabled,
                                onTap: _toggleVideo,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFakeDropdown(Icons.mic, 'Built-in Microphone'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFakeDropdown(Icons.videocam, 'Front Camera'),
                  ),
                ],
              ),
            ),

            // --- বটম অ্যাকশন বার (Start Button) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: alwaysShowPreview,
                          activeColor: Colors.blue,
                          onChanged: (val) =>
                              setState(() => alwaysShowPreview = val!),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Always show this preview when joining',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1866EE),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetingRoomScreen(
                            startAudio: isAudioEnabled,
                            startVideo: isVideoEnabled,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.red, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeDropdown(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
