import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salutepfi/adms/ExamesDia.dart';
import 'package:salutepfi/adms/cadastroMedico.dart';
import 'package:salutepfi/adms/perfil.dart';
import 'ConsultasDia.dart';
import 'cadastroAdm.dart';


class AdmPag extends StatefulWidget {
  const AdmPag({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<AdmPag> {
  final User? _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0077B6),
        automaticallyImplyLeading: false,
        title: Text(
          user != null ? 'Olá, ${user.displayName}' : 'Olá, Usuário',
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
                    MaterialPageRoute(builder: (context) => const ConsultasList()),
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
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExameList()),
                    );
                  },
                label: const Text('Exames marcadas para hoje'),
                icon: const Icon( Icons.arrow_forward, ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: const Color(0xff90E0EF), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
              ),),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroAdm()),
                  );
                },
                label: const Text('Cadastrar novos administradores'),
                icon: const Icon( Icons.arrow_forward, ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: const Color(0xff90E0EF), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
              ),),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroMedico()),
                  );
                },
                label: const Text('Cadastrar novos médicos'),
                icon: const Icon( Icons.arrow_forward, ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: const Color(0xff90E0EF), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
              ),
            ),
            const SizedBox(height: 5),
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
