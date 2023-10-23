// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salutepfi/users/historico.dart';
import 'package:salutepfi/users/perfil.dart';
import 'package:salutepfi/users/receitasMedicas.dart';
import 'package:salutepfi/users/resultadoExame.dart';
import 'consultasExames.dart';
import 'marcarConsulta.dart';
import 'marcarExame.dart';


class PacientePag extends StatelessWidget {
  const PacientePag({super.key});


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
                MaterialPageRoute(builder: (context) => const Consulta()),
              );
            },
            label: const Text('Marcar consulta'),
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
                MaterialPageRoute(builder: (context) => const Exames()),
              );
            },
            label: const Text('Marcar exame'),
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
                MaterialPageRoute(builder: (context) => const ConsultasExamesList()),
              );
            },
            label: const Text('Consultas e examas agendados'),
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
              onPressed: () async {
                String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

                QuerySnapshot receitasQuery = await FirebaseFirestore.instance
                    .collection('exames')
                    .where('userId', isEqualTo: userId)
                    .where('status', whereIn: ['concluido'])
                    .get();

                QuerySnapshot examesQuery = await FirebaseFirestore.instance
                    .collection('consultas')
                    .where('userId', isEqualTo: userId)
                    .where('status', whereIn: ['concluido'])
                    .get();

                if (receitasQuery.docs.isEmpty && examesQuery.docs.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Nenhum resultado disponível'),
                        content: const Text('Você ainda não tem um exame concluído.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const resultadoExame()),
                  );
                }
              },
              label: const Text('Resultados de exames'),
              icon: const Icon(Icons.arrow_forward),
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
              onPressed: () async {
                String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

                QuerySnapshot receitasQuery = await FirebaseFirestore.instance
                    .collection('exames')
                    .where('userId', isEqualTo: userId)
                    .where('status', whereIn: ['concluido'])
                    .get();

                QuerySnapshot examesQuery = await FirebaseFirestore.instance
                    .collection('consultas')
                    .where('userId', isEqualTo: userId)
                    .where('status', whereIn: [ 'concluido'])
                    .get();

                if (receitasQuery.docs.isEmpty && examesQuery.docs.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Nenhum resultado disponível'),
                        content: const Text('Você ainda não tem uma receita médica.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReceitaMedica()),
                  );
                }
              },
              label: const Text('Receitas de remédios'),
              icon: const Icon(Icons.arrow_forward),
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
                  MaterialPageRoute(builder: (context) => const HistoricoPaciente()),
                );
              },
              label: const Text('Histórico medico'),
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
                MaterialPageRoute(builder: (context) => const Perfil()),
              );
            },
            label: const Text('Perfil'),
            icon: const Icon( Icons.arrow_forward, ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, backgroundColor: const Color(0xff90E0EF), shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
            ),
          ),),
        ],
      ),
    ),
    );
  }
}
