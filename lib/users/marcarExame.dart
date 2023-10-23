import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../commons/Snackbar.dart';
import 'PacientPag.dart';


var now = DateTime.now();
var firstDay = DateTime(now.year, now.month - 3, now.day);
var lastDay = DateTime(now.year, now.month + 3, now.day);

class Exames extends StatelessWidget {
  const Exames({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MarcarExames(),
    );
  }
}

class MarcarExames extends StatefulWidget {
  const MarcarExames({super.key});

  @override
  _MarcarExamesState createState() => _MarcarExamesState();
}

class _MarcarExamesState extends State<MarcarExames> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _dataSelecionada = DateTime.now();
  bool _isDataValida() {
    DateTime dataAtual = DateTime.now();
    return !_dataSelecionada.isBefore(dataAtual);
  }
  String selectedValue = 'Testes rápidos para doenças infecciosas';


  List<String> options = [
    'Testes rápidos para doenças infecciosas',
    'Papanicolau',
    'Mamografia',
    'Glicemia ',
    'Triglicerídeos',
    'Hemograma completo',
  ];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print('Data selecionada no calendário: $selectedDay');
    setState(() {
      _dataSelecionada = selectedDay;
    });
    print('Data após a seleção: $_dataSelecionada');

  }
  _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => const PacientePag(),
      ),
    );
  }
  _marcarExames() async {
    User? user = FirebaseAuth.instance.currentUser;
    var cidade;
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();
        var data = snapshot.data() as Map<String, dynamic>;
        cidade = data['cidade'];
        var dataUtc = _dataSelecionada.toUtc();
        await FirebaseFirestore.instance.collection('exames').add({
          'userId': user?.uid,
          'nomeUsuario': user?.displayName,
          'emailUsuario': user?.email,
          'tipoExame': selectedValue,
          'dataExame': dataUtc.toLocal(),
          'status': "pendente",
          'cidade': cidade,
        });

        mostrarSnackBar(context: context, texto: "Exame marcada com sucesso!!",isErro: false);
        Duration duration = const Duration(seconds: 0);
        return Timer(duration, () {
          _navigateToNextScreen();
        });
      } catch (e) {
        mostrarSnackBar(context: context,texto: 'Erro ao marcar consulta $e');
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
            "Escolha o tipo de exame abaixo",
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:  () {
              if (_isDataValida()) {
                _marcarExames();
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
          const SizedBox(height: 20),
        ],
      ),
      ),
    );
  }
}



