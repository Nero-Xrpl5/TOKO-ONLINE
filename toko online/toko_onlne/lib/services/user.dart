import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toko_online/models/response_data_map.dart';
import 'package:toko_online/models/user_login.dart';
import 'package:toko_online/services/url.dart' as url;

class UserService {
  Future loginUser(data) async {
    var uri = Uri.parse("${url.BaseUrl}/auth/login");
    var response = await http.post(uri, body: data);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"] == true) {
        UserLogin userLogin = UserLogin(
          status: data["status"],
          token: data["token"],
          message: data["message"],
          id: data["user"]["id"],
          nama_user: data["user"]["nama_user"],
          email: data["user"]["email"],
          role: data["user"]["role"],
        );
        await userLogin.prefs();
        ResponseDataMap response = ResponseDataMap(
          status: true,
          message: "Sukses login user",
          data: data,
        );
        return response;
      } else {
        ResponseDataMap response = ResponseDataMap(
          status: false,
          message: 'Email dan password salah',
        );
        return response;
      }
    } else {
      ResponseDataMap responseMap = ResponseDataMap(
        status: false,
        message: "gagal login user dengan code error${response.statusCode}",
      );
      return responseMap;
    }
  }

  // Fungsi registerUser tetap seperti modul (opsional)
  Future registerUser(data) async {
    var uri = Uri.parse("${url.BaseUrl}/auth/register");
    var response = await http.post(uri, body: data);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"] == true) {
        ResponseDataMap res = ResponseDataMap(
          status: true,
          message: "Sukses menambah user",
          data: data,
        );
        return res;
      } else {
        var message = '';
        for (String key in data["message"].keys) {
          message += '${data["message"][key][0]}\n';
        }
        ResponseDataMap res = ResponseDataMap(
          status: false,
          message: message,
        );
        return res;
      }
    } else {
      ResponseDataMap res = ResponseDataMap(
        status: false,
        message: "gagal menambah user dengan code error${response.statusCode}",
      );
      return res;
    }
  }
}
