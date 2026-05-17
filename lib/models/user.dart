class UserLoginDto {
  final String username;
  final String password;

  UserLoginDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class UserResponseDto {
  final int id;
  final String username;
  final String email;
  final String token;
  final String name;
  final String surname1;
  final String? surname2;

  UserResponseDto({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
    required this.name,
    required this.surname1,
    this.surname2,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      surname1: json['surname1'] ?? '',
      surname2: json['surname2'], 
    );
  }
}

class UserRegistrationDto {
  final String name;
  final String surname1;
  final String? surname2;
  final String email;
  final String username;
  final String password;

  UserRegistrationDto({
    required this.name,
    required this.surname1,
    this.surname2,
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'surname1': surname1,
    'surname2': surname2,
    'email': email,
    'username': username,
    'password': password,
  };
}
