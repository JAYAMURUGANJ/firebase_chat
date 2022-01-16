class UserModel {
  String? uid;
  String? createdAt;
  String? lastSignInTime;
  String? email;
  String? updatedAt;

  UserModel(
      {this.uid,
      this.createdAt,
      this.lastSignInTime,
      this.email,
      this.updatedAt});

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    createdAt = json['createdAt'];
    lastSignInTime = json['lastSignInTime'];
    email = json['email'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['createdAt'] = createdAt;
    data['lastSignInTime'] = lastSignInTime;
    data['email'] = email;
    data['updatedAt'] = updatedAt;
    return data;
  }

  static fromMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return UserModel(
        uid: data['uid'],
        createdAt: data['createdAt'],
        lastSignInTime: data['lastSignInTime'],
        email: data['email'],
        updatedAt: data['updatedAt'],
      );
    }
    return null;
  }
}
