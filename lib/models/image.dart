
import 'dart:convert';

ImageData imageDataFromJson(String str) => ImageData.fromJson(jsonDecode(str));
class ImageData {
  late int totalImages;
  late int totalPages;
  late List<Images> result;

  ImageData({
    required this.totalImages,
    required this.totalPages,
    required this.result,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      totalImages: json['total'],
      totalPages: json['total_pages'],
      result: List<Images>.from(json['results'].map((x) => Images.fromJson(x))),
    );
  }
}

class Images {
  late String imageUrl;

  Images({
    required this.imageUrl,
  });
  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      imageUrl: json['urls']['small'],
    );
  }

}
