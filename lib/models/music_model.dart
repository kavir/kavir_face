// ignore_for_file: public_member_api_docs, sort_constructors_first
class MusicModel {
  final String? emotion;
  final List<MusicData>? musicRecommendations;

  MusicModel({
    this.emotion,
    this.musicRecommendations,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      emotion: json['emotion'],
      musicRecommendations: (json['music_recommendations'] as List)
          .map((item) => MusicData.fromJson(item))
          .toList(),
    );
  }
}

class MusicData {
  final String? album;
  final String? artist;
  final String? mood;
  final String? name;

  MusicData({
    this.album,
    this.artist,
    this.mood,
    this.name,
  });

  factory MusicData.fromJson(Map<String, dynamic> json) {
    return MusicData(
      album: json['album'],
      artist: json['artist'],
      mood: json['mood'],
      name: json['name'],
    );
  }
}
