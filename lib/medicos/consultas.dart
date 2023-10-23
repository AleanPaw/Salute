
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:salutepfi/medicos/MedicoPag.dart';


class Consultas extends StatelessWidget {
  Consultas({Key? key});


  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    var now = DateTime.now();
    var startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 0, 0, 0));

    return DefaultTabController(
      length: 1,
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
                MaterialPageRoute(builder: (context) => const MedicoPag()),
              );
            },
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Consultas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildConsultasListTodas(user!, startOfDay),
          ],
        ),

      ),
    );
  }

  late User? _user = FirebaseAuth.instance.currentUser;
  Widget _buildConsultasListTodas(User user, Timestamp startOfDay) {

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('consultas')
          .where('dataConsulta', isGreaterThanOrEqualTo: startOfDay)
          .orderBy('dataConsulta', descending: false)
          .snapshots(),
      builder: (context, consultaSnapshot) {
        if (!consultaSnapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var consultas = consultaSnapshot.data!.docs;

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(_user?.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var especialidadeDoMedico = userSnapshot.data!['especialidade'];

            var consultasFiltradas = consultas.where((consulta) {
              var especialidadeConsulta = consulta['tipoConsulta'];
              return especialidadeConsulta == especialidadeDoMedico;
            }).toList();

            return ListView.builder(
              itemCount: consultasFiltradas.length,
              itemBuilder: (context, index) {
                var consulta = consultasFiltradas[index];
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
      },
    );
  }

  String formatarData(DateTime data) {
    var formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(data);
  }
}
