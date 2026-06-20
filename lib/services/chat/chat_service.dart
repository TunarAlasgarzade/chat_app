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

    // add new message to datebase
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
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
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final contact = doc.data();
        return contact;
      }).toList();
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
}