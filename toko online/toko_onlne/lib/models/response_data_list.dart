class ResponseDataList {
  bool status;
  String message;
  List? data;
  bool isUnauthorized;

  ResponseDataList({
    required this.status,
    required this.message,
    this.data,
    this.isUnauthorized = false,
  });
}