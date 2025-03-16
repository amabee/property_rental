class Property {
  final String id;
  final String title;
  final String address;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final int area;
  final String imageUrl;
  final bool isAvailable;

  Property({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrl,
    required this.isAvailable,
  });
}
