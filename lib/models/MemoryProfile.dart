import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryProfile {
  final String id;
  final String username;
  final String url;

  MemoryProfile({
    this.id,
    this.username,
    this.url,
  });

  factory MemoryProfile.fromDocument(DocumentSnapshot doc) {
    return MemoryProfile(
      id: doc.documentID,
      username: doc['username'],
      url: doc['url'],
    );
  }
}
