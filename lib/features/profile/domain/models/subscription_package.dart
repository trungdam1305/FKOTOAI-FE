class SubscriptionPackage {
  final int packageId;
  final String packageCode;
  final String packageName;
  final double price;
  final int durationDays;
  final String description;
  final String status;

  SubscriptionPackage({
    required this.packageId,
    required this.packageCode,
    required this.packageName,
    required this.price,
    required this.durationDays,
    required this.description,
    required this.status,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      // Hỗ trợ đọc cả camelCase (Spring Boot) và snake_case
      packageId: json['packageId'] ?? json['package_id'] ?? 0,
      packageCode: json['packageCode'] ?? json['package_code'] ?? '',
      packageName: json['packageName'] ?? json['package_name'] ?? '',

      // Xử lý an toàn cho kiểu số (tránh lỗi null hoặc parse String sang double)
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,

      durationDays: json['durationDays'] ?? json['duration_days'] ?? 0,

      // Đã fix lỗi copy-paste nhầm key
      description: json['description'] ?? '',
      status: json['status'] ?? '',
    );
  }
}