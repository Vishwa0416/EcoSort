import 'package:flutter/material.dart';
import 'package:ecosort/helpers/helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  final String message;
  final Map<String, dynamic> userData;

  const HomePage({required this.message, required this.userData, Key? key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _savedUsers = [];
  final ScrollController _scrollController = ScrollController();
  bool _isScrollable = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _printDatabasePath();
    _scrollController.addListener(_checkIfScrollable);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkIfScrollable() {
    setState(() {
      _isScrollable = _scrollController.position.maxScrollExtent > 0 &&
          !_scrollController.position.atEdge;
    });
  }

  // Function to print the database path
  Future<void> _printDatabasePath() async {
    String dbPath = await getDatabasesPath();
    String fullDbPath = join(dbPath, 'user_data.db');
    debugPrint("Database path: $fullDbPath");
  }

  // Fetch users from the database
  Future<void> _fetchUsers() async {
    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getUsers();
    setState(() {
      _savedUsers = users;
    });
  }

  void _saveToDatabase(BuildContext context) async {
    final dbHelper = DatabaseHelper();

    // Prepare user data for insertion
    final Map<String, dynamic> user = {
      'display_name': widget.userData['User_Display_Name'] ?? 'N/A',
      'email': widget.userData['Email'] ?? 'N/A',
      'user_code': widget.userData['User_Code'] ?? 'N/A',
      'employee_code': widget.userData['User_Employee_Code'] ?? 'N/A',
      'company_code': widget.userData['Company_Code'] ?? 'N/A',
    };

    try {
      await dbHelper.insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data saved successfully!')),
      );
      _fetchUsers(); // Refresh the saved users list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        title: const Center(
          child: Text('EcoSort'), // Centers the title
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message: ${widget.message}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'User Details:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildUserDetailsRow(
                  'Name', widget.userData['User_Display_Name']),
              _buildUserDetailsRow('Email', widget.userData['Email']),
              _buildUserDetailsRow('User Code', widget.userData['User_Code']),
              _buildUserDetailsRow(
                  'Employee Code', widget.userData['User_Employee_Code']),
              _buildUserDetailsRow(
                  'Company Code', widget.userData['Company_Code']),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _saveToDatabase(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Save to Database',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Saved Users:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  SizedBox(
                    height: 200, // Adjust height for scrolling
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _savedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _savedUsers[index];
                        return ListTile(
                          title: Text(user['display_name'] ?? 'N/A'),
                          subtitle: Text(user['email'] ?? 'N/A'),
                          trailing: Text(user['user_code'] ?? 'N/A'),
                        );
                      },
                    ),
                  ),
                  if (_isScrollable)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 20,
                        ),
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

  Widget _buildUserDetailsRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
