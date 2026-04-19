// Modelo de dados retornado pela API após autenticação.
class AuthModel {
  final String token;
  final String userId;
  final String email;

  const AuthModel({
    required this.token,
    required this.userId,
    required this.email,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'userId': userId,
        'email': email,
      };
}
