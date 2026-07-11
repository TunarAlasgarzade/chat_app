import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  /*
  List<Map<String, dynamic>> = 
  [
  {
    'email': 'test@gmail.com',
    'id': ..
  },
  {
    'email': 'mitch@gmail.com',
    'id': ..
  },
  ]
  */
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each invidual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

  // get all users stream except blocked users
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // get blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      // get all users
      final usersSnapshot = await _firestore.collection('Users').get();

      // return as stream list, excluding current user and blocked users
      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockedUserIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  // send message
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message 
    Message newMessage = Message(
      senderID: currentUserID, 
      senderEmail: currentUserEmail, 
      receiverID: receiverID, 
      message: message,
      isRead: false, 
      timestamp: timestamp
    );

    // construct chat room ID for this two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // send notification in background (without awaiting)
    _sendNotification(receiverID, currentUserID, currentUserEmail, message);
  }

  // send push notification in background
  Future<void> _sendNotification(String receiverID, String currentUserID, String currentUserEmail, String message) async {
    try {
      // check if receiver blocked the sender
      final blockedDoc = await _firestore
          .collection('Users')
          .doc(receiverID)
          .collection('BlockedUsers')
          .doc(currentUserID)
          .get();

      if (blockedDoc.exists) return;
      // get receiver's oneSignalId
      final doc = await _firestore.collection("Users").doc(receiverID).get();
      final data = doc.data();
      final receiverOneSignalId = data?['oneSignalId'];
      final isOnline = data?['isOnline'] ?? false;

      if (isOnline) return;

      // get firebase id token
      final idToken = await _auth.currentUser!.getIdToken();

      // get sender name from receiver's contacts
      final contactDoc = await _firestore
          .collection("Users")
          .doc(receiverID)
          .collection("Contacts")
          .doc(currentUserID)
          .get();
      final senderName = contactDoc.data()?['contactName'] ?? currentUserEmail;

      // send notification via cloudflare worker
      if (receiverOneSignalId != null) {
        http.post(
          Uri.parse("https://chat-app.t-alasgarzade.workers.dev"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $idToken",
          },
          body: jsonEncode({
            "oneSignalId": receiverOneSignalId,
            "senderName": senderName,
            "message": message,
          }),
        );
      }
    } catch (e) {
      // if notification fails, message is not affected
    }
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // add contact
  Future<void> addContact(String email, String customName) async {
    try {
      // We are looking for the entered email in the "Users" collection.
      final querySnapshot = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();
      
      // If no user with such an email address is found, we throw an error.
      if (querySnapshot.docs.isEmpty) {
        throw Exception("User not found!");
      }

      // If the user is found, we take his UID and my UID
      final String contactUid = querySnapshot.docs.first.id;
      final String currentUid = _auth.currentUser!.uid;

      // We create a "Contacts" subcollection in our document and write the data.
      await _firestore
        .collection('Users')
        .doc(currentUid)
        .collection('Contacts')
        .doc(contactUid)
        .set({
          'contactName': customName,
          'email': email,
          'id': contactUid,
        });
    } catch (e) {
      rethrow;
    }
  }

  // get contacts stream
  Stream<List<Map<String, dynamic>>> getContactsStream() {
    final String currentUid = _auth.currentUser!.uid;

    return _firestore
        .collection("Users")
        .doc(currentUid)
        .collection("Contacts")
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedSnapshot = await _firestore
        .collection('Users')
        .doc(currentUid)
        .collection('BlockedUsers')
        .get();
        final blockedIds = blockedSnapshot.docs.map((doc) => doc.id).toList();
        return snapshot.docs
        .where((doc) => !blockedIds.contains(doc.id))
        .map((doc) => doc.data())
        .toList();
    });
  }

  // delete contact
  Future<void> deleteContact(String contactUid) async {
    final String currentUid = _auth.currentUser!.uid;
    await _firestore
      .collection('Users')
      .doc(currentUid)
      .collection('Contacts')
      .doc(contactUid)
      .delete();
  } 

  // update contact name
  Future<void> updateContact(String contactUid, String newName) async {
    final String currentUid = _auth.currentUser!.uid;
    await _firestore
      .collection('Users')
      .doc(currentUid)
      .collection('Contacts')
      .doc(contactUid)
      .update({'contactName': newName});
  }

  // delete message
  Future<void> deleteMessage(String receiverID, String messageID) async {
    final String currentUserID = _auth.currentUser!.uid;
  
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .doc(messageID)
      .delete();
  }

  // mark as read
  Future<void> markAsRead(String receiverID) async {
    final String currentUserID = _auth.currentUser!.uid;

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    final querySnapshot = await _firestore
    .collection("chat_rooms")
    .doc(chatRoomID)
    .collection("messages")
    .where("senderID", isEqualTo: receiverID)
    .where("isRead", isEqualTo: false)
    .get();

    for (var doc in querySnapshot.docs) {
      doc.reference.update({'isRead': true});
    }
  }

  // typing status
  Future<void> startTyping(String receiverID) async {
    final currentUserID = _auth.currentUser!.uid;

    await _firestore
        .collection("Users")
        .doc(currentUserID)
        .update({
      "isTypingTo": receiverID,
    });
  }

  // clear typing status
  Future<void> stopTyping() async {
    final currentUserID = _auth.currentUser!.uid;

    await _firestore
        .collection("Users")
        .doc(currentUserID)
        .update({
      "isTypingTo": null,
    });
  }

  // typing stream
  Stream<bool> isTypingStream(String userID) {
    final currentUserID = _auth.currentUser!.uid;

    return _firestore
      .collection('Users')
      .doc(userID)
      .snapshots()
      .map((doc) {
        final data = doc.data();

        return data?['isTypingTo'] == currentUserID;
      });
  }

  // get unread count stream
  Stream<int> getUnreadCountStream(String otherUserID) {
    final String currentUserID = _auth.currentUser!.uid;

    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .where("senderID", isEqualTo: otherUserID)
        .where("isRead", isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.length;
        });
  }

  // block user
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
  }

  // unblock user
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;

    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  // get blocked users stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // get list of blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(
        blockedUserIds
            .map((id) => _firestore.collection('Users').doc(id).get()),
      );

      // return as a list
      return userDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // is user blocked
  Stream<bool> isUserBlocked(String userID) {
    final currentUID = _auth.currentUser!.uid;
    return _firestore
        .collection('Users')
        .doc(currentUID)
        .collection('BlockedUsers')
        .doc(userID)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // is account deleted
  Stream<bool> isAccountDeleted(String userID) {
    return _firestore
        .collection('Users')
        .doc(userID)
        .snapshots()
        .map((doc) => doc.data()?['isDeleted'] ?? false);
  }
}