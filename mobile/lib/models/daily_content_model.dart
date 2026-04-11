class DailyContentModel {
  final String id;
  final String title;
  final String content;
  final String typeName;
  final List<String> categories;

  DailyContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.typeName,
    required this.categories,
  });

  factory DailyContentModel.fromJson(Map<String, dynamic> json) {
    // Extract categories names
    List<String> categoryList = [];
    final jsonCategories = json['categories'] ?? json['Categories'];
    if (jsonCategories is List) {
      categoryList = jsonCategories.map((c) {
        if (c is Map) {
          return (c['name'] ?? c['Name'] ?? '').toString();
        }
        return c.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return DailyContentModel(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? 'Bilinmiyor').toString(),
      content: (json['content'] ?? json['Content'] ?? '').toString(),
      typeName: (json['typeName'] ?? json['TypeName'] ?? '').toString(),
      categories: categoryList,
    );
  }
}
