import 'dart:convert';

class UserModel {
  final String? qrUrl;
  final String ip;
  final String? locality;
  final String? loginTime;
  UserModel({
    this.qrUrl,
    required this.ip,
    this.locality,
    this.loginTime,
  });

  UserModel copyWith({
    String? qrUrl,
    String? ip,
    String? locality,
    String? loginTime,
  }) {
    return UserModel(
      qrUrl: qrUrl ?? this.qrUrl,
      ip: ip ?? this.ip,
      locality: locality ?? this.locality,
      loginTime: loginTime ?? this.loginTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qrUrl': qrUrl,
      'ip': ip,
      'locality': locality,
      'loginTime': loginTime,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      qrUrl: map['qrUrl'],
      ip: map['ip'] ?? '',
      locality: map['locality'],
      loginTime: map['loginTime'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(qrUrl: $qrUrl, ip: $ip, locality: $locality, loginTime: $loginTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.qrUrl == qrUrl &&
        other.ip == ip &&
        other.locality == locality &&
        other.loginTime == loginTime;
  }

  @override
  int get hashCode {
    return qrUrl.hashCode ^
        ip.hashCode ^
        locality.hashCode ^
        loginTime.hashCode;
  }
}
