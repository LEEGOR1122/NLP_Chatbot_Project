import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart'; // api_service.dart는 이 한 줄로만 import 합니다.
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

Future<void> main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: '208f6d61d6fda80aea6a10379857dab2',
  );

  runApp(const MyApp());
}

// 앱의 시작점
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '손에 보험',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        // 🔹 전체 텍스트 테마를 NotoSansKR로 교체
        textTheme: GoogleFonts.notoSansKrTextTheme(),

        // 🔹 AppBar의 제목만 별도로 스타일 지정
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          titleTextStyle: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        // 🔹 버튼 스타일은 그대로 둠
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: GoogleFonts.notoSansKr( // 👈 여기서도 폰트 지정
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// 로딩 화면 (Splash Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageMaxWidth = size.width * 0.65;
    final imageMaxHeight = size.height * 0.35;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: imageMaxWidth,
                  maxHeight: imageMaxHeight,
                ),
                child: Image.asset(
                  'assets/images/Online Doctor-pana.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '내 손에 보험',
                style: TextStyle(
                  // [정리] fontFamily를 직접 지정하지 않아도 ThemeData의 GothicA1이 적용됩니다.
                  // 만약 다른 폰트를 원하시면 여기에 지정하시면 됩니다.
                  // fontFamily: 'GothicA1', 
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '당신은 적절한 보상을 받으셨나요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // [정리] fontFamily를 직접 지정하지 않아도 ThemeData의 NotoSansKR이 적용됩니다.
                  // fontFamily: 'NotoSansKR',
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.2,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                color: Colors.blue[800],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MainScreen: 탭 관리 껍데기
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    ChatbotScreen(),
    MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  Future<bool> _handleWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ExitConfirmScreen()),
    );
    if (result == true) {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: '챗봇'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final resultData = await ApiService.sendMessageToChatbot(query);

    final replyContent = resultData['reply_content'] as String? ?? '데이터 없음';
    final replyAnswer = resultData['reply_answer'] as String? ?? '데이터 없음';
    
    String formattedResult = '본문 내용:\n$replyContent\n\n추천 답변:\n$replyAnswer';
    
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsScreen(resultData: formattedResult, searchQuery: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('손에 보험', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                '무엇을 도와드릴까요?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _handleSearch,
                  decoration: const InputDecoration(
                    hintText: '궁금한 내용을 검색하세요 (예: 보험금 청구)',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '주요 서비스',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  List<String> titles = ['보험금 청구', '보상금 계산', '교통사고 상담', '상해/질병 보상', '후유장해 평가', '서류 준비 도움'];
                  List<IconData> icons = [Icons.receipt_long, Icons.calculate, Icons.directions_car, Icons.local_hospital, Icons.wheelchair_pickup, Icons.folder_open];
                  return _buildServiceItem(context, titles[index], icons[index]);
                },
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: () => Navigator.push(context, 
                // MaterialPageRoute(builder: (context) => const OfficeRecommendationScreen())), 기존 추천 목록 이동
                MaterialPageRoute(builder: (context) => const ConsultationScreen()),
                ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      FlashJitterIcon(size: 24, color: Colors.yellow),
                      SizedBox(width: 12),
                      Text(
                        '실시간 보상상담 (24시간)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () => print('$title 기능 실행!'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(icon, size: 28, color: Colors.blue[800]),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashJitterIcon extends StatefulWidget {
  final double size;
  final Color color;

  const FlashJitterIcon({
    super.key,
    this.size = 24,
    this.color = Colors.yellow,
  });

  @override
  State<FlashJitterIcon> createState() => _FlashJitterIconState();
}

class _FlashJitterIconState extends State<FlashJitterIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _rot;
  late final Animation<double> _dx;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // 모션 속도
    );

    _rot = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut));

    _dx = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 2.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: -2.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut));

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut));

    // 3초마다 한번씩 forward
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _ctl.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_dx.value, 0),
          child: Transform.rotate(
            angle: _rot.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Icon(
                Icons.flash_on,
                size: widget.size,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}


// 챗봇 화면
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': '안녕하세요! 손에보험 챗봇입니다.\n궁금한 점을 입력해주세요.', 'isUser': false},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    _controller.clear();
    
    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _messages.add({'text': '답변을 준비하고 있어요...', 'isUser': false});
    });
    
    final botReply = await ApiService.sendMessageToChatbot2(text);
    String text2 = botReply['response'] ?? '죄송합니다. 답변을 받을 수 없습니다.';

    setState(() {
      _messages.removeLast();
      _messages.add({'text': text2, 'isUser': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('챗봇 상담'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message['text'], message['isUser']);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 70,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration.collapsed(
                hintText: '메시지를 입력하세요...',
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}

// 마이페이지 화면
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _isLoggedIn = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkKakaoLoginStatus();
  }

  Future<void> _checkKakaoLoginStatus() async {
    if (await AuthApi.instance.hasToken()) {
      try {
        await UserApi.instance.accessTokenInfo();
        _updateUser(await UserApi.instance.me());
      } catch (error) {
        print('토큰 유효성 확인 실패: $error');
        _logout();
      }
    }
  }

  void _updateUser(User user) {
    setState(() {
      _isLoggedIn = true;
      _user = user;
    });
  }

  Future<void> _logout() async {
    try {
      await UserApi.instance.logout();
    } catch (error) {
      print('로그아웃 실패: $error');
    }
    setState(() {
      _isLoggedIn = false;
      _user = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: '로그아웃',
              onPressed: _logout,
            )
        ],
      ),
      body: _isLoggedIn 
        ? _buildLoggedInView() 
        : LoginView(onLoginSuccess: _checkKakaoLoginStatus),
    );
  }

  Widget _buildLoggedInView() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            _user?.kakaoAccount?.profile?.nickname ?? '사용자', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          accountEmail: Text(_user?.kakaoAccount?.email ?? '이메일 정보 없음'),
          currentAccountPicture: CircleAvatar(
            backgroundImage: _user?.kakaoAccount?.profile?.profileImageUrl != null
              ? NetworkImage(_user!.kakaoAccount!.profile!.profileImageUrl!)
              : null,
            backgroundColor: Colors.white,
            child: _user?.kakaoAccount?.profile?.profileImageUrl == null
              ? const Icon(Icons.person, size: 50)
              : null,
          ),
          decoration: BoxDecoration(color: Colors.blue[700]),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('상담 이력 보기'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('설정'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}

// 로그인 UI 위젯
class LoginView extends StatelessWidget {
  final VoidCallback onLoginSuccess;
  const LoginView({super.key, required this.onLoginSuccess});

// ▼▼▼ 이 함수 전체를 아래 최종 코드로 교체하세요 ▼▼▼
Future<void> _loginWithKakao(BuildContext context) async {
  try {
    // 1. [수정] 카카오 SDK로 로그인하고 'OAuthToken' 받기
    bool isInstalled = await isKakaoTalkInstalled();
    OAuthToken token = isInstalled
        ? await UserApi.instance.loginWithKakaoTalk()
        : await UserApi.instance.loginWithKakaoAccount();
    
    print('✅ 카카오 액세스 토큰 받기 성공: ${token.accessToken}');

    // 2. ApiService를 호출하여 '액세스 토큰'을 서버에 전송
    final serverResponse = await ApiService.kakaoLogin(token.accessToken);
    print('✅ FastAPI 서버 로그인 성공: $serverResponse');

    // 3. 부모 위젯(MyPageScreen)에 로그인 성공 알림
    onLoginSuccess();

  } catch (error) {
    print('❌ 카카오 로그인 또는 서버 통신 실패: $error');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다: $error')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            const Text('환영합니다!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('로그인하여 모든 서비스를 이용하세요.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 48),
            TextField(
              decoration: InputDecoration(
                labelText: '이메일',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('이메일 로그인은 현재 지원되지 않습니다.'))
                );
              },
              child: const Text('로그인'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('또는', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _loginWithKakao(context),
              child: Image.asset(
                'assets/images/kakao_login_large_wide.png',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('아직 계정이 없으신가요?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  }, 
                  child: const Text('회원가입'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// 회원가입 페이지
enum UserRole { client, expert }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.client;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  void _signUp() async { // async 키워드를 추가합니다.
    if (_formKey.currentState!.validate()) {


      try {
        // ApiService를 호출하여 서버에 회원가입 요청
        await ApiService.register(
          email: _emailController.text,
          password: _passwordController.text,
          nickname: _nameController.text,
        );
        
        // 성공 시 메시지 표시 및 이전 화면으로 이동
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해주세요.')),
          );
          Navigator.pop(context);
        }

      } catch (error) {
        print('❌ 회원가입 실패: $error');
        // 실패 시 사용자에게 에러 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입에 실패했습니다: $error')),
          );
        }
      }

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text('새로운 계정 만들기', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                const Text('가입 유형 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected: [_selectedRole == UserRole.client, _selectedRole == UserRole.expert],
                  onPressed: (index) {
                    setState(() {
                      _selectedRole = index == 0 ? UserRole.client : UserRole.expert;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  fillColor: Colors.blue[100],
                  selectedColor: Colors.blue[800],
                  constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('의뢰인')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('전문가')),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                   validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return '올바른 이메일 형식이 아닙니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                   validator: (value) {
                    if (value == null || value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                   validator: (value) {
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 상담 이력 페이지
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, String>> _history = const [
    {'title': '자동차 접촉사고 과실비율 문의', 'date': '2025-09-18', 'status': '답변 완료'},
    {'title': '실손의료보험금 청구 서류 문의', 'date': '2025-09-02', 'status': '답변 완료'},
    {'title': '상해 후유장해 평가 관련', 'date': '2025-08-15', 'status': '답변 완료'},
    {'title': '질병 진단금 청구 가능 여부', 'date': '2025-08-01', 'status': '답변 완료'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상담 이력'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return Card(
            elevation: 2,
            shadowColor: Colors.grey.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.receipt_long, color: Colors.blue),
              ),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(item['date']!),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['status']!,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 상담 정보 입력 화면
class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isAgreed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 보상 상담'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    '손해사정사와 1:1 채팅으로 빠르고 정확한\n상담이 연결됩니다.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름', hintText: '이름을 입력하세요', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '이름을 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: '휴대폰번호', hintText: '숫자만 입력해주세요', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '휴대폰 번호를 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreed,
                      onChanged: (bool? value) => setState(() => _isAgreed = value!),
                    ),
                    const Flexible(child: Text('개인정보 수집 및 이용에 동의합니다.')),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('유의사항', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                _buildInfoItem('24시간 운영됩니다. 언제든지 편하게 문의하세요.'),
                _buildInfoItem('전문가 답변은 답변이 오기까지 다소 시간이 소요될 수 있습니다.'),
                _buildInfoItem('전문가의 답변은 고객님의 상황에 대한 조언이며, 정확한 판례는 아닐 수 있습니다.'),
                _buildInfoItem('실제 손해사정 시에는 해당 전문가에게 별도의 비용이 청구될 수 있습니다.'),
                _buildInfoItem('민감한 개인정보는 1:1 상담 시에 전문가에게 직접 알려주세요.'),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _isAgreed) {
                      // 1) (모킹) 서버에 상담 요청을 보냈다고 가정하고 requestId 발급
                      final requestId = await MockApiService.createRequest(
                        name: _nameController.text,
                        phone: _phoneController.text,
                        region: '서울',       // 필요하면 폼에 필드 추가해서 바꾸면 됨
                        category: '일반상담', // 필요하면 폼에 필드 추가해서 바꾸면 됨
                      );

                      if (!mounted) return;

                      // 2) 안내 토스트
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('상담 요청이 접수되었습니다. 관련 전문가의 견적을 기다려주세요.')),
                      );

                      // 3) 견적 수신 화면으로 교체 이동 (뒤로가기 시 폼으로 안 돌아오게)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OffersScreen(requestId: requestId),
                        ),
                      );
                    } else if (!_isAgreed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('개인정보 수집에 동의해야 합니다.')),
                      );
                    }
                  },
                  child: const Text('손해사정사 연결하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 16, color: Colors.blue[800]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54))),
        ],
      ),
    );
  }
}

// 검색 결과 화면
class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;
  final String resultData;
  const SearchResultsScreen({super.key, required this.searchQuery, required this.resultData});

  @override
  Widget build(BuildContext context) {
        
    bool hasResults = resultData.isNotEmpty && resultData != '데이터 없음';

    return Scaffold(
      appBar: AppBar(
        title: Text('\'$searchQuery\' 검색 결과'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasResults)
              // 변경점: Expanded와 SingleChildScrollView를 사용하여 스크롤 가능하게 만듦
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                    ),
                    child: Text(resultData, style: const TextStyle(fontSize: 16, height: 1.5)),
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('"$searchQuery"에 대한\n검색 결과를 찾을 수 없습니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey[600], height: 1.4)),
                    const SizedBox(height: 8),
                    Text('다른 검색어로 다시 시도해 보세요.', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// '종료하시겠습니까?' 확인 페이지
class ExitConfirmScreen extends StatelessWidget {
  const ExitConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('확인'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로가기',
          onPressed: () => Navigator.pop(context, false), // 취소
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '종료하시겠습니까?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '앱을 종료하면 진행 중인 작업이 중단될 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, false), // 취소
                      child: const Text('아니요', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context, true), // 종료
                      child: const Text('예', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class OfficeRecommendationScreen extends StatelessWidget {
  const OfficeRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offices = _dummyOffices; // 더미 데이터 5개

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 주변 손해사정사 추천'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: offices.length,
        itemBuilder: (context, index) {
          final o = offices[index];
          return _OfficeCard(office: o);
        },
      ),
    );
  }
}

// 카드 위젯
class _OfficeCard extends StatelessWidget {
  final _Office office;
  const _OfficeCard({required this.office});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더(이름 + 평점/리뷰수)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    office.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${office.rating.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text('(${office.reviewCount})',
                    style: const TextStyle(color: Colors.black45)),
              ],
            ),
            const SizedBox(height: 8),

            // 태그(전문분야)
            Wrap(
              spacing: 8,
              runSpacing: -6,
              children: office.tags
                  .map(
                    (t) => Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),

            // 연락처/주소
            _infoRow(Icons.phone, office.phone),
            const SizedBox(height: 6),
            _infoRow(Icons.location_on, office.address),
            const SizedBox(height: 6),
            _infoRow(Icons.access_time, office.hours),
            const SizedBox(height: 14),

            // 이력(경력) 리스트
            const Text(
              '주요 이력',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...office.career.take(3).map(
              (c) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, size: 16, color: Colors.blue[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 하단 버튼들 (디자인만, 동작은 추후 연동)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: url_launcher로 전화/카카오맵 연동 예정
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('연동 준비중입니다.')),
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('카카오맵으로 보기'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 추후 앱 내 상담 요청/문의 플로우 연결
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('문의 연결 준비중입니다.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('문의하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue[800]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

// 모델 & 더미데이터
class _Office {
  final String name;
  final double rating;
  final int reviewCount;
  final String phone;
  final String address;
  final String hours;
  final List<String> tags;
  final List<String> career;

  _Office({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.phone,
    required this.address,
    required this.hours,
    required this.tags,
    required this.career,
  });
}

final _dummyOffices = <_Office>[
  _Office(
    name: '한빛 손해사정',
    rating: 4.8,
    reviewCount: 132,
    phone: '02-123-4567',
    address: '서울 강남구 테헤란로 123, 7층',
    hours: '평일 09:00 ~ 18:00 (점심 12:30 ~ 13:30)',
    tags: ['교통사고', '실손의료비', '상해/질병'],
    career: [
      '전직 손해보험사 손해사정 12년 경력',
      '교통사고 과실분쟁 300+건 처리',
      '실손보험 지급거절 이의신청 다수 성공',
    ],
  ),
  _Office(
    name: '바른 보상센터',
    rating: 4.7,
    reviewCount: 98,
    phone: '02-234-5678',
    address: '서울 서초구 서초대로 77길 45, 3층',
    hours: '평일 09:00 ~ 18:00 / 토 10:00 ~ 14:00',
    tags: ['후유장해', '산재', '교통사고'],
    career: [
      '후유장해 평가 전문 (사지/척추/신경계)',
      '산재보상/장해급여 청구 경험 풍부',
      '법률 자문 네트워크 보유',
    ],
  ),
  _Office(
    name: '케어라인 손해사정법인',
    rating: 4.9,
    reviewCount: 210,
    phone: '02-456-7890',
    address: '서울 마포구 양화로 21, 10층',
    hours: '평일 09:30 ~ 18:30',
    tags: ['실손의료비', '진단금', '보험분쟁'],
    career: [
      '대형 병원 제휴 상담 창구 운영',
      '진단금 지급거절 분쟁 150+건 해결',
      '보험금 산정/협상 전문팀 운영',
    ],
  ),
  _Office(
    name: '뉴브릿지 손해사정',
    rating: 4.6,
    reviewCount: 64,
    phone: '031-555-1234',
    address: '경기 성남시 분당구 불정로 45, 5층',
    hours: '평일 09:00 ~ 18:00',
    tags: ['배상책임', '재물', '기업보험'],
    career: [
      '기업 화재/누수/도난 등 재물 손해 정밀 산정',
      '배상책임 보험 손해액 산정 자문',
      '중소기업 단체 보상 프로세스 구축',
    ],
  ),
  _Office(
    name: '라이츠 손해사정',
    rating: 4.8,
    reviewCount: 85,
    phone: '051-777-9999',
    address: '부산 해운대구 센텀중앙로 97, 18층',
    hours: '평일 09:00 ~ 18:00 (예약 시 연장 상담)',
    tags: ['교통사고', '후유장해', '상해/질병'],
    career: [
      '교통사고 소송 자문 파트너십',
      '중증 장해 평가 및 합의 컨설팅',
      '의무기록 분석 전담팀 보유',
    ],
  ),
];
/// ─────────────────────────────────────────────────
/// Mock API (백엔드 없이 데모용)
/// ─────────────────────────────────────────────────
class MockApiService {
  static final Random _rnd = Random();

  static Future<String> createRequest({
    required String name,
    required String phone,
    required String region,
    required String category,
    String? detail,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'REQ-${DateTime.now().millisecondsSinceEpoch}';
  }

static Stream<List<Map<String, dynamic>>> offersStream(String requestId) async* {
  final List<Map<String, dynamic>> acc = [];
  int count = 0;
  
  final expertNames = [
    '한빛 손해사정',
    '케어라인 보상센터',
    '바른 보상파트너스',
    '뉴브릿지 손해사정',
    '라이츠 어드바이저',
    '정도 보상컨설팅',
    '서울 손해사정 법인',
    '푸른길 보상센터',
    '미래 보상연구소',
    '정성 손해사정'
  ];
  // 👇 추가: 다양한 소개 문구
  final messages = [
    '보험분쟁 다수 해결, 신속 상담 가능합니다.',
    '실손보험 청구 전문, 서류 검토 도와드립니다.',
    '교통사고 과실분쟁 경험 풍부, 빠른 합의 지원.',
    '후유장해 평가 자문 가능, 사례 다수 보유.',
    '의무기록 분석 전담팀 보유, 투명한 절차 약속.',
  ];

  while (count < 5) {
    await Future.delayed(const Duration(seconds: 2));
    count++;

    final price = (5 + _rnd.nextInt(15)) * 10000;   // 5~20만원
    final rating = (35 + _rnd.nextInt(15)) / 10.0;  // 3.5~4.9
    final expertId = 'EXP-${_rnd.nextInt(9999).toString().padLeft(4, '0')}';

    acc.add({
      'id': 'OFF-${DateTime.now().millisecondsSinceEpoch}',
      'request_id': requestId,
      'expert_id': expertId,
      'expert_name': expertNames[_rnd.nextInt(expertNames.length)],
      'rating': rating,
      'review_count': 30 + _rnd.nextInt(150),
      'price': price,
      'message': messages[_rnd.nextInt(messages.length)], // 👈 랜덤 선택
      'eta': '${10 + _rnd.nextInt(50)}분 내 응답',
    });

    yield List<Map<String, dynamic>>.from(acc);
  }
}


  static Future<String> acceptOffer(String offerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'CONV-$offerId';
  }
}

/// ─────────────────────────────────────────────────
/// OffersScreen: 들어오는 견적 실시간 수신(모킹) → 수락 시 채팅 더미로 이동
/// ─────────────────────────────────────────────────
class OffersScreen extends StatefulWidget {
  final String requestId;
  const OffersScreen({super.key, required this.requestId});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  StreamSubscription<List<Map<String, dynamic>>>? _sub;
  final List<Map<String, dynamic>> _offers = [];

  @override
  void initState() {
    super.initState();
    _sub = MockApiService.offersStream(widget.requestId).listen((list) {
      if (!mounted) return;
      setState(() {
        _offers
          ..clear()
          ..addAll(list);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도착한 견적'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('요청: ${widget.requestId.split('-').last}'),
            ),
          ),
        ],
      ),
      body: _offers.isEmpty
          ? const Center(
              child: Text(
                '견적을 기다리는 중입니다...',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final o = _offers[i];
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.person, color: Colors.blue[700]),
                    ),
                    title: Text(
                      '${o['expert_name']} · ★${o['rating']} (${o['review_count']})',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    subtitle: Text(
                      '${o['price']}원 · ${o['eta']}\n${o['message']}',
                      style: TextStyle(color: Colors.blueGrey[700]),
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onPressed: () async {
                        final convId = await MockApiService.acceptOffer(o['id']);
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _SimpleChatScreen(
                              conversationId: convId,
                              expertName: o['expert_name'] as String,
                            ),
                          ),
                        );
                      },
                      child: const Text('수락'),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _offers.length,
            ),
    );
  }
}

/// 아주 단순한 채팅 화면 더미(향후 실제 챗봇/채팅 UI로 교체)
class _SimpleChatScreen extends StatelessWidget {
  final String conversationId;
  final String expertName;
  const _SimpleChatScreen({
    super.key,
    required this.conversationId,
    required this.expertName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('채팅 · $expertName')),
      body: Center(
        child: Text(
          '대화방 ID: $conversationId\n(여기에 실제 채팅 UI를 연결하세요)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}