class UserLoginDto {
  final String username;
  final String password;

  UserLoginDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class UserResponseDto {
  final int id;
  final String username;
  final String email;

  UserResponseDto({required this.id, required this.username, required this.email});

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}