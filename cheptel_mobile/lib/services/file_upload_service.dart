import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/token_storage.dart';

class FileUploadService {
  final Dio _dio;

  FileUploadService() : _dio = Dio();

  Future<String?> uploadPhoto(String filePath) async {
    try {
      final token = await TokenStorage.getToken();

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: "photo.jpg"),
      });

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.uploadPhoto}',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['fileUrl'] != null) {
        return response.data['fileUrl'];
      }
      return null;
    } catch (e) {
      print("Erreur upload photo : $e");
      return null;
    }
  }

  Future<String?> uploadAudio(String filePath) async {
    try {
      final token = await TokenStorage.getToken();

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: "audio.mp3"),
      });

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.uploadAudio}',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['fileUrl'] != null) {
        return response.data['fileUrl'];
      }
      return null;
    } catch (e) {
      print("Erreur upload audio : $e");
      return null;
    }
  }
}