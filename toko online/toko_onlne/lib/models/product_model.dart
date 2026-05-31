class ProductModel {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final int harga;
  final int stok;
  final String image;

  ProductModel({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse((json['id'] ?? json['id_barang'] ?? 0).toString()) ?? 0,
      namaBarang: json['nama_barang'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      image: _formatImage(json['image'] ?? ''),
    );
  }

  static String _formatImage(String image) {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return 'https://learn.smktelkom-mlg.sch.id/toko/public/images/$image';
  }

}