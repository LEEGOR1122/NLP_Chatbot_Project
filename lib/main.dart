import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';


void main() {
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
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/OIG3.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('내 손에 보험', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 60),
                Text('당신은 적절한 보상을 받으셨나요?', style: GoogleFonts.notoSans(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MainScreen: 탭을 관리하는 껍데기 역할
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: '챗봇'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
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

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsScreen(searchQuery: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('손에 보험', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _handleSearch,
                  decoration: const InputDecoration(
                    hintText: '궁금한 내용을 검색하세요',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.0,
                ),
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  List<String> titles = ['보험금 청구', '보상금 계산', '교통사고 상담', '상해/질병 보상', '후유장해 평가', '서류 준비 도움'];
                  List<IconData> icons = [Icons.receipt, Icons.calculate, Icons.directions_car, Icons.local_hospital, Icons.wheelchair_pickup, Icons.folder_open];
                  return InkWell(
                    onTap: () => print('${titles[index]} 기능 실행!'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icons[index], size: 40, color: Colors.blue[800]),
                          const SizedBox(height: 8),
                          Text(titles[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultationScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.flash_on, color: Colors.blue, size: 24),
                      SizedBox(width: 8),
                      Text('실시간 보상상담 (24시간)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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

void _sendMessage(String text) async { // async 추가
    if (text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    _controller.clear();

    // 1. 사용자 메시지를 먼저 화면에 표시
    setState(() {
      _messages.add({'text': text, 'isUser': true});
    });

    // 2. ApiService를 통해 서버로 메시지 전송 및 응답 받기
    final botReply = await ApiService.sendMessageToChatbot(text);
    
    // 3. 서버로부터 받은 답변을 화면에 표시
    setState(() {
      _messages.add({'text': botReply, 'isUser': false});
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
          color: isUser ? Colors.blue[600] : Colors.grey[200],
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
  final String _userName = "사용자";

  void _handleLoginResult(bool loginSuccess) {
    if (loginSuccess) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }
  
  void _logout() {
    setState(() {
      _isLoggedIn = false;
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
        : _buildLoggedOutView(),
    );
  }

  Widget _buildLoggedOutView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('로그인이 필요합니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ).then((result) {
                  if (result == true) {
                    _handleLoginResult(true);
                  }
                });
              },
              child: const Text('로그인/회원가입', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return ListView(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text('${_userName}님', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          accountEmail: const Text('환영합니다!'),
          currentAccountPicture: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50),
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

// 로그인 페이지
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('로그인', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// 상담 이력 페이지
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, String>> _history = const [
    {'title': '자동차 접촉사고 과실비율 문의', 'date': '2025-08-28', 'status': '답변 완료'},
    {'title': '실손의료보험금 청구 서류 문의', 'date': '2025-08-15', 'status': '답변 완료'},
    {'title': '상해 후유장해 평가 관련', 'date': '2025-07-30', 'status': '답변 완료'},
    {'title': '질병 진단금 청구 가능 여부', 'date': '2025-07-02', 'status': '답변 완료'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상담 이력'),
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: Text(item['title']!),
              subtitle: Text(item['date']!),
              trailing: Text(
                item['status']!,
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
        title: const Text('실시간 보상 상담', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _isAgreed) {
                        print('상담 신청 완료');
                        print('이름: ${_nameController.text}');
                        print('전화번호: ${_phoneController.text}');
                        Navigator.pop(context);
                      } else if (!_isAgreed) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('개인정보 수집에 동의해야 합니다.')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('손해사정사 연결하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
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
  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    const String resultData =
        '보험금 청구는 질병, 상해, 사고 등 약관에 명시된 보험사고가 발생했을 때, 계약자가 보험사에 보상을 요청하는 정당한 권리입니다.\n\n'
        '정확한 보험금 산정을 위해서는 사고나 질병을 입증할 수 있는 병원 서류(진단서, 영수증 등), 사고 사실 확인서, 그리고 기타 보험사가 요청하는 서류들을 꼼꼼히 준비하는 것이 중요합니다.\n\n'
        '서류가 접수되면 보험사는 손해사정사를 통해 사고를 조사하고, 약관에 따라 보상 금액을 결정하여 지급 절차를 진행하게 됩니다. 전문가의 도움이 필요하다면 언제든 상담을 요청하세요.';
    
    bool hasResults = searchQuery.contains('보험금') || searchQuery.contains('사고');

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('"${searchQuery}"에 대한 검색 결과입니다.', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            if (hasResults)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                ),
                child: Text(resultData, style: const TextStyle(fontSize: 16, height: 1.5)),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('"${searchQuery}"에 대한\n검색 결과를 찾을 수 없습니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey[600], height: 1.4)),
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

