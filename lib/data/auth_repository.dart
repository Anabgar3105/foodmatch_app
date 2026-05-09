import '../models/user.dart';
import 'api_client.dart';

class AuthRepository {
  final ApiClient api;
  final String baseUrl = 'http://10.0.2.2:8080/api/users'; 

  AuthRepository(this.api); 

  Future<UserResponseDto> login(UserLoginDto loginDto) async {
    final url = Uri.parse('$baseUrl/login');
    final json = await api.postJsonObject(url, loginDto.toJson()); 
    
    return UserResponseDto.fromJson(json);
  }
}