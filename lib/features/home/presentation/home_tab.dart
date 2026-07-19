import 'package:flutter/material.dart';
// TODO: Thay đổi đường dẫn import này cho khớp với thư mục của bạn
import '../data/home_models.dart';
import '../data/home_api_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Bảng màu giữ nguyên nhưng thêm một số tone pastel nhạt để làm nền
  final Color primaryBlue = const Color(0xFF3B40E8);
  final Color textBlack = const Color(0xFF2D2D2D); // Màu đen than, mềm mắt hơn đen tuyền
  final Color textGrey = const Color(0xFF757575);
  final Color starYellow = const Color(0xFFFFB300);
  final Color bgCard = const Color(0xFFF8F9FA); // Màu nền xám trắng như giấy vở

  final HomeApiService _apiService = HomeApiService();
  late Future<Map<String, dynamic>> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _apiService.fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _homeDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi kết nối: ${snapshot.error}', style: TextStyle(fontFamily: 'Nunito', color: textBlack)));
        }

        final data = snapshot.data!;
        final dashboardSummary = DashboardSummary.fromJson(data['dashboard_summary']);
        final List<WeakVocab> weakVocabs = (data['weak_vocabularies'] as List)
            .map((v) => WeakVocab.fromJson(v))
            .toList();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Gợi ý học tập', Icons.lightbulb_outline_rounded, Colors.amber.shade600),
                const SizedBox(height: 16),
                _buildStaticFeatures(),
                const SizedBox(height: 32),

                _buildSectionTitle('Ôn tập từ vựng yếu', Icons.menu_book_rounded, primaryBlue),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220, // Chỉnh lại chiều cao thẻ từ vựng
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: weakVocabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildVocabCard(weakVocabs[index]);
                    },
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('Tiến độ của bạn', Icons.insights_rounded, Colors.teal),
                const SizedBox(height: 16),
                _buildLargeDashboardCard(dashboardSummary),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tiêu đề mang phong cách sổ tay: Thanh vạch dọc + Icon mềm mại + Chữ đơn sắc
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Vạch dọc tạo điểm nhấn mộc mạc
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textBlack,
            fontFamily: 'Nunito', // Thay đổi toàn bộ sang font bo tròn
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildStaticFeatures() {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildFeatureCard(
            imageUrl: 'https://i.pinimg.com/736x/36/c6/bc/36c6bc4fd3836784c474d5bd1d4df729.jpg?w=500&q=80', // Hình minh họa sổ sách
            title: 'Flashcards N5',
            subtitle: 'Lật thẻ & Ghi nhớ',
            rating: 5,
            reviews: '2.1k',
          ),
          const SizedBox(width: 16),
          _buildFeatureCard(
            imageUrl: 'https://images.unsplash.com/photo-1528164344705-47542687000d?w=500&q=80',
            title: 'Thi thử JLPT N4',
            subtitle: 'Đề thi thật mô phỏng',
            rating: 5,
            reviews: '3.3k',
          ),
        ],
      ),
    );
  }

  // Thẻ tính năng: Lược bỏ các nút bấm rườm rà, bo góc lớn hơn, bóng đổ cực nhẹ
  Widget _buildFeatureCard({required String imageUrl, required String title, required String subtitle, required int rating, required String reviews}) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito'),
                    maxLines: 1
                ),
                const SizedBox(height: 4),
                Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: textGrey, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                    maxLines: 1
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: starYellow, size: 18),
                    const SizedBox(width: 4),
                    Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textBlack, fontFamily: 'Nunito')
                    ),
                    const SizedBox(width: 4),
                    Text(
                        '($reviews)',
                        style: TextStyle(fontSize: 13, color: textGrey, fontFamily: 'Nunito')
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐️ ĐÂY LÀ PHẦN "MAZII" NHẤT: Thẻ từ vựng giống hệt một cuốn từ điển mini
  Widget _buildVocabCard(WeakVocab vocab) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgCard, // Nền xám giấy
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row chứa chữ Hán Việt và Cảnh báo số lần sai
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    vocab.hanViet,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryBlue, letterSpacing: 1.0, fontFamily: 'Nunito')
                ),
              ),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded, size: 14, color: Colors.red.shade400),
                  const SizedBox(width: 4),
                  Text(
                      'Sai ${vocab.wrongCount} lần',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade400, fontFamily: 'Nunito')
                  ),
                ],
              )
            ],
          ),
          const Spacer(),

          // Trọng tâm thẻ: Chữ Kanji/Hiragana cực lớn ở giữa
          Center(
            child: Text(
                vocab.word,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500, color: textBlack, fontFamily: 'Nunito') // w500 để chữ Nhật thanh thoát
            ),
          ),
          Center(
            child: Text(
                vocab.reading,
                style: TextStyle(fontSize: 16, color: textGrey, fontWeight: FontWeight.w600, fontFamily: 'Nunito')
            ),
          ),

          const Spacer(),

          // Nghĩa tiếng Việt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1, style: BorderStyle.solid)), // Vạch kẻ ngang mỏng
            ),
            child: Text(
                vocab.exampleMeaning,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textBlack, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }

  // Thẻ Dashboard được làm phẳng (Flat UI), thân thiện và gọn gàng hơn
  Widget _buildLargeDashboardCard(DashboardSummary summary) {
    int percentView = (summary.progressPercent * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade100) // Vòng nền xám nhạt
                    ),
                    CircularProgressIndicator(
                        value: summary.progressPercent,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                        strokeCap: StrokeCap.round
                    ),
                    Center(
                        child: Text(
                            '$percentView%',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primaryBlue, fontFamily: 'Nunito')
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Chinh phục tiếng Nhật N5',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textBlack, fontFamily: 'Nunito')
                    ),
                    const SizedBox(height: 6),
                    Text(
                        'Gần đây: ${summary.recentActivityStr}',
                        style: TextStyle(fontSize: 14, color: textGrey, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Khối thống kê Streak & Hạng
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                          '${summary.streakCount} ngày liên tiếp',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textBlack, fontFamily: 'Nunito')
                      )
                    ]
                ),
                Container(width: 1, height: 20, color: Colors.grey.shade300),
                Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                          '${summary.rankPoints} Điểm',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textBlack, fontFamily: 'Nunito')
                      )
                    ]
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nút bấm bo tròn dẹp (Pill shape)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)), // Bo tròn 2 bên
                elevation: 0, // Bỏ đổ bóng để phẳng hoàn toàn
              ),
              child: const Text(
                  'Tiếp tục học',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Nunito')
              ),
            ),
          ),
        ],
      ),
    );
  }
}