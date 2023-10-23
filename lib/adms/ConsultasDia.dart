import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salutepfi/adms/AdmPag.dart';
import 'package:intl/intl.dart';

class ConsultasList extends StatelessWidget {
  const ConsultasList({Key? key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var now = DateTime.now();
    var startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 0, 0, 0));
    var endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff0077B6),
          title: const Text(
            "Voltar",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdmPag()),
              );
            },
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            _buildConsultasList(user!, startOfDay, endOfDay),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultasList(User user, Timestamp startOfDay, Timestamp endOfDay) {

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('consultas')
          .where('dataConsulta', isGreaterThanOrEqualTo: startOfDay)
          .where('dataConsulta', isLessThanOrEqualTo: endOfDay)
          .orderBy('dataConsulta', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var consultas = snapshot.data!.docs;

        return ListView.builder(
          itemCount: consultas.length,
          itemBuilder: (context, index) {
            var consulta = consultas[index].data();
            var data = consulta['dataConsulta'].toDate();
            var dataFormatada = formatarData(data);
            var tipo = consulta['tipoConsulta'];
            var nome = consulta['nomeUsuario'];

            return ListTile(
              title: Text('Consulta: $tipo'),
              subtitle: Text('Data: $dataFormatada \n$nome'),
            );
          },
        );
      },
    );
  }

  String formatarData(DateTime data) {
    var formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(data);
  }
}
