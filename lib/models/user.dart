/// Data Transfer Object for user login credentials.
///
/// Used to send login information to the authentication API.
///
/// Properties:
/// - [username]: User's unique username
/// - [password]: User's password (should be transmitted securely over HTTPS)
class UserLoginDto {
  /// User's unique username
  final String username;

  /// User's password
  final String password;

  /// Creates a [UserLoginDto] instance.
  UserLoginDto({required this.username, required this.password});

  /// Converts the login data to JSON for API request.
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

/// Data Transfer Object for user authentication response.
///
/// Returned by the server after successful login or registration.
/// Contains user profile information and authentication token.
///
/// Properties:
/// - [id]: User's unique identifier
/// - [username]: User's unique username
/// - [email]: User's email address
/// - [token]: JWT authentication token for subsequent requests
/// - [name]: User's first name
/// - [surname1]: User's primary surname
/// - [surname2]: User's secondary surname (optional)
/// - [avatarUrl]: URL to user's profile avatar (optional)
class UserResponseDto {
  /// Unique user identifier
  final int id;

  /// User's unique username
  final String username;

  /// User's email address
  final String email;

  /// JWT authentication token
  final String token;

  /// User's first name
  final String name;

  /// User's primary surname
  final String surname1;

  /// User's secondary surname (optional)
  final String? surname2;

  /// User's avatar image URL (optional)
  final String? avatarUrl;

  /// Creates a [UserResponseDto] instance.
  UserResponseDto({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
    required this.name,
    required this.surname1,
    this.surname2,
    this.avatarUrl,
  });

  /// Creates a [UserResponseDto] from JSON API response.
  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      token: json['token'] ?? '',
      name: json['name'] ?? '',
      surname1: json['surname1'] ?? '',
      surname2: json['surname2'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

/// Data Transfer Object for user registration.
///
/// Contains all information needed to create a new user account.
///
/// Properties:
/// - [name]: User's first name
/// - [surname1]: User's primary surname
/// - [surname2]: User's secondary surname (optional)
/// - [email]: User's email address
/// - [username]: Desired unique username
/// - [password]: Account password
class UserRegistrationDto {
  /// User's first name
  final String name;

  /// User's primary surname
  final String surname1;

  /// User's secondary surname (optional)
  final String? surname2;

  /// User's email address
  final String email;

  /// Desired unique username
  final String username;

  /// Account password
  final String password;

  /// Creates a [UserRegistrationDto] instance.
  UserRegistrationDto({
    required this.name,
    required this.surname1,
    this.surname2,
    required this.email,
    required this.username,
    required this.password,
  });

  /// Converts registration data to JSON for API request.
  Map<String, dynamic> toJson() => {
    'name': name,
    'surname1': surname1,
    'surname2': surname2,
    'email': email,
    'username': username,
    'password': password,
  };
}

/// Data Transfer Object for updating user profile.
///
/// Contains user information that can be updated after registration.
///
/// Properties:
/// - [username]: Updated username
/// - [email]: Updated email address
/// - [avatarUrl]: Updated avatar image URL (optional)
class UserUpdateDto {
  /// Updated username
  final String username;

  /// Updated email address
  final String email;

  /// Updated avatar image URL (optional)
  final String? avatarUrl;

  /// Creates a [UserUpdateDto] instance.
  UserUpdateDto({required this.username, required this.email, this.avatarUrl});

  /// Converts update data to JSON for API request.
  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
  };
}

/// Data Transfer Object for password change requests.
///
/// Contains the current password and new password for user account updates.
///
/// Properties:
/// - [currentPassword]: User's current password for verification
/// - [newPassword]: The new password to set
class PasswordChangeDto {
  /// Current password for verification
  final String currentPassword;

  /// New password to set
  final String newPassword;

  /// Creates a [PasswordChangeDto] instance.
  PasswordChangeDto({required this.currentPassword, required this.newPassword});

  /// Converts password change data to JSON for API request.
  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
