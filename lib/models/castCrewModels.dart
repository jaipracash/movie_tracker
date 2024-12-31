class CastMember {
  final int id;
  final String originalName;
  final String character;
  final String? profilePath;

  CastMember({
    required this.id,
    required this.originalName,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'],
      originalName: json['original_name'],
      character: json['character'],
      profilePath: json['profile_path'],
    );
  }
}

class CrewMember {
  final int id;
  final String originalName;
  final String job;
  final String? profilePath;

  CrewMember({
    required this.id,
    required this.originalName,
    required this.job,
    this.profilePath,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'],
      originalName: json['original_name'],
      job: json['job'],
      profilePath: json['profile_path'],
    );
  }
}
