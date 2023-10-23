class UserModel {
  String? id;
  String? displayName;
  String? email;
  String? photoUrl;

  UserModel({
    this.id,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['displayName'];
    email = json['email'];
    photoUrl = json['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['displayName'] = displayName;
    data['email'] = email;
    data['photoUrl'] = photoUrl;
    return data;
  }
}
