// import 'package:beena_social_app/constants.dart';
// import 'package:beena_social_app/pages/HomePage.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:timeago/timeago.dart' as timeAgo;
//
// class Comment extends StatefulWidget {
//   final String username;
//   final String userId;
//   final String url;
//   final String comment;
//   final Timestamp timestamp;
//   final dynamic likes;
//
//   Comment({
//     this.username,
//     this.userId,
//     this.url,
//     this.comment,
//     this.timestamp,
//     this.likes,
//   });
//
//   factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
//     return Comment(
//       username: documentSnapshot['username'],
//       userId: documentSnapshot['userId'],
//       url: documentSnapshot['url'],
//       comment: documentSnapshot['comment'],
//       timestamp: documentSnapshot['timestamp'],
//     );
//   }
//
//   int getTotalNumberOfLikes(likes) {
//     if (likes == null) {
//       return 0;
//     }
//
//     int counter = 0;
//     likes.values.forEach((eachValue) {
//       if (eachValue == true) {
//         counter = counter + 1;
//       }
//     });
//     return counter;
//   }
//
//   @override
//   _CommentState createState() => _CommentState(
//         username: username,
//         userId: userId,
//         url: url,
//         comment: comment,
//         timestamp: timestamp,
//       );
// }
//
// class _CommentState extends State<Comment> {
//   final String username;
//   final String userId;
//   final String url;
//   final String comment;
//   final Timestamp timestamp;
//   bool myVIP = false;
//
//   @override
//   void initState() {
//     getUserCommentColor(userId);
//   }
//
//   _CommentState({
//     this.username,
//     this.userId,
//     this.url,
//     this.comment,
//     this.timestamp,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       child: Container(
//         padding: EdgeInsets.only(bottom: 5),
//         color: colorWhite,
//         child: Column(
//           children: [
//             ListTile(
//               title: RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: username + ': ',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     TextSpan(
//                       text: comment,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Quicksand',
//                         color: myVIP ? Colors.yellow.shade900 : colorBlack,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               leading: CircleAvatar(
//                 backgroundImage: CachedNetworkImageProvider(url),
//               ),
//               subtitle: Text(
//                 timeAgo.format(timestamp.toDate()),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   void getUserCommentColor(String userId) async {
//     await usersReference.document(userId).snapshots().forEach((element) {
//       setState(() {
//         myVIP = element['isVip'];
//       });
//     });
//   }
// }
