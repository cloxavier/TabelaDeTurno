import 'package:flutter/material.dart';
import 'package:tabela_de_turno/temas.dart';
import 'dados.dart';
import 'rotinas.dart';
import 'screens/notificacoes_config_screen.dart';

class Interface extends StatefulWidget {
  const Interface({super.key});

  @override
  State<Interface> createState() => _InterfaceState();
}

class _InterfaceState extends State<Interface> {

  Widget _styleOption(int value, String label) {
    bool isSelected = estiloCard == value;
    return InkWell(
      onTap: () {
        setState(() {
          estiloCard = value;
          // Sincroniza o estado global e notifica ouvintes (Tabela principal)
          // para redesenho imediato do layout.
          if (estiloCard == 0) {
            barraVisivel = false; 
            diaMesVisivel = true;
            horarioCentro = false;
            barraComTabelaVisivel = true;
          }
          preferencias[0]["estiloCard"] = estiloCard;
          preferencias[0]["interface"] = barraVisivel;
          salvaArquivo();
          
          AppController.instance.updateCardStyle(value);
        });
      },
      child: Column(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? Colors.deepOrange : Colors.grey,
          ),
          Text(label, style: TextStyle(
            color: isSelected ? Colors.deepOrange : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Cria lista de booleando para toggleButton
    List<bool> selPagInicial = List.generate(5, (_) => false);
    //Defini qual botão vai esta ativo em função da pagina inicial
    selPagInicial[paginaInicial] =true;

    //Capturam a largura e altura da tela do dispositivo
    altura = MediaQuery.of(context).size.height;
    largura = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Interface"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Titulo Interior do Botão
            Container(
              padding: const EdgeInsets.only(left: 10,top: 20),
              alignment: Alignment.centerLeft,
              child: Text("Interior do Botão",
                style:(isTemaDark)? Theme.of(context).textTheme.titleLarge : const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),

            //Interface: Estilo do Card
            Container(
              width: largura*0.85,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey)
              ),
              margin: const EdgeInsets.only(top: 10,bottom: 10),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  const Text("Selecione o layout dos dias:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _styleOption(0, "CLÁSSICO"),
                      _styleOption(1, "MODERNO"),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),
                  Visibility(
                    visible: estiloCard == 0,
                    child: Column(
                      children: [
                        const Text("Preferências de Efeito:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Row(
                          children: [
                            Checkbox(
                              value: flat,
                              onChanged: (value) {
                                setState(() {
                                  flat = !flat;
                                  preferencias[0]["botaoFlat"] = flat;
                                  salvaArquivo();
                                  // Notifica ouvintes para atualizar sombras e relevos via método seguro
                                  AppController.instance.updateUI();
                                });
                              },
                            ),
                            const Text("Sem relevo (Sombra)")
                          ],
                        ),
                        const Divider(thickness: 1,),
                      ],
                    ),
                  ),
                  const Text("Prévia do visual selecionado:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  cardDia(1, dataHoje.day.toString(), diaSemana[dataHoje.weekday-1], Colors.amber ,full: true),
                ],
              ),
            ),

            //Titulo Display
            Container(
              margin: const EdgeInsets.only(left: 10,top: 20),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text("Telas",
                style:(isTemaDark)? Theme.of(context).textTheme.titleLarge : const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),

            //Corpo display
            Container(
              width: largura*0.85,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey)
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isTemaDark,
                        onChanged: ( value) {
                          setState(() {
                            isTemaDark = !isTemaDark;
                            preferencias[0]["temaEscuro"] = isTemaDark;
                            salvaArquivo();
                            AppController.instance.changeTheme(escuro: isTemaDark);
                          });
                        },
                      ),
                      const Text("Tema Escuro")
                    ],
                  ),
                  const Divider(thickness: 2,),
                  Container(
                    margin: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: const Text("Selecione a página inicial."),),

                  //Botões de seleção da pagina inicial
                  ToggleButtons(
                    isSelected:selPagInicial,
                    onPressed: (indice){
                      setState(() {
                        paginaInicial=indice;
                        for(int i=0; i<5;i++ ) {
                          if(i==indice) {
                            selPagInicial[i] =true;
                          } else {
                            selPagInicial[i] =false;
                          }
                        }
                      });
                      preferencias[0]["pgInicial"]=indice;
                      salvaArquivo();
                    },
                    //Controle das cores dos Toggles
                    color: Colors.green,
                    selectedColor: Colors.blue,
                    borderColor:Colors.blue ,
                    selectedBorderColor: Colors.orange,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                    children: const [
                      Text("D"),
                      Text("S"),
                      Text("M"),
                      Text("A"),
                      Text("G"),
                    ],
                    //
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: const Text("D= Dia, S= Semana, M= Mês, A= Ano, G= Geral"),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("Interface e Tema"),
            subtitle: const Text("Personalize as cores e o estilo dos botões."),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Interface())
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text("Notificações e Pontualidade"),
            subtitle: const Text("Garanta que seus alarmes toquem no horário."),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificacoesConfigScreen())
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Em breve: Mais opções de personalização e notificações.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
