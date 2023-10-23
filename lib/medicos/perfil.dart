// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salutepfi/servicos/autenticacao.dart';
import '../Entrada.dart';
import '../commons/Snackbar.dart';
import 'MedicoPag.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  late User? _user = FirebaseAuth.instance.currentUser;
  final AutenticacaoServicos _autenServicos = AutenticacaoServicos();
  String? email;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    email = _user?.email;
  }
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
              MaterialPageRoute(builder: (context) => const MedicoPag()),
            );
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              _user?.displayName ?? "Nome do Usuário",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _user?.email ?? "Email do Usuário",
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () => _autenServicos.resetSenha(email: email!).then(
                      (String? erro){
                    if(erro != null){
                      mostrarSnackBar(context: context, texto: erro);
                    }else{
                      mostrarSnackBar(context: context, texto: "Email enviado", isErro: false);
                    }
                  },
                ),
                label: const Text('Mudar senha'),
                icon: const Icon(Icons.arrow_forward),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: const Color(0xff90E0EF), shape: RoundedRectangleBorder(
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
                  String? senha = await _pedirSenha(context);
                  if (senha != null) {
                    AutenticacaoServicos().deleteConta(senha: senha).then((String? erro) {
                      if (erro != null) {
                        mostrarSnackBar(context: context, texto: erro);
                      } else {
                        mostrarSnackBar(context: context, texto: "Conta deletada");
                      }
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const entrada()),
                    );
                  }
                },
                label: const Text('Deletar conta'),
                icon: const Icon(Icons.arrow_forward),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.red, shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  AutenticacaoServicos().deslogar();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const entrada()),
                  );
                },
                label: const Text('Sair'),
                icon: const Icon(Icons.arrow_forward),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: const Color(0xff90E0EF), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<String?> _pedirSenha(BuildContext context) async {
    String? senha;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Digite sua senha'),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              senha = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop(senha);
              },
            ),
          ],
        );
      },
    );
    return senha;
  }
}
