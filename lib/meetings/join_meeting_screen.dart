import 'package:flutter/material.dart';
import 'meeting_room_screen.dart'; // আপনার মিটিং রুম স্ক্রিনের সঠিক পাথটি নিশ্চিত করুন

class JoinMeetingScreen extends StatefulWidget {
  const JoinMeetingScreen({super.key});

  @override
  State<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  final _meetingIdController = TextEditingController();
  final _nameController = TextEditingController(
    text: "Jannatul Mim",
  ); // ডিফল্ট নাম

  bool _isJoinButtonActive = false;
  bool _dontConnectAudio = false;
  bool _turnOffVideo = false;

  @override
  void initState() {
    super.initState();
    // Meeting ID ইনপুট ট্র্যাক করার জন্য লিসেনার
    _meetingIdController.addListener(_updateJoinButtonState);
  }

  void _updateJoinButtonState() {
    setState(() {
      // মিটিং আইডি খালি না থাকলে বাটন ব্লু (Active) হবে
      _isJoinButtonActive = _meetingIdController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _meetingIdController.removeListener(_updateJoinButtonState);
    _meetingIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE), // লাইট থিম ব্যাকগ্রাউন্ড
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Join a Meeting',
          style: TextStyle(
            color: Color(0xFF111E38),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- মিটিং আইডি ইনপুট ফিল্ড ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _meetingIdController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Meeting ID',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ইনভাইট লিংক হেল্পার টেক্সট
            Center(
              child: Text(
                'Join with a personal link name',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- ডিসপ্লে নেম ইনপুট ফিল্ড ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Your Name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- ডাইনামিক জয়েন বাটন (Meeting ID দিলে ব্লু হবে) ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isJoinButtonActive
                      ? const Color(0xFF0E72ED)
                      : const Color(0xFFE2E8F0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isJoinButtonActive
                    ? () {
                        // জয়েন বাটনে ক্লিক করলে মিটিং রুমে নিয়ে যাবে
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeetingRoomScreen(
                              startAudio: !_dontConnectAudio,
                              startVideo: !_turnOffVideo,
                            ),
                          ),
                        );
                      }
                    : null, // ডিজেবল থাকলে ক্লিক কাজ করবে না
                child: Text(
                  'Join',
                  style: TextStyle(
                    color: _isJoinButtonActive
                        ? Colors.white
                        : Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "If you received an invitation link, tap on the link again to join the meeting",
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 35),

            // --- জয়েন অপশনস হেডার ---
            const Text(
              'JOIN OPTIONS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // অডিও এবং ভিডিও টগল প্যানেল
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildToggleRow(
                    label: "Don't Connect To Audio",
                    value: _dontConnectAudio,
                    onChanged: (val) => setState(() => _dontConnectAudio = val),
                  ),
                  Divider(height: 1, color: Colors.grey[100]),
                  _buildToggleRow(
                    label: "Turn Off My Video",
                    value: _turnOffVideo,
                    onChanged: (val) => setState(() => _turnOffVideo = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111E38),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF0E72ED),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
