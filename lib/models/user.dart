import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String email;
  final String bio;
  final bool isVip;

  User(
      {this.id,
      this.profileName,
      this.username,
      this.url,
      this.email,
      this.bio,
      this.isVip});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      profileName: doc['profileName'],
      username: doc['username'],
      url: doc['url'],
      email: doc['email'],
      bio: doc['bio'],
      isVip: doc['isVip'],
    );
  }
}
