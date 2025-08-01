import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;
import 'settings_repository.dart';

Future<Stream<Notification>> getNotifications() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(Notification.fromJSON({}));
  }
  
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}notifications?$_apiToken';

  final client = http.Client();
  try {
    final response = await client.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        List<dynamic> notificationsData = jsonResponse['data'];
        
        return Stream.fromIterable(notificationsData.map((data) => Notification.fromJSON(data)));
      } else {
        print('API Error: ${jsonResponse['message'] ?? 'Unknown error'}');
        return Stream.value(Notification.fromJSON({}));
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      return Stream.value(Notification.fromJSON({}));
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: 'Error fetching notifications: $e'));
    return Stream.value(Notification.fromJSON({}));
  } finally {
    client.close();
  }
}

Future<List<Notification>> getNotificationsList() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return [];
  }
  
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}notifications?$_apiToken';

  final client = http.Client();
  try {
    final response = await client.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      print('API Response: $jsonResponse'); // Debug log
      
      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        List<dynamic> notificationsData = jsonResponse['data'];
        print('Found ${notificationsData.length} notifications'); // Debug log
        
        return notificationsData.map((data) => Notification.fromJSON(data)).toList();
      } else if (jsonResponse['data'] is List) {
        // Handle case where success field might not be present
        List<dynamic> notificationsData = jsonResponse['data'];
        print('Found ${notificationsData.length} notifications (no success field)'); // Debug log
        
        return notificationsData.map((data) => Notification.fromJSON(data)).toList();
      } else {
        print('API Error: ${jsonResponse['message'] ?? 'Unknown error'}');
        print('Response structure: ${jsonResponse.keys.toList()}');
        return [];
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: 'Error fetching notifications: $e'));
    return [];
  } finally {
    client.close();
  }
}

Future<int> getUnreadNotificationsCount() async {
  try {
    List<Notification> notifications = await getNotificationsList();
    return notifications.where((notification) => !notification.read).length;
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: 'Error counting unread notifications: $e'));
    return 0;
  }
}

Future<Notification> markAsReadNotifications(Notification notification) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Notification();
  }
  
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}notifications/${notification.id}?$_apiToken';
  
  final client = http.Client();
  try {
  final response = await client.put(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(notification.markReadMap()),
  );
    
  print("[${response.statusCode}] NotificationRepository markAsReadNotifications");
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Notification.fromJSON(jsonResponse['data']);
    } else {
      print('Error marking notification as read: ${response.statusCode}');
      return notification;
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: 'Error marking notification as read: $e'));
    return notification;
  } finally {
    client.close();
  }
}

Future<Notification> removeNotification(Notification notification) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Notification();
  }
  
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}notifications/${notification.id}?$_apiToken';
  
  final client = http.Client();
  try {
  final response = await client.delete(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
    
    print("[${response.statusCode}] NotificationRepository removeNotification");
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Notification.fromJSON(jsonResponse['data']);
    } else {
      print('Error removing notification: ${response.statusCode}');
      return notification;
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: 'Error removing notification: $e'));
    return notification;
  } finally {
    client.close();
  }
}

Future<bool> markAllAsRead() async {
  try {
    List<Notification> notifications = await getNotificationsList();
    List<Notification> unreadNotifications = notifications.where((n) => !n.read).toList();
    
    for (Notification notification in unreadNotifications) {
      await markAsReadNotifications(notification);
    }
    
    return true;
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: 'Error marking all notifications as read: $e'));
    return false;
  }
}

Future<void> sendNotification(String body, String title, User user) async {
  final data = {
    "notification": {"body": "$body", "title": "$title"},
    "priority": "high",
    "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "messages", "status": "done"},
    "to": "${user.deviceToken}"
  };
  
  final String url = 'https://fcm.googleapis.com/fcm/send';
  final client = http.Client();
  
  try {
  final response = await client.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "key=${setting.value.fcmKey}",
    },
    body: json.encode(data),
  );
    
  if (response.statusCode != 200) {
      print('notification sending failed: ${response.statusCode}');
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: 'Error sending notification: $e'));
  } finally {
    client.close();
  }
}
