import 'dart:convert';

import "package:http/http.dart" as http;

var headers = {
  'Content-Type': 'application/json',
  'Authorization':
      'key=AAAAc4fMoWY:APA91bEHAUs3CHgn8la1VogaHbWnCUZJB4Zp6V2mzGTyB778tRkFaS26yzVd_3fqHqbhfjQp3VI87ApH6a8uLXHzMZU_9zFgQqfQ-eF1eKq3QKaalmLjcoDkfwTB93r8_N2fijTCYqXI'
};

Future sendNotification(String title, String body) async {
  var data = {
    "notification": {"title": title, "body": body, "sound": "default"},
    "priority": "high",
    "data": {
      "email": title,
      "type": "chat",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "to": "/topics/all"
  };

  var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: json.encode(data));
  print(response.body);
}
