import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:salutepfi/adms/AdmPag.dart';
import 'package:salutepfi/commons/Snackbar.dart';


class ExameList extends StatelessWidget {
  const ExameList({Key? key}) : super(key: key);

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
                MaterialPageRoute(builder: (context) => const AdmPag()),
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
              Tab(icon: Icon(Icons.list), text: 'Exame:'),
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

  Widget _buildConsultasList(User user, Timestamp startOfDay, Timestamp endOfDay) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('exames')
          .where('dataExame', isGreaterThanOrEqualTo: startOfDay)
          .where('dataExame', isLessThanOrEqualTo: endOfDay)
          .orderBy('dataExame', descending: false)
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
              var nome = exame['nomeUsuario'];
              var documento = exame.id;
              var status = exame['status'];
              return ListTile(
                title: Text('Exame: $tipo'),
                subtitle: Text('Data: $dataFormatada \n$nome'),
                trailing: status == 'pendente' ? IconButton(
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
                        ),
                      ),
                    );
                  },
                ) : IconButton(
                  icon: const Icon(Icons.verified, color: Colors.black), onPressed: () {},),
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
}
class PacienteConsultando extends StatefulWidget {
  final String tipoExame;
  final DateTime dataExame;
  final String nomeUsuario;
  final String id;
  final String nomeDocumento;

  PacienteConsultando({
    required this.tipoExame,
    required this.dataExame,
    required this.nomeUsuario,
    required this.id,
    required this.nomeDocumento,
    Key? key,
  }) : super(key: key);

  @override
  _PacienteConsultandoState createState() => _PacienteConsultandoState();
}

class _PacienteConsultandoState extends State<PacienteConsultando> {
  final TextEditingController _comentarioController = TextEditingController();
  late File _file;
  String? _fileName;

  @override
  Widget build(BuildContext context) {
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
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(labelText: 'Comentário'),
              ),
              const SizedBox(height: 15),
              const Text('Exame:', textAlign: TextAlign.center),
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
                      await _uploadPDF(widget.nomeDocumento, _comentarioController.text, _file);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExameList(),
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
        print(_fileName);
      });
    } else {
      print("Nada");
    }
  }

  Future<void> _uploadPDF(String idExame, String comentario, File pdfFile) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
    try {
        Reference storageReference = FirebaseStorage.instance.ref().child('pdfs/${DateTime.now()}.pdf');
        UploadTask uploadTask = storageReference.putFile(pdfFile);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String downloadURL = await storageReference.getDownloadURL();

        await FirebaseFirestore.instance.collection('exames').doc(idExame).update({
          'comentario': comentario,
          'pdfURL': downloadURL,
          'status': 'concluida',
        });

        mostrarSnackBar(texto: 'Comentário e PDF adicionados com sucesso!', context: context, isErro: false);
      } catch (e) {
      mostrarSnackBar(texto: 'Erro ao fazer o upload do PDF: $e', context: context);
      print('Erro ao fazer o upload do PDF: $e');
    }
  }else {
      // O usuário não está autenticado. Redirecione-o para a tela de login ou autenticação.
      // Você também pode mostrar uma mensagem para informar ao usuário que ele precisa estar autenticado.
      mostrarSnackBar(texto: 'Você precisa estar autenticado para fazer upload do PDF.', context: context);
    }
}
}
