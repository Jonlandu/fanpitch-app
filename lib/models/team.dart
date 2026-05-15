class Team {
  final int id;
  final String name;
  final String shortName;
  final String country;
  final String? crestUrl;
  final String colorPrimary;

  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.country,
    this.crestUrl,
    this.colorPrimary = '#1e90ff',
  });

  factory Team.fromJson(Map<String, dynamic> j) => Team(
    id: j['id'] as int,
    name: j['name'] as String,
    shortName: j['short_name'] as String,
    country: (j['country'] ?? '') as String,
    crestUrl: j['crest_url'] as String?,
    colorPrimary: (j['color_primary'] ?? '#1e90ff') as String,
  );
}
