//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  Timestamp createdAt;
  String id;
  String content;
  String authorId;
  String authorName;
  String authorPhoto;

  ChatMessage(
      {this.createdAt,
      this.id,
      this.content,
      this.authorId,
      this.authorName,
      this.authorPhoto});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    id = json['id'];
    content = json['content'];
    authorId = json['authorId'];
    authorName = json['authorName'];
    authorPhoto = json['authorPhoto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['createdAt'] = createdAt;
    data['id'] = id;
    data['content'] = content;
    data['authorId'] = authorId;
    data['authorName'] = authorName;
    data['authorPhoto'] = authorPhoto;
    return data;
  }
}
