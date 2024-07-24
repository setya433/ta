import 'package:flutter/material.dart';
//import 'package:projek_ta_smarthome/home_screen.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.person, size: 100),
              SizedBox(height: 10),
              Text('HI USER!', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: <Widget>[
              ControlButton(title: 'Lampu Ruang Tamu', status: 'ON', color: Colors.green),
              ControlButton(title: 'Lampu Ruang Keluarga', status: 'OFF', color: Colors.red),
              ControlButton(title: 'Kipas Angin', status: 'ON', color: Colors.blue),
              ControlButton(title: 'Temperature Suhu', status: '19°C', color: Colors.yellow),
            ],
          ),
        ),
      ],
    );
  }
}

class ControlButton extends StatefulWidget {
  final String title;
  final String status;
  final Color color;

  ControlButton({required this.title, required this.status, required this.color});

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Text(
              widget.status,
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
