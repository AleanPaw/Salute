import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServicos{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<String?> cadastrarUsuario({
    required String nome,
    required String email ,
    required String senha,
    required String cidade,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'tipo': "paciente",
          'cidade': cidade,
          'historico': '',
        });
      }

      await userCredential.user!.updateDisplayName(nome);
      await userCredential.user!.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {

      if(e.code == "email-already-in-use"){
        return "O usuário já está cadastrado";
      }else{
        return "Erro desconhecido";
      }

    }

    }

    Future<String?> logarUsuarios({
      required String email,
      required String senha
    }) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;

    } on FirebaseAuthException catch(e){
     return e.message;
    }
    }

    Future<void> deslogar() async{
    return _firebaseAuth.signOut();
    }


    Future<String?> resetSenha({required String email}) async{
      try{
        await _firebaseAuth.sendPasswordResetEmail(email: email);
          return null;
      } on FirebaseAuthException catch (e){         
        return "Erro: $e";
      }
    }

  Future<String?> cadastrarMedico({
    required String nome,
    required String email ,
    required String senha,
    required String especialista,
    required String cidade,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'tipo': "medico",
          'especialidade': especialista,
          'cidade': cidade,
        });
      }

      await userCredential.user!.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {

      if(e.code == "email-already-in-use"){
        return "O usuário já está cadastrado";
      }else{
        return "Erro desconhecido";
      }

    }
  }

  Future<String?> cadastrarAdm({
    required String nome,
    required String email ,
    required String senha,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'tipo': "adm",
        });
      }

      await userCredential.user!.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {

      if(e.code == "email-already-in-use"){
        return "O usuário já está cadastrado";
      }else{
        return "Erro desconhecido";
      }

    }
  }
  Future<String?> deleteConta({
      required String senha
   }) async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? "";

    String? senha1 = senha;

    if (senha != null) {
      try {
        // Reautentique o usuário
        AuthCredential credential = EmailAuthProvider.credential(email: user!.email!, password: senha);
        await user.reauthenticateWithCredential(credential);

        // Exclua os documentos relacionados ao usuário
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          QuerySnapshot consultasQuery = await FirebaseFirestore.instance
              .collection('consultas')
              .where('userId', isEqualTo: userId)
              .get();
          consultasQuery.docs.forEach((consultaDoc) {
            transaction.delete(consultaDoc.reference);
          });

          QuerySnapshot examesQuery = await FirebaseFirestore.instance
              .collection('exames')
              .where('userId', isEqualTo: userId)
              .get();
          examesQuery.docs.forEach((exameDoc) {
            transaction.delete(exameDoc.reference);
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .delete();
        });

        // Exclua a conta do usuário
        await user.delete();

        return null;
      } on FirebaseAuthException catch (e) {
        print ("Erro ao excluir conta: $e");
        return "Erro ao excluir conta: $e";
      }
    } else {
      // O usuário cancelou a operação
      return "Operação cancelada pelo usuário.";
    }
  }


}
