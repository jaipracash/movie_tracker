class WatchProvider {
  final String logoPath;
  final String providerName;

  WatchProvider({required this.logoPath, required this.providerName});

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      logoPath: json['logo_path'] ?? '',
      providerName: json['provider_name'] ?? '',
    );
  }
}
