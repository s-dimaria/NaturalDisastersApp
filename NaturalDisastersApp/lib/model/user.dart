class ModelUser {
  late String email;
  late String username;
  late String role;

  ModelUser(this.email, this.username, this.role);

  ModelUser.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        username = json['username'],
        role = json['role'];

  Map<String, dynamic> toJson() =>
      {'email': email, 'username': username, 'role': role};
}
