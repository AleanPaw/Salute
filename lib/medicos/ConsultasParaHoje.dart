import 'dart:io';
import 'package:chakre_pdf_viewer/chakre_pdf_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:salutepfi/medicos/MedicoPag.dart';


class ConsultasParahoje extends StatelessWidget {
   ConsultasParahoje({super.key, Key});


  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var now = DateTime.now();
    var startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 0, 0, 0));
    var endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

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
            _buildConsultasList(user!, startOfDay, endOfDay),
          ],
        ),

      ),
    );
  }
  late User? _user = FirebaseAuth.instance.currentUser;
  Widget _buildConsultasList(User user, Timestamp startOfDay, Timestamp endOfDay) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('consultas')
          .where('dataConsulta', isGreaterThanOrEqualTo: startOfDay)
          .where('dataConsulta', isLessThanOrEqualTo: endOfDay)
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
              var cidadeConsulta = consulta['cidade'];
              return especialidadeConsulta == especialidadeDoMedico && cidadeConsulta == cidadeConsulta;
            }).toList();

            return ListView.builder(
              itemCount: consultasFiltradas.length,
              itemBuilder: (context, index) {
                var consulta = consultasFiltradas[index];
                var data = consulta['dataConsulta'].toDate();
                var dataFormatada = formatarData(data);
                var tipo = consulta['tipoConsulta'];
                var nome = consulta['nomeUsuario'];
                var documento = consulta.id;
                var status = consulta['status'];
                var historioco = consulta['historioco'];

                return ListTile(
                  title: Text('Consulta: $tipo'),
                  subtitle: Text('Data: $dataFormatada \n$nome'),
                  trailing: status == 'pendente'
                      ? IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PacienteConsultando(
                                    tipoExame: tipo,
                                    dataExame: data,
                                    nomeUsuario: nome,
                                    id: user.uid,
                                    nomeDocumento: documento,
                                    histo: historioco,
                          ),
                        ),
                      );
                    },
                  )
                      : IconButton(
                            icon: const Icon(Icons.verified, color: Colors.black),
                            onPressed: () {},
                  ),
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
class PacienteConsultando extends StatefulWidget {
  final String tipoExame;
  final DateTime dataExame;
  final String nomeUsuario;
  final String id;
  final String nomeDocumento;
  final String histo;

  PacienteConsultando({
    required this.tipoExame,
    required this.dataExame,
    required this.nomeUsuario,
    required this.id,
    required this.nomeDocumento,
    required this.histo,
    Key? key,
  }) : super(key: key);

  @override
  _PacienteConsultandoState createState() => _PacienteConsultandoState();
}

class _PacienteConsultandoState extends State<PacienteConsultando> {
  final TextEditingController _comentarioController = TextEditingController();
  late File _file;
  String? _fileName;
  late final String filePath;

  @override
  void initState() {
    super.initState();
    filePath = widget.histo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0077B6),
        title: const Text(
          'Consulta',
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
              Text("Nome: ${widget.nomeUsuario}\nTipo: ${widget.tipoExame}"),
              const SizedBox(height: 10),
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(labelText: 'Comentário'),
              ),
              const SizedBox(height: 15),
              const Text('Receita médica:', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectFile,
                child: Text('Selecionar Arquivo'),
              ),
              const SizedBox(height: 10),
              if (_fileName != null) Text('Arquivo Selecionado: $_fileName'),
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
                child: const Text('Abrir o historioco medico do paciente'),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_file != null) {
                      await _uploadPDF(widget.nomeDocumento, _comentarioController.text, _file);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsultasParahoje(),
                        ),
                      );
                    } else {
                      print('Por favor, selecione um arquivo PDF.');
                    }
                  },
                  label: const Text('Concluir'),
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    } else {
      print("Nada");
    }
  }

  Future<void> _uploadPDF(String idExame, String comentario, File pdfFile) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child('pdfs/${DateTime.now()}.pdf');
      UploadTask uploadTask = storageReference.putFile(pdfFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await storageReference.getDownloadURL();

      await FirebaseFirestore.instance.collection('consultas').doc(idExame).update({
        'comentario': comentario,
        'pdfURL': downloadURL,
        'status': 'concluida',
      });

      print('Comentário e PDF adicionados com sucesso!');
    } catch (e) {
      print('Erro ao fazer o upload do PDF: $e');
    }
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

