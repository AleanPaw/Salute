import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:salutepfi/users/PacientPag.dart';
import 'adms/AdmPag.dart';
import 'medicos/MedicoPag.dart';
import 'firebase_options.dart';
import 'Entrada.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  WidgetsFlutterBinding.ensureInitialized();



  runApp( MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
    debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('pt', 'BR'),
      ],
      home: Roteador(),
    );
  }
}
class Roteador extends StatelessWidget {
  const Roteador({Key? key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Erro ao autenticar o usuário.');
        } else if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator(
                  value: 1,
                )
                ;
              } else if (userSnapshot.hasError) {
                return const Text('Erro ao carregar dados do usuário.');
              } else if (!userSnapshot.hasData || userSnapshot.data == null || !userSnapshot.data!.exists) {
                print('UID do usuário autenticado: ${snapshot.data!.uid}');
                return const entrada();
              } else {
                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                String userType = userData['tipo'];
                if (userType == 'medico') {
                  return const MedicoPag();
                } else if (userType == 'adm') {
                  return const AdmPag();
                } else {
                  return const PacientePag();
                }
              }
            },
          );
        } else {
          return const entrada();
        }
      },
    );
  }
}