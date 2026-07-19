import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:bim/core/theme/app_colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String title;

  const VideoPlayerScreen({super.key, required this.url, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      print("Khởi tạo video từ CDN với Header giả lập trình duyệt: ${widget.url}");

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Referer': 'https://dungmori.com/',
          'Origin': 'https://dungmori.com',
        },
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,

        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),

        placeholder: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),

        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Lỗi phát từ CDN: $errorMessage\n(Có thể link luồng đã hết hạn)',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMsg = 'Không thể kết nối trực tiếp đến luồng CDN: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.midnightBlue,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildVideoBody(),
    );
  }

  Widget _buildVideoBody() {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _errorMsg,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Đang tải luồng video trực tiếp từ CDN...',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          )
        ],
      ),
    );
  }
}