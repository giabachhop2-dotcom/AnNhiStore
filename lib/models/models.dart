/// Product model — maps to table_product
class Product {
  final int id;
  final int? idList;
  final int? idCat;
  final int? idItem;
  final String? photo;
  final String? slugvi;
  final String? namevi;
  final String? nameen;
  final String? descvi;
  final String? descen;
  final String? contentvi;
  final String? contenten;
  final String? code;
  final double? regularPrice;
  final double? salePrice;
  final double? discount;
  final int? view;
  final String? status;
  final String? type;

  Product({
    required this.id,
    this.idList,
    this.idCat,
    this.idItem,
    this.photo,
    this.slugvi,
    this.namevi,
    this.nameen,
    this.descvi,
    this.descen,
    this.contentvi,
    this.contenten,
    this.code,
    this.regularPrice,
    this.salePrice,
    this.discount,
    this.view,
    this.status,
    this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      idList: json['id_list'] as int?,
      idCat: json['id_cat'] as int?,
      idItem: json['id_item'] as int?,
      photo: json['photo'] as String?,
      slugvi: json['slugvi'] as String?,
      namevi: json['namevi'] as String?,
      nameen: json['nameen'] as String?,
      descvi: json['descvi'] as String?,
      descen: json['descen'] as String?,
      contentvi: json['contentvi'] as String?,
      contenten: json['contenten'] as String?,
      code: json['code'] as String?,
      regularPrice: (json['regular_price'] as num?)?.toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      view: json['view'] as int?,
      status: json['status'] as String?,
      type: json['type'] as String?,
    );
  }

  /// Display price — sale price if available, else regular
  double get displayPrice => (salePrice != null && salePrice! > 0) ? salePrice! : (regularPrice ?? 0);

  /// Whether product is on sale
  bool get isOnSale => salePrice != null && salePrice! > 0 && regularPrice != null && regularPrice! > salePrice!;
}

/// Product category tree node
class ProductCategory {
  final int id;
  final String? namevi;
  final String? nameen;
  final String? slugvi;
  final String? photo;
  final String? type;

  ProductCategory({
    required this.id,
    this.namevi,
    this.nameen,
    this.slugvi,
    this.photo,
    this.type,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      namevi: json['namevi'] as String?,
      nameen: json['nameen'] as String?,
      slugvi: json['slugvi'] as String?,
      photo: json['photo'] as String?,
      type: json['type'] as String?,
    );
  }
}

/// News / Blog article
class NewsArticle {
  final int id;
  final int? idList;
  final String? photo;
  final String? slugvi;
  final String? namevi;
  final String? nameen;
  final String? descvi;
  final String? descen;
  final String? contentvi;
  final String? contenten;
  final int? view;
  final String? type;
  final int? dateCreated;

  NewsArticle({
    required this.id,
    this.idList,
    this.photo,
    this.slugvi,
    this.namevi,
    this.nameen,
    this.descvi,
    this.descen,
    this.contentvi,
    this.contenten,
    this.view,
    this.type,
    this.dateCreated,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as int,
      idList: json['id_list'] as int?,
      photo: json['photo'] as String?,
      slugvi: json['slugvi'] as String?,
      namevi: json['namevi'] as String?,
      nameen: json['nameen'] as String?,
      descvi: json['descvi'] as String?,
      descen: json['descen'] as String?,
      contentvi: json['contentvi'] as String?,
      contenten: json['contenten'] as String?,
      view: json['view'] as int?,
      type: json['type'] as String?,
      dateCreated: json['date_created'] as int?,
    );
  }
}

/// Photo / Slide / Banner
class PhotoItem {
  final int id;
  final String? photo;
  final String? namevi;
  final String? nameen;
  final String? descvi;
  final String? link;
  final String? type;

  PhotoItem({
    required this.id,
    this.photo,
    this.namevi,
    this.nameen,
    this.descvi,
    this.link,
    this.type,
  });

  factory PhotoItem.fromJson(Map<String, dynamic> json) {
    return PhotoItem(
      id: json['id'] as int,
      photo: json['photo'] as String?,
      namevi: json['namevi'] as String?,
      nameen: json['nameen'] as String?,
      descvi: json['descvi'] as String?,
      link: json['link'] as String?,
      type: json['type'] as String?,
    );
  }
}

/// Order — for creating orders
class Order {
  final int? id;
  final String? code;
  final String fullname;
  final String phone;
  final String? email;
  final String? address;
  final int? city;
  final int? district;
  final int? ward;
  final String? requirements;
  final double tempPrice;
  final double totalPrice;
  final double? shipPrice;
  final int? orderPayment;
  final int? orderStatus;
  final List<OrderItem> items;

  Order({
    this.id,
    this.code,
    required this.fullname,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.district,
    this.ward,
    this.requirements,
    required this.tempPrice,
    required this.totalPrice,
    this.shipPrice,
    this.orderPayment,
    this.orderStatus,
    this.items = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'phone': phone,
      'email': email ?? '',
      'address': address ?? '',
      'city': city ?? 0,
      'district': district ?? 0,
      'ward': ward ?? 0,
      'requirements': requirements ?? '',
      'temp_price': tempPrice,
      'total_price': totalPrice,
      'ship_price': shipPrice ?? 0,
      'order_payment': orderPayment ?? 0,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int idProduct;
  final String name;
  final String? photo;
  final String? code;
  final double regularPrice;
  final double salePrice;
  final int quantity;

  OrderItem({
    required this.idProduct,
    required this.name,
    this.photo,
    this.code,
    required this.regularPrice,
    required this.salePrice,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      'name': name,
      'photo': photo ?? '',
      'code': code ?? '',
      'regular_price': regularPrice,
      'sale_price': salePrice,
      'quantity': quantity,
    };
  }
}

/// Cart item (local state)
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get lineTotal => product.displayPrice * quantity;
}
