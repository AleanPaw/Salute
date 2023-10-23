import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PacientPag.dart';
import 'package:intl/intl.dart';

class ConsultasExamesList extends StatelessWidget {
  const ConsultasExamesList({super.key});

  DateTime converterParaFuso(Timestamp dataUtc) {
    DateTime dataUtcConvertida = dataUtc.toDate();
    var fusoHorarioBrasil = DateTime.now().timeZoneOffset;
    return dataUtcConvertida.subtract(fusoHorarioBrasil);
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final userEmail = user?.email;

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
                MaterialPageRoute(builder: (context) => const PacientePag()),
              );
            },
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Consultas'),
              Tab(text: 'Exames',),
            ],

          ),
        ),
        body: TabBarView(
          children: [
            _buildConsultasList(userEmail!),
            _buildExamesList(userEmail!),
          ],
        ),
      ),
    );
  }


   Widget _buildConsultasList(String userEmail) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('consultas')
          .where('emailUsuario', isEqualTo: userEmail)
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
            Timestamp data = consulta['dataConsulta'];
            DateTime dataConvertida = converterParaFuso(data);
            String dataFormatada = DateFormat('dd/MM/yyyy').format(dataConvertida);
            var status = consulta['status'];

            var diferencaEmHoras = dataConvertida.difference(DateTime.now()).inHours;

            bool podeCancelar = (status == "pendente" && diferencaEmHoras >= 24);


            var tipo = consulta['tipoConsulta'];
            var consultaId = consultas[index].id;
            return ListTile(
              title: Text('Consulta: $tipo'),
              subtitle: Text('Data: $dataFormatada'),
              trailing: podeCancelar
                  ? ElevatedButton(
                    onPressed: () async {
                      _mostrarDialogoConfirmacao(context, consultaId, userEmail);
                    },
                        child: const Text('Cancelar'),
                  )
                      : null,

            );
          },
        );
      },
    );
  }

  Widget _buildExamesList(String userEmail) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('exames')
          .where('emailUsuario', isEqualTo: userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var exames = snapshot.data!.docs;

        return ListView.builder(
          itemCount: exames.length,
          itemBuilder: (context, index) {
            var exame = exames[index].data();
            Timestamp data = exame['dataExame'];
            DateTime dataConvertida = converterParaFuso(data);
            String dataFormatada = DateFormat('dd/MM/yyyy').format(dataConvertida);
            var tipo = exame['tipoExame'];
            var exameId = exames[index].id;
            var status = exame['status'];

            var diferencaEmHoras = dataConvertida.difference(DateTime.now()).inHours;

            bool podeCancelar = (status == "pendente" && diferencaEmHoras >= 24);



            return ListTile(
              title: Text('Exame: $tipo'),
              subtitle: Text('Data: $dataFormatada'),

              trailing: podeCancelar
                      ? ElevatedButton(
                         onPressed: () async {
                          _mostrarDialogoConfirmacaoExame(context, exameId, userEmail);
                    },
                          child: const Text('Cancelar'),
                  )
                      : null,


            );
          },
        );
      },
    );
  }
  Future<void> _mostrarDialogoConfirmacaoExame(BuildContext context, String consultaId, String userEmail) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar consulta'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja cancelar esta consulta?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                _cancelarExame(consultaId, userEmail);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

    void _cancelarExame(String exameId, String userEmail) {
      FirebaseFirestore.instance
          .collection('exames')
          .where('emailUsuario', isEqualTo: userEmail)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (doc.id == exameId) {
            doc.reference.delete();
          }
        }
      });

    }

  Future<void> _mostrarDialogoConfirmacao(BuildContext context, String consultaId, String userEmail) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar consulta'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja cancelar esta consulta?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                _cancelarConsulta(consultaId, userEmail);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _cancelarConsulta(String consultaId, String userEmail) {

    FirebaseFirestore.instance
        .collection('consultas')
        .where('emailUsuario', isEqualTo: userEmail)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.id == consultaId) {
          doc.reference.delete();
        }
      }
    });
  }


}

