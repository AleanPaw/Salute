import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salutepfi/adms/AdmPag.dart';
import 'package:salutepfi/commons/Snackbar.dart';
import 'package:salutepfi/servicos/autenticacao.dart';



class CadastroAdm extends StatefulWidget {
  const CadastroAdm({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState ();
}

class _CadastroPageState  extends State<CadastroAdm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaConfirmarController = TextEditingController();
  final AutenticacaoServicos _autenServicos = AutenticacaoServicos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Cadastrar administradores:",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome completo'),
              ),
              const SizedBox(height: 10),
              TextFormField(
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
              TextField(
                controller: _senhaConfirmarController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Comfirmar senha:'
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: cadastrarAdm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
                child: const Text(
                  "Cadastrar",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => const AdmPag(),
      ),
    );
  }
  cadastrarAdm() {
    int validacao = 0;
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text;
    String senhaConfirmar = _senhaConfirmarController.text;

    if (nome.isEmpty) {
      _showErrorDialog('Por favor, insira seu nome completo.');
      validacao++;
      return;
    }

    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email)) {
      _showErrorDialog('Por favor, insira um email válido.');
      validacao++;
      return;
    }
    if (senha.length < 6) {
      _showErrorDialog('A senha deve ter pelo menos 6 caracteres.');
      validacao++;
      return;
    }
    if (senha != senhaConfirmar) {
      _showErrorDialog('As senhas não correspondem. Por favor, tente novamente.');
      validacao++;
      return;
    }
    if(validacao == 0){
      print("${nome}, ${email},${senha},${senhaConfirmar}");
      _autenServicos.cadastrarAdm(nome: nome, email: email, senha: senha).
      then(
            (String? erro){
          if(erro != null){
            mostrarSnackBar(context: context, texto: erro);
          }else{
            mostrarSnackBar(context: context, texto: "Cadastro realizado com sucesso", isErro: false);
            Duration duration = const Duration(seconds: 0);
            return Timer(duration, _navigateToNextScreen);
          }
        },
      );
    }
  }
}