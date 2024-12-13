import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Based on liars bar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlayerInputScreen(),
    );
  }
}

class PlayerInputScreen extends StatefulWidget {
  @override
  _PlayerInputScreenState createState() => _PlayerInputScreenState();
}

class _PlayerInputScreenState extends State<PlayerInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = [];
  int _playerCount = 2;

  void _addPlayerFields() {
    setState(() {
      _controllers.clear();
      for (int i = 0; i < _playerCount; i++) {
        _controllers.add(TextEditingController());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _addPlayerFields();
  }

  void _incrementPlayerCount() {
    if (_playerCount < 4) {
      setState(() {
        _playerCount++;
        _controllers.add(TextEditingController());
      });
    }
  }

  void _decrementPlayerCount() {
    if (_playerCount > 2) {
      setState(() {
        _playerCount--;
        _controllers.removeLast();
      });
    }
  }

  void _showRandomCard() {
    final List<String> cards = ['7s', '8s', '9s'];
    final String selectedCard = (cards..shuffle()).first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Carta da Mesa:'),
          content: Text(
            selectedCard,
            style: const TextStyle(fontSize: 25),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Row(
          children: [
            const Text('Tela de jogadores'),
            ButtonBar(
              children: [
                IconButton(
                  icon: const Icon(Icons.casino),
                  onPressed: _showRandomCard,
                ),
              ],
            )
          ],
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: _decrementPlayerCount,
                  ),
                  Text('Jogadores: $_playerCount',
                      style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: _incrementPlayerCount,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _playerCount,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          labelText: 'Jogador ${index + 1}',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'bote um nome';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    List<String> playerNames = _controllers
                        .map((controller) => controller.text)
                        .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameScreen(playerNames: playerNames),
                      ),
                    );
                  }
                },
                child: const Text('Começar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final List<String> playerNames;

  GameScreen({required this.playerNames});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<int> playerCounters;
  late List<bool> playerActive;

  @override
  void initState() {
    super.initState();
    playerCounters = List<int>.filled(widget.playerNames.length, 0);
    playerActive = List<bool>.filled(widget.playerNames.length, true);
  }

  void _playRussianRoulette(BuildContext context, int index) {
    setState(() {
      playerCounters[index]++;
    });
    int counter = playerCounters[index];
    bool isSafe = (DateTime.now().millisecondsSinceEpoch % 6) >= counter;
    if (!isSafe) {
      setState(() {
        playerActive[index] = false;
      });
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.playerNames[index]),
          content: Text(isSafe ? 'Tá salvo por enquanto!' : 'Bang! Ta morto!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de jogo'),
      ),
      body: ListView.builder(
        itemCount: widget.playerNames.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                '${widget.playerNames[index]} (${playerCounters[index]}/6)',
                style: TextStyle(
                  decoration: playerActive[index]
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              leading: CircleAvatar(
                child: Icon(
                  playerActive[index] ? Icons.person : Icons.person_off,
                  color: playerActive[index] ? Colors.green : Colors.red,
                ),
              ),
              trailing: Icon(
                Icons.play_arrow,
                color: playerActive[index] ? Colors.blue : Colors.grey,
              ),
              onTap: playerActive[index]
                  ? () {
                      _playRussianRoulette(context, index);
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
