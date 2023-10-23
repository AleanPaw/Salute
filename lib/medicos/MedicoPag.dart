import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salutepfi/medicos/perfil.dart';
import 'package:salutepfi/servicos/autenticacao.dart';
import '../Entrada.dart';
import 'ConsultasParaHoje.dart';
import 'consultas.dart';


class MedicoPag extends StatefulWidget {
  const MedicoPag({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<MedicoPag> {
  final User? _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0077B6),
        automaticallyImplyLeading: false,
        title: Text(
          _user != null ? 'Olá, ${_user?.displayName}' : 'Olá, Usuário',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.start,
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ConsultasParahoje()),
                  );
                },
                label: const Text('Consultas marcadas para hoje'),
                icon: const Icon( Icons.arrow_forward, ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xff90E0EF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),

              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  Consultas()),
                  );
                },
                label: const Text('Todas as consultas'),
                icon: const Icon( Icons.arrow_forward, ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xff90E0EF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),

              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Perfil()),
                  );
                },
                label: const Text('Perfil'),
                icon: const Icon( Icons.arrow_forward, ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor:  const Color(0xff90E0EF), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
