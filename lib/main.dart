import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(BluetoothApp());
}

class BluetoothApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDiscoveryResult> devices = [];
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool isConnected = false;
  String receivedData = '';

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void _startDiscovery() {
    devices.clear();
    // keşfet ve sonuçları listeye ekle
    FlutterBluetoothSerial.instance
        .startDiscovery()
        .listen((BluetoothDiscoveryResult result) {
      if (!devices.any((d) => d.device.address == result.device.address)) {
        setState(() {
          devices.add(result);
        });
      }
    });
  }
  String fixTurkishChars(String input) {
    final replacements = {
      'Ã§': 'ç',
      'Ã‡': 'Ç',
      'Ã¶': 'ö',
      'Ã–': 'Ö',
      'Ã¼': 'ü',
      'Ãœ': 'Ü',
      'ÄŸ': 'ğ',
      'Äž': 'Ğ',
      'ÅŸ': 'ş',
      'Åž': 'Ş',
      'Ä±': 'ı',
      'Ä°': 'İ',
    };

    replacements.forEach((wrong, correct) {
      input = input.replaceAll(wrong, correct);
    });

    return input;
  }

  void _connect(BluetoothDevice device) async {
    setState(() {
      isConnecting = true;
      receivedData = '';
    });

    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
        isConnecting = false;
      });

      connection!.input!.listen((Uint8List data) {
        String raw = utf8.decode(data);
        String fixed = fixTurkishChars(raw);

        setState(() {
          receivedData += fixed;
        });
      }).onDone(() {
        setState(() {
          isConnected = false;
        });
      });
    } catch (e) {
      setState(() {
        isConnecting = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Bağlantı hatası: $e')));
    }
  }
  void _listBondedDevices() async {
    List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      devices = bondedDevices
          .map((device) => BluetoothDiscoveryResult(
        device: device,
        rssi: 0,
      ))
          .toList();
    });
  }


  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth Terminal")),
      body: isConnected
      // Bağlıysa gelen veriyi göster
          ? Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
            child: Text(receivedData,
                style: TextStyle(fontFamily: 'Courier'))),
      )
      // Henüz bağlanmadıysa cihaz listesini göster
          : Column(
        children: [
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text("Yeniden Tara"),
            onPressed: isConnecting ? null : _startDiscovery,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final r = devices[index];
                return ListTile(
                  leading: Icon(Icons.bluetooth),
                  title: Text(r.device.name?.isNotEmpty == true ? r.device.name! : r.device.address),
                  subtitle: Text(r.device.address),
                  trailing: isConnecting
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : null,
                  onTap: isConnecting
                      ? null
                      : () => _connect(r.device),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _listBondedDevices,
            child: Text("Eşleşmiş Cihazları Göster"),
          ),

        ],
      ),
    );
  }
}
