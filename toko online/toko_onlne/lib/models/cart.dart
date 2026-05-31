class Cart {
  final int? id;
  final int idMovie;
  final String title;
  final double voteAverage;
  final String overview;
  int quantity;
  final String posterPath;

  Cart({
    this.id,
    required this.idMovie,
    required this.title,
    required this.voteAverage,
    required this.overview,
    required this.quantity,
    required this.posterPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_movie': idMovie,
      'title': title,
      'voteaverage': voteAverage,
      'overview': overview,
      'quantity': quantity,
      'posterpath': posterPath,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'],
      idMovie: map['id_movie'],
      title: map['title'] ?? '',
      voteAverage: (map['voteaverage'] as num?)?.toDouble() ?? 0.0,
      overview: map['overview'] ?? '',
      quantity: map['quantity'] ?? 1,
      posterPath: map['posterpath'] ?? '',
    );
  }

  /// Konversi ke JSON untuk keperluan checkout
  Map<String, dynamic> toJson() {
    return {
      'barang_id': idMovie,  // id barang
      'qty': quantity,
    };
  }
}