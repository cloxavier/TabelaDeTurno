import 'package:flutter/material.dart';
import 'dados.dart';
import 'rotinas.dart';

class VisaoSemanal extends StatefulWidget {
  final int grupo;
  const VisaoSemanal({super.key, required this.grupo});

  @override
  State<VisaoSemanal> createState() => _VisaoSemanalState();
}

class _VisaoSemanalState extends State<VisaoSemanal> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30), ),
                  color:(isTemaDark)?Colors.white10 : Colors.blueAccent),
              width: largura * 0.4,
              child: TextButton(
                child: const Icon(Icons.arrow_left, color: Colors.white, size: 35),
                onPressed: () {
                  setState(() {
                    semanas += 7;
                  });
                }),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color:(isTemaDark)?Colors.white10 : Colors.blueAccent),
              width: largura * 0.4,
              child: TextButton(
                child: const Icon(Icons.arrow_right, color: Colors.white, size: 35),
                onPressed: () {
                  setState(() {
                    semanas -= 7;
                  });
                }),
            )
          ],
        ),
        Container(
          padding: const EdgeInsets.only(top:5),
          child: semanaWrap(context, pGrupo: widget.grupo))
      ],
    );
  }
}
