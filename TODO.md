# TODO - Ubah Project Menjadi Toko Kasir IntDex

- [ ] Analisis awal sudah dilakukan (review Postman + baca file utama).
- [ ] Rename branding/tema: CinemaX/CINEMAX -> IntDex di `main.dart`, `login_view.dart`, `dashboard_view.dart`, dan komponen terkait.
- [ ] Rename struktur admin view: `movie_view.dart` -> konsep “Kelola Barang”.
- [ ] Samakan endpoint kasir:
  - [ ] ambil daftar barang dari `user/getbarang` (kasir)
  - [ ] transaksi ke `user/transaksi` dengan body `pesan[{barang_id, qty}]`
  - [ ] history dari `user/history_trans`
- [ ] Samakan endpoint admin:
  - [ ] CRUD barang memakai `admin/getbarang`, `admin/insertbarang`, `admin/updatebarang/{id}`, `admin/hapusbarang/{id}`.
- [ ] Update/extend service layer (`product_service.dart`) agar mendukung user transaksi & history + CRUD admin.
- [ ] Update model tambahan bila diperlukan (mis. transaksi/history).
- [ ] Rename/adjust UI `product_view.dart` dan `pesan_view.dart` agar benar-benar sesuai flow kasir.
- [ ] Rename/adjust UI yang masih bertema movie/cinema menjadi toko kasir.
- [x] Rename file/metadata Postman collection: ubah `name` pada JSON menjadi `IntDex`.
- [x] Rename brand Flutter: `main.dart` dan `login_view.dart` menjadi **IntDex**.
- [ ] Jalankan `flutter analyze` & `flutter run` untuk memastikan build sukses (akan diuji setelah perubahan service/UI).

