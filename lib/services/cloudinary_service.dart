import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = "dhgojipbh";
  final String uploadPreset = "unsigned_preset";

  Future<String?> uploadFile(File file) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", url);
    request.fields["upload_preset"] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final resBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(resBody.body);
      print("✅ تم الرفع: ${data['secure_url']}");
      return data["secure_url"]; // اللينك النهائي للصورة
    } else {
      print("❌ فشل الرفع: ${resBody.body}");
      return null;
    }
  }
}
