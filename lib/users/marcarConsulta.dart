import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salutepfi/commons/Snackbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'PacientPag.dart';


var now = DateTime.now();
var firstDay = DateTime(now.year, now.month - 3, now.day);
var lastDay = DateTime(now.year, now.month + 3, now.day);

class Consulta extends StatelessWidget {
  const Consulta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MarcarConsulta(),
    );
  }
}

class MarcarConsulta extends StatefulWidget {
  @override
  _MarcarConsultaState createState() => _MarcarConsultaState();
}

class _MarcarConsultaState extends State<MarcarConsulta> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _dataSelecionada = DateTime.now();
  bool _isDataValida() {
    DateTime dataAtual = DateTime.now();
    return !_dataSelecionada.isBefore(dataAtual);
  }
  String selectedValue = 'Geral';

  final TextEditingController _motivoConsultaController = TextEditingController();


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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _dataSelecionada = selectedDay;
    });
  }
  _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => PacientePag(),
      ),
    );
  }

   _marcarConsulta() async {
    User? user = FirebaseAuth.instance.currentUser;
    String motivoConsulta = _motivoConsultaController.text;
    var cidade;
    var historioco;
    if (user != null && motivoConsulta.isNotEmpty) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();
          var data = snapshot.data() as Map<String, dynamic>;
          cidade = data['cidade'];
          historioco = data['historioco'];

        await FirebaseFirestore.instance.collection('consultas').add({
          'userId': user.uid,
          'nomeUsuario': user.displayName,
          'emailUsuario': user.email,
          'tipoConsulta': selectedValue,
          'dataConsulta': _dataSelecionada,
          'motivoConsulta': _motivoConsultaController.text,
          'comentario': "",
          'status': "pendente",
          'pdfURl': "",
          'cidade': cidade,
          'historioco': historioco,
        });

        mostrarSnackBar(context: context, texto: "Consulta marcada com sucesso!!",isErro: false);
        Duration duration = const Duration(seconds: 1);
        return Timer(duration, () {
          _navigateToNextScreen();
        });
      } catch (e) {
        mostrarSnackBar(context: context,texto: 'Erro ao marcar consulta $e');
      }
    } else {
      mostrarSnackBar(context: context,texto: 'Motivo da consulta está vazio');
    }
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
              MaterialPageRoute(builder: (context) => const PacientePag()),
            );
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Escolha o tipo de consulta abaixo",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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
          const Divider(
            color: Colors.black,
            height: 20,
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
          const SizedBox(height: 20),
          const Text(
            "Escolha a data da consulta",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TableCalendar(
            locale: 'pt_BR',
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mês',
            },
            focusedDay: now,
            firstDay: firstDay,
            lastDay: lastDay,
            onPageChanged: (value) {},
            onDaySelected: _onDaySelected,
            selectedDayPredicate: (day) {
              return isSameDay(_dataSelecionada, day);
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Data selecionada: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}',
            style: TextStyle(
              fontSize: 18,
              color: _dataSelecionada.isBefore(DateTime.now()) || _dataSelecionada.isAtSameMomentAs(DateTime.now())
                  ? Colors.red
                  : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          if (_dataSelecionada.isBefore(DateTime.now()) || _dataSelecionada.isAtSameMomentAs(DateTime.now()))
            const Text(
              'Esta data está indisponível',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 10),
         TextField(
            controller: _motivoConsultaController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Por que vai consultar?',
            ),
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_isDataValida()) {
               _marcarConsulta();
               } else {

                  mostrarSnackBar(context: context, texto: 'Data inválida. Selecione uma data futura.');

                  }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
            ),
            child: const Text(
              "Confirmar",
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
    );
  }
}



