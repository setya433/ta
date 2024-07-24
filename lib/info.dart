import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        elevation: 0,
        title: Text(''),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300]!, Colors.blue[100]!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                'Pemanfaatan kecerdasan buatan, terutama melalui aplikasi berbasis Android, menjadi suatu terobosan yang signifikan dalam mengimplementasikan teknologi Speech Recognition di dalam lingkungan Smart Home. Sistem Aplikasi AI berbasis Android untuk implementasi Speech Recognition dalam bidang IoT Smart Home memberikan solusi inovatif dalam mengintegrasikan perangkat-perangkat yang ada di rumah menjadi suatu ekosistem pintar yang dapat dioperasikan dengan menggunakan suara. Dengan memanfaatkan teknologi ini, pengguna dapat mengontrol perangkat secara verbal di Rumah Pintar, sehingga meningkatkan kenyamanan dan interaksi pengguna.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[300],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'VOICE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '',
          ),

        
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          // Handle bottom navigation tap
        },
      ),
    );
  }
}
