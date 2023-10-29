import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salutepfi/adms/AdmPag.dart';
import 'package:salutepfi/commons/Snackbar.dart';
import 'package:salutepfi/servicos/autenticacao.dart';



class CadastroMedico extends StatefulWidget {
  const CadastroMedico({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState ();
}

class _CadastroPageState  extends State<CadastroMedico> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaConfirmarController = TextEditingController();
  final TextEditingController _espeController = TextEditingController();
  final AutenticacaoServicos _autenServicos = AutenticacaoServicos();
  String selectedValue = 'Geral';
  String selectedCidade = 'Quedas Do Iguaçu';

  List<String> options = [
    'Geral',
    'Pediatria',
    'Ginecologia',
    'Obstetrícia',
    'Oftalmologia',
    'Odontologia',
    'Psicologia',
    'Psiquiatria',
  ];
  List<String> options2 = [
    'Quedas Do Iguaçu',
    'Cascavel',
  ];


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
                "Cadastrar médico e assistentes:",
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
              const SizedBox(height: 10),
              TextField(
                controller: _senhaConfirmarController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirmar senha:'
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Especialidade:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
              DropdownButton<String>(
                value: selectedValue,
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                }).toList(),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                ),
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24.0,
                elevation: 16,
                underline: Container(),
                alignment: Alignment.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Cidade:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
              DropdownButton<String>(
                value: selectedCidade,
                onChanged: (newValue) {
                  setState(() {
                    selectedCidade = newValue!;
                  });
                },
                items: options2.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                }).toList(),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                ),
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24.0,
                elevation: 16,
                underline: Container(),
                alignment: Alignment.center,
              ),
              const Divider(
                color: Colors.black,
                height: 5,
                thickness: 1,

              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: cadastrarMedico,
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
  cadastrarMedico() {
    int validacao = 0;
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text;
    String senhaConfirmar = _senhaConfirmarController.text;
    String especialidade = selectedValue;
    if (nome.isEmpty) {
      _showErrorDialog('Por favor, insira seu nome completo.');
      validacao++;
      return;
    }
    if (especialidade.isEmpty) {
      _showErrorDialog('Por favor, insira a especialidade.');
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
      _autenServicos.cadastrarMedico(nome: nome, email: email, senha: senha, especialista: especialidade,cidade: selectedCidade).
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