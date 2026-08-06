/* Visão mensal*/
import 'package:flutter/material.dart';
import 'package:tabela_de_turno/dados.dart';
import 'rotinas.dart';

class VisaoMensal extends StatefulWidget {
  final int ano;
  final int mes;
  final int grupo;
  const VisaoMensal({super.key, required this.ano, required this.mes, required this.grupo});

  @override
  State<VisaoMensal> createState() => _VisaoMensalState();
}

class _VisaoMensalState extends State<VisaoMensal> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: double.infinity,
      child: GestureDetector(
          onVerticalDragStart: (dstr) {
            //ToDo
          },
          onVerticalDragEnd: (valor) {
            //ToDo
          },
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: corpoTabela("m", context, pAno: widget.ano, pMes: widget.mes, pGrupo: widget.grupo)
                  ))),
    );
  }
}
