class User {
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.roleName,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? roleName;

  bool get isAdmin => roleName?.toLowerCase() == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    final role = json['role'];
    String? roleName;
    if (role is Map<String, dynamic>) {
      roleName = role['name'] as String?;
    }
    return User(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roleName: roleName,
    );
  }
}

class Profile {
  Profile({
    this.address1,
    this.address2,
    this.unit,
    this.floor,
    this.city,
    this.state,
    this.country,
    this.zipCode,
  });

  final String? address1;
  final String? address2;
  final String? unit;
  final String? floor;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      address1: json['address1'] as String?,
      address2: json['address2'] as String?,
      unit: json['unit'] as String?,
      floor: json['floor'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'address1': address1 ?? '',
        'address2': address2 ?? '',
        'unit': unit ?? '',
        'floor': floor ?? '',
        'city': city ?? '',
        'state': state ?? '',
        'country': country ?? '',
        'zipCode': zipCode ?? '',
      };
}
