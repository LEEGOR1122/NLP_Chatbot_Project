import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ❗️ 중요: FastAPI 서버를 실행한 컴퓨터의 IP 주소를 사용하세요!
  static const String _baseUrl = 'http://172.30.1.42:8000' ; //172.30.1.42 10.0.2.2
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


// 챗봇 메시지 전송 및 응답 받기 (POST)
static Future<Map<String, dynamic>> sendMessageToChatbot2(String message) async {
  final url = Uri.parse('$_baseUrl/chatBot');
  final body = json.encode({'prompt': message});
  
  try {
    debugPrint('Response message: $message'); // 디버그 출력
    final response = await http.post(url, headers: _headers, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      
      return data; // 서버가 보낸 'reply' 값을 반환
    } else {
      return { 'msg': '서버와 통신 중 오류가 발생했습니다.' };
    }
  } catch (e) {
    return { 'msg': '연결에 실패했습니다: $e'};
  }
}


  // ▼▼▼ 여기에 새로운 함수들을 추가합니다. ▼▼▼

// ▼▼▼ 카카오 로그인 함수를 아래 내용으로 수정 ▼▼▼
static Future<Map<String, dynamic>> kakaoLogin(String accessToken) async {
  final url = Uri.parse('$_baseUrl/api/auth/kakao'); 
  
  final response = await http.post(
    url,
    headers: _headers,
    body: jsonEncode({'access_token': accessToken}), // 'authorization_code' -> 'access_token'
  );

  if (response.statusCode == 200) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
  throw Exception('Failed to login with Kakao: ${jsonDecode(response.body)['detail']}');
}

  // 자체 회원가입
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/register'); // FastAPI 라우터 prefix에 맞게 경로 설정
    
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 201) { // 회원가입 성공 코드는 201
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to register: ${jsonDecode(response.body)['detail']}');
  }
}



