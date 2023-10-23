// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chakre_pdf_viewer/chakre_pdf_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salutepfi/commons/Snackbar.dart';
import 'package:salutepfi/users/PacientPag.dart';

class HistoricoPaciente extends StatelessWidget {
  const HistoricoPaciente({Key? key}) : super(key: key);

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
              Tab(icon: Icon(Icons.list), text: 'Histórico médico:'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AddHistorico(),
          ],
        ),
      ),
    );
  }
}

class AddHistorico extends StatefulWidget {
  @override
  _AddHistoricoState createState() => _AddHistoricoState();
}

class _AddHistoricoState extends State<AddHistorico> {
  late File _file;
  String? _fileName;



  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),
              const Text('Adicionar histórico:', textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectFile,
                child: const Text('Selecionar Arquivo'),
              ),
              const SizedBox(height: 10),
              if (_fileName != null) Text('Arquivo Selecionado: $_fileName'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_file != null) {
                      await _uploadPDF(_file);
                    } else {
                      print('Por favor, selecione um arquivo PDF.');
                      mostrarSnackBar(context: context, texto: 'Por favor, selecione um arquivo PDF .');
                    }
                  },
                  label: const Text('Salvar'),
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .get();

                    if (userDoc.exists) {
                      var historico = userDoc['historico'];
                      if (historico != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => pdfVisualizar(file: historico),
                          ),
                        );
                      } else {
                        mostrarSnackBar(context: context, texto: "Histórico médico não encontrado");
                      }
                    } else {
                      mostrarSnackBar(context: context, texto: 'Documento do usuário não encontrado');
                      print('Documento do usuário não encontrado.');
                    }
                  },

                  label: const Text('Ver histórico'),
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
        print(_fileName);
      });
    } else {
      print("Nada");
    }
  }

  Future<void> _uploadPDF(File pdfFile) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        Reference storageReference = FirebaseStorage.instance.ref().child('pdfs/${DateTime.now()}.pdf');
        UploadTask uploadTask = storageReference.putFile(pdfFile);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String downloadURL = await storageReference.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'historico': downloadURL,
        });

        mostrarSnackBar(texto: 'PDF adicionado com sucesso!', context: context, isErro: false);
      } catch (e) {
        mostrarSnackBar(texto: 'Erro ao fazer o upload do PDF: $e', context: context);
        print('Erro ao fazer o upload do PDF: $e');
      }
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