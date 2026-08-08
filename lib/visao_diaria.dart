import 'package:flutter/material.dart';
import 'package:tabela_de_turno/dados.dart';
import 'rotinas.dart';
import 'local_storage_service.dart';
import 'models/integrante.dart';

class VisaoDiaria extends StatefulWidget {
  const VisaoDiaria({super.key});

  @override
  State<VisaoDiaria> createState() => _VisaoDiariaState();
}

class _VisaoDiariaState extends State<VisaoDiaria> {
  DateTime dataH = DateTime.now();
  double larguraInterna = 0.9;
  double tmBt = 1/numeroDeGrupos-0.01;
  String _grupoSendoVisualizado = 'a';

  @override
  void initState() {
    super.initState();
    // Inicializa o grupo visualizado com o favorito salvo
    grupo.forEach((key, value) {
      if (value == grupoAtual) _grupoSendoVisualizado = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_left, size: 40, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      dataAtual = dataAtual.subtract(const Duration(days: 1));
                      atualiza();
                    });
                  }),
              Container(
                height: 60,
                alignment: Alignment.center,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: TextButton(
                    onPressed: () => showDatePicker(
                        context: context,
                        initialDate: dataAtual,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(3000)
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          dataAtual = value;
                          atualiza();
                        });
                      }
                    }),
                    child: Text(
                      "${diaSemanaComp[dataAtual.weekday - 1]} - "
                      "${dataAtual.day}/${dataAtual.month}/${dataAtual.year}",
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    )),
              ),
              IconButton(
                  icon: const Icon(Icons.arrow_right, size: 40, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      dataAtual = dataAtual.add(const Duration(days: 1));
                      atualiza();
                    });
                  })
            ],
          ),
          Center(
            child: Card(
              shadowColor: Colors.grey,
              elevation: 7,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              margin: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                width: largura * larguraInterna,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: largura * larguraInterna,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGrupoHeader("a", 0),
                            _buildGrupoHeader("b", 1),
                            if (numeroDeGrupos >= 3) _buildGrupoHeader("c", 2),
                            if (numeroDeGrupos >= 4) _buildGrupoHeader("d", 3),
                            if (numeroDeGrupos >= 5) _buildGrupoHeader("e", 4),
                            if (numeroDeGrupos == 6) _buildGrupoHeader("f", 5),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.blue, thickness: 3),
                      SizedBox(
                        width: largura * larguraInterna,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHorarioRow(gA, "a"),
                            _buildHorarioRow(gB, "b"),
                            if (numeroDeGrupos >= 3) _buildHorarioRow(gC, "c"),
                            if (numeroDeGrupos >= 4) _buildHorarioRow(gD, "d"),
                            if (numeroDeGrupos >= 5) _buildHorarioRow(gE, "e"),
                            if (numeroDeGrupos == 6) _buildHorarioRow(gF, "f"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildIntegrantesList(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
          onPressed: () {
            String turno = getTurnoPorGrupo(dataAtual, _grupoSendoVisualizado);
            mostrarMenuEventos(context, dataAtual, turno);
          },
          icon: const Icon(Icons.add_task),
          label: const Text("Ações para este dia"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIntegrantesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: LocalStorageService().loadIntegrantes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final list = snapshot.data!
            .map((e) => Integrante.fromMap(e))
            .where((i) => i.grupo == _grupoSendoVisualizado)
            .toList();

        if (list.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Integrantes do Grupo ${_grupoSendoVisualizado.toUpperCase()}:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 5),
              ...list.map((i) => Card(
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: const Icon(Icons.person, size: 20),
                  title: Text(i.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(i.cargo),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrupoHeader(String letra, int index) {
    bool isFavorito = (grupoAtual == grupo[letra]);
    bool isVisualizado = (_grupoSendoVisualizado == letra);

    return InkWell(
      onTap: () {
        setState(() {
          _grupoSendoVisualizado = letra;
        });
      },
      onLongPress: () {
        setState(() {
          grupoAtual = grupo[letra]!;
          _grupoSendoVisualizado = letra;
          preferencias[0]["turnoFavorito"] = grupoAtual;
          salvaArquivo();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Grupo ${letra.toUpperCase()} definido como favorito!"),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      },
      child: Container(
        width: largura * larguraInterna * tmBt,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isVisualizado ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isVisualizado ? Border.all(color: Colors.blue.withValues(alpha: 0.3)) : null,
        ),
        child: Column(
          children: [
            Icon(
              isFavorito ? Icons.star : Icons.star_border,
              size: 14,
              color: isFavorito ? Colors.orange : Colors.transparent,
            ),
            Text(grupos[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isVisualizado ? Colors.blue : corTxBtTurnoC,
                  fontSize: 20,
                  fontWeight: isVisualizado ? FontWeight.bold : FontWeight.normal,
                  decoration: isVisualizado ? TextDecoration.underline : TextDecoration.none,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioRow(String label, String letra) {
    bool isVisualizado = (_grupoSendoVisualizado == letra);
    return SizedBox(
      width: largura * larguraInterna * tmBt,
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: coresHorarios[label],
              fontSize: 20,
              fontWeight: isVisualizado ? FontWeight.bold : FontWeight.normal)),
    );
  }

  void atualiza() {
    anoAtual = dataAtual.year;
    mesAtual = dataAtual.month;
    diaAtual = dataAtual.day;
    gA = tabela[indiceDtGr(dataAtual, 'a')];
    gB = tabela[indiceDtGr(dataAtual, 'b')];
    gC = tabela[indiceDtGr(dataAtual, 'c')];
    gD = tabela[indiceDtGr(dataAtual, 'd')];
    gE = tabela[indiceDtGr(dataAtual, 'e')];
    gF = tabela[indiceDtGr(dataAtual, 'f')];
  }
}
