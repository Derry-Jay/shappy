class ProductCategory {
  final String id, name;
  ProductCategory(this.id, this.name);

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      json["productcat_ID"].toString(),
      json["product_category"],
    );
  }

  static List<ProductCategory> fromJsonList(List list) {
    return list.map((item) => ProductCategory.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.id} ${this.name}';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(ProductCategory model) {
    return this?.id == model?.id;
  }

  @override
  String toString() => name;
}
