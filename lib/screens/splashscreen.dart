import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isAuthenticating = false;
  bool isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MANGA APP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Nicholas Adi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                // Logika otentikasi
                if (usernameController.text == 'adi' &&
                    passwordController.text == '24') {
                  setState(() {
                    isAuthenticated = true;
                    isAuthenticating = false;
                  });
                  // Navigasi ke halaman Home jika otentikasi berhasil
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                } else {
                  // Pesan kesalahan jika otentikasi gagal
                  setState(() {
                    isAuthenticating = true;
                  });
                }
              },
              child: const Text('Login'),
            ),
            if (isAuthenticating)
              const Text(
                'Username atau password salah',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
