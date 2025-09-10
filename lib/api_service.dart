import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ❗️ 중요: FastAPI 서버를 실행한 컴퓨터의 IP 주소를 사용하세요!
  static const String _baseUrl = 'http://10.0.2.2:8000' ;
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

// 챗봇 메시지 전송 및 응답 받기 (POST)
static Future<dynamic> sendMessageToChatbot(String message) async {
  final url = Uri.parse('$_baseUrl/chat');
  final body = json.encode({'message': message});
  
  try {
    final response = await http.post(url, headers: _headers, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      
      return data; // 서버가 보낸 'reply' 값을 반환
    } else {
      return '서버와 통신 중 오류가 발생했습니다.';
    }
  } catch (e) {
    return '연결에 실패했습니다: $e';
  }
}

}