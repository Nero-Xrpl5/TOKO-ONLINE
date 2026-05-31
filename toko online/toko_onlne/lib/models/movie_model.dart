/// Untuk kasir: "movie" di sini adalah barang yang ditampilkan di PesanView
class MovieModel {
  final int id;
  final String title;       // nama_barang
  final double voteAverage; // harga (dipakai sebagai "nilai")
  final String overview;    // deskripsi
  final String posterPath;  // image

  MovieModel({
    required this.id,
    required this.title,
    required this.voteAverage,
    required this.overview,
    required this.posterPath,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['nama_barang'] ?? '',
      voteAverage: double.tryParse(json['harga'].toString()) ?? 0.0,
      overview: json['deskripsi'] ?? '',
      posterPath: json['image'] ?? '',
    );
  }
}