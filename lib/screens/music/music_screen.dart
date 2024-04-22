import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kavir_face/models/music_model.dart';
import 'package:logger/logger.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final Logger _log = Logger();

  Future<List<MusicModel>> _fetchData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    List jsonResponse = jsonDecode(jsonString);
    _log.i(jsonResponse);
    return jsonResponse.map((data) => MusicModel.fromJson(data)).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<MusicModel>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            MusicModel musicData = snapshot.data!.last;
            var musicRecommendations = musicData.musicRecommendations;
            _log.i(snapshot.data);
            if (snapshot.hasData) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    child: ListTile(
                      title: Text(musicRecommendations![index].name!),
                      subtitle: Text(musicRecommendations[index].artist!),
                    ),
                  );
                },
                itemCount: musicData.musicRecommendations!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 12);
                },
              );
            } else {
              return const Text('No data found.');
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            _log.e(snapshot.error);
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Text("hello world from the kathmandu");
          }
        },
      ),
    );
  }
}
