import 'package:chakre_pdf_viewer/chakre_pdf_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'PacientPag.dart';


// ignore: camel_case_types
class resultadoExame extends StatefulWidget {
  const resultadoExame({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ResultadoExameState createState() => _ResultadoExameState();
}

class _ResultadoExameState extends State<resultadoExame> {
  final User? _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
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
                    MaterialPageRoute(builder: (context) => const PacientePag()),
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
                  Tab(icon: Icon(Icons.list), text: 'Exames:'),
                ],
              ),
      ),
            body: TabBarView(
              children: [
                _buildConsultasList(_user!),
              ],
            ),
              ),
            );
        }
      }
Widget _buildConsultasList(User user,) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('exames')
        .where('emailUsuario', isEqualTo: user.email)
          .where('status', isEqualTo: 'concluido')
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(
          child: SizedBox.shrink(),
        );
      }
      var exames = snapshot.data!.docs;

      return ListView.builder(
          itemCount: exames.length,
          itemBuilder: (context, index) {
            var exame = exames[index];
            var data = exame['dataExame'].toDate();
            var dataFormatada = formatarData(data);
            var tipo = exame['tipoExame'];
            var email = exame['emailUsuario'];
            var comentario = exame['comentario'];
            var url = exame['pdfURL'];

            return ListTile(
              title: Text('Exame: $tipo'),
              subtitle: Text('Data: $dataFormatada'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => verComPdf(
                        email: email,
                        id: user.uid,
                        nomeDocumento: exame.id,
                        comentarios: comentario,
                        pdfURL: url,
                      ),
                    ),
                  );
                },
              )
            );
          }
      );
    },
  );
}

String formatarData(DateTime data) {
  var formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(data);
}

// ignore: camel_case_types
class verComPdf extends StatefulWidget {
  final String email;
  final String id;
  final String nomeDocumento;
  final String comentarios;
  final String pdfURL;

  const verComPdf({
    required this.email,
    required this.id,
    required this.nomeDocumento,
    required this.comentarios,
    required this.pdfURL,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VerComentarioPDF createState() => _VerComentarioPDF();
}

class _VerComentarioPDF extends State<verComPdf>{
  late final String filePath;

  @override
  void initState() {
    super.initState();
    filePath = widget.pdfURL;
  }
  @override
  Widget build(BuildContext context) {
    String comentarios = widget.comentarios;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0077B6),
        title: const Text(
          'Exames',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
               Text(
               "Comentario sobre o exame:\n\n$comentarios\n"
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pdfVisualizar(file: filePath),
                    ),
                  );
                  print(filePath);
                },
                child: const Text('Abrir o arquivo'),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const resultadoExame(),
                      ),
                    );
                  },
                  label: const Text('Voltar'),
                  icon: const Icon(Icons.arrow_forward),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xff90E0EF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class pdfVisualizar extends StatefulWidget{
  final String file;

  const pdfVisualizar({super.key,
    required  this.file});

  @override
  _VerPDF createState() => _VerPDF();
}

class _VerPDF extends State<pdfVisualizar> {
  late PDFDocument _doc;

  late bool _load;


  @override
  void initState() {
    _load = false;
    super.initState();
    _initPdf();
  }

  _initPdf() async {
    print(widget.file);
    final doc = await PDFDocument.fromURL(widget.file);
    setState(() {
      _doc = doc;
      _load = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0077B6),
        title: const Text(
          'Voltar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: _load == true
          ?  PDFViewer(document: _doc)

          : const Center(
        child: CircularProgressIndicator(),
      ),


    );
  }
}

