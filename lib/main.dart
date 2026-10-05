import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Compras',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FA),
      ),
      home: const TelaLista(),
    );
  }
}

// ============================================================
// MODELO ITEM
// ============================================================

class Item {
  String nome;
  int quantidade;
  bool comprado;

  Item({
    required this.nome,
    required this.quantidade,
    this.comprado = false,
  });
}

// ============================================================
// TELA PRINCIPAL
// ============================================================

class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  final List<Item> itens = [];

  Future<void> abrirTelaAdicionar() async {
    final item = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => const TelaAdicionarItem(),
      ),
    );

    if (item != null) {
      setState(() {
        itens.add(item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.nome} adicionado à lista'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void removerItem(int indice) {
    final item = itens[indice];

    setState(() {
      itens.removeAt(indice);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nome} removido da lista'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void alterarCompra(int indice, bool valor) {
    setState(() {
      itens[indice].comprado = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final comprados = itens.where((item) => item.comprado).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Minha Lista',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              bottom: 12,
            ),
            child: Text(
              '$comprados de ${itens.length} comprados',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),

      body: itens.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 70,
                      color: Color(0xFF6750A4),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sua lista está vazia',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toque no botão + para adicionar\num item à sua lista.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              itemCount: itens.length,
              itemBuilder: (context, indice) {
                final item = itens[indice];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    leading: Checkbox(
                      value: item.comprado,
                      activeColor: const Color(0xFF6750A4),
                      onChanged: (valor) {
                        if (valor != null) {
                          alterarCompra(indice, valor);
                        }
                      },
                    ),

                    title: Text(
                      item.nome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: item.comprado
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.comprado
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),

                    subtitle: Text(
                      '${item.quantidade} ${item.quantidade == 1 ? 'unidade' : 'unidades'}',
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Remover',
                      onPressed: () {
                        removerItem(indice);
                      },
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: abrirTelaAdicionar,
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================
// TELA DE ADICIONAR ITEM
// ============================================================

class TelaAdicionarItem extends StatefulWidget {
  const TelaAdicionarItem({super.key});

  @override
  State<TelaAdicionarItem> createState() => _TelaAdicionarItemState();
}

class _TelaAdicionarItemState extends State<TelaAdicionarItem> {
  final nomeController = TextEditingController();
  final quantidadeController = TextEditingController();

  void salvar() {
    final nome = nomeController.text.trim();
    final quantidadeTexto = quantidadeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do item'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final quantidade = int.tryParse(quantidadeTexto);

    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma quantidade válida'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final item = Item(
      nome: nome,
      quantidade: quantidade,
    );

    Navigator.pop(context, item);
  }

  @override
  void dispose() {
    nomeController.dispose();
    quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Adicionar item',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Novo item',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Informe o produto e a quantidade.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Nome do produto',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nomeController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ex.: Arroz',
                prefixIcon: const Icon(
                  Icons.shopping_bag_outlined,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Quantidade',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: quantidadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex.: 2',
                prefixIcon: const Icon(
                  Icons.numbers,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salvar item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
