class ProfileAppearance {
  final String avatarId;
  final String? photoBase64;

  const ProfileAppearance({this.avatarId = 'farmer', this.photoBase64});

  factory ProfileAppearance.fromJson(Map<String, dynamic> json) {
    return ProfileAppearance(
      avatarId: json['avatarId'] as String? ?? 'farmer',
      photoBase64: json['photoBase64'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'avatarId': avatarId,
        if (photoBase64 != null) 'photoBase64': photoBase64,
      };
}
