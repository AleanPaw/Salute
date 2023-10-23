import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salutepfi/adms/AdmPag.dart';
import 'package:salutepfi/medicos/MedicoPag.dart';
import 'package:salutepfi/servicos/autenticacao.dart';
import 'Entrada.dart';
import 'cadastrar.dart';
import 'commons/Snackbar.dart';
import 'users/PacientPag.dart';


class login extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _forgotPasswordEmailController = TextEditingController();
  final AutenticacaoServicos _autenServicos = AutenticacaoServicos();

  void _Esqueceu() {
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Esqueci a senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _forgotPasswordEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _autenServicos.resetSenha(email: _forgotPasswordEmailController.text). then(
                    (String? erro){
                  if(erro != null){
                    mostrarSnackBar(context: context, texto: erro);
                  }else{
                    mostrarSnackBar(context: context, texto: "Email enviado", isErro: false);
                  }
                  Navigator.of(context).pop();
                 },
              ),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
             onPressed: () {
                 Navigator.push(
                  context,
                   MaterialPageRoute(builder: (context) => const entrada()),
            );
             },
        ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
      ),
    body: Padding(
        padding: const EdgeInsets.all(16.0),

    child: ListView(
      children: [
          Column(
          mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Entrar:",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha:'
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _Esqueceu,
                child: const Text('Esqueceu sua senha?'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:  _entrar,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
                child: const Text(
                  "Entrar",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Ainda não tem uma conta?',
                style: TextStyle(
                  fontSize: 15,
                ),  textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Cadastro()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
                child: const Text(
                  "Criar uma conta",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );

  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  _navigateToNextScreen() {
    String email = _emailController.text.trim();
    String tipo1 = 'adm';
    String tipo2 = 'paciente';
    String tipo3 = 'medico';

    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var documento = querySnapshot.docs.first;
        var tipo = documento['tipo'];
        print('Tipo do usuário: $tipo');

        if(tipo == tipo1){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const AdmPag(),
            ),
          );
        }if(tipo == tipo3){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const MedicoPag(),
            ),
          );
        }if(tipo == tipo2){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const PacientePag(),
            ),
          );
        }
      } else {
      }
    })
        .catchError((error) {
      print( 'Erro ao consultar o Firestore: $error');
      mostrarSnackBar(context: context, texto: 'Erro ao consultar o Firestore: $error');
    });
  }

  _entrar() {
    int validacao = 0;
    String email = _emailController.text.trim();
    String senha = _senhaController.text;
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(
        email)) {
      _showErrorDialog('Por favor, insira um email válido.');
      return;
    }

    if (senha.length < 6) {
      _showErrorDialog('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    if(validacao == 0){
      print("${email},${senha}");
      _autenServicos.logarUsuarios(email: email, senha: senha).
      then(
            (String? erro){
          if(erro != null){
            mostrarSnackBar(context: context, texto: "Usuário não existe");
          }else{
            mostrarSnackBar(context: context, texto: "Login realizado com sucesso", isErro: false);
            Duration duration = const Duration(seconds: 0);
            return Timer(duration, _navigateToNextScreen);
          }
        },
      );
    }


  }

}
