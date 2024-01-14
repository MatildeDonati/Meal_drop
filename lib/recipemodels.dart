class RecipeModels {

  String label;
  String image;
  String source;
  String url;

  RecipeModels({
    required this.url,
    required this.source,
    required this.image,
    required this.label});

  factory RecipeModels.fromMap(Map<String, dynamic> parsedJson){
    return RecipeModels(
      url: parsedJson["url"],
      label: parsedJson["label"],
      image: parsedJson["image"],
      source: parsedJson["source"],
    );
  }
}