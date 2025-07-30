import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EventsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userEvents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userTickets = <Map<String, dynamic>>[].obs;
  
  // Event form fields
  final RxString eventName = ''.obs;
  final RxString description = ''.obs;
  final RxString location = ''.obs;
  final RxString date = ''.obs;
  final RxString time = ''.obs;
  final RxDouble ticketPrice = 0.0.obs;
  final RxInt maxTickets = 100.obs;
  final RxList<String> images = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
    loadUserEvents();
    loadUserTickets();
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      final QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .orderBy('date')
          .get();

      events.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load events';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserEvents() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('promoterId', isEqualTo: user.uid)
          .get();

      userEvents.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load user events';
    }
  }

  Future<void> loadUserTickets() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final QuerySnapshot snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .get();

      userTickets.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load user tickets';
    }
  }

  Future<void> createEvent() async {
    if (eventName.value.isEmpty || description.value.isEmpty || 
        location.value.isEmpty || date.value.isEmpty || time.value.isEmpty) {
      errorMessage.value = 'Please fill in all required fields';
      return;
    }

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      // Upload images if any
      List<String> imageUrls = [];
      for (String imagePath in images) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';
        final ref = _storage.ref().child('event_images/$fileName');
        await ref.putFile(File(imagePath));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Create event
      await _firestore.collection('events').add({
        'name': eventName.value,
        'description': description.value,
        'location': location.value,
        'date': date.value,
        'time': time.value,
        'ticketPrice': ticketPrice.value,
        'maxTickets': maxTickets.value,
        'availableTickets': maxTickets.value,
        'images': imageUrls,
        'promoterId': user.uid,
        'isActive': true,
        'totalRevenue': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _clearForm();
      await loadUserEvents();
    } catch (e) {
      errorMessage.value = 'Failed to create event';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseTicket(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get event data
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return;

      final eventData = eventDoc.data() as Map<String, dynamic>;
      final availableTickets = eventData['availableTickets'] ?? 0;
      final ticketPrice = eventData['ticketPrice'] ?? 0.0;

      if (availableTickets <= 0) {
        errorMessage.value = 'No tickets available';
        return;
      }

      // Create ticket
      await _firestore.collection('tickets').add({
        'eventId': eventId,
        'userId': user.uid,
        'ticketPrice': ticketPrice,
        'purchaseDate': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // Update event
      await _firestore.collection('events').doc(eventId).update({
        'availableTickets': availableTickets - 1,
        'totalRevenue': (eventData['totalRevenue'] ?? 0.0) + ticketPrice,
      });

      await loadUserTickets();
    } catch (e) {
      errorMessage.value = 'Failed to purchase ticket';
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        images.add(image.path);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
    }
  }

  void removeImage(int index) {
    if (index < images.length) {
      images.removeAt(index);
    }
  }

  void updateEventName(String value) => eventName.value = value;
  void updateDescription(String value) => description.value = value;
  void updateLocation(String value) => location.value = value;
  void updateDate(String value) => date.value = value;
  void updateTime(String value) => time.value = value;
  void updateTicketPrice(double value) => ticketPrice.value = value;
  void updateMaxTickets(int value) => maxTickets.value = value;

  void _clearForm() {
    eventName.value = '';
    description.value = '';
    location.value = '';
    date.value = '';
    time.value = '';
    ticketPrice.value = 0.0;
    maxTickets.value = 100;
    images.clear();
  }

  void clearError() {
    errorMessage.value = '';
  }
} 