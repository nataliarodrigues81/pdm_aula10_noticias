
import 'package:flutter/material.dart';

import '../models/noticia_model.dart';
import '../services/noticia_service.dart';
import 'detalhe_noticia_screen.dart';

class FeedNoticiasScreen extends StatefulWidget {
  const FeedNoticiasScreen({super.key});

  @override
  State<FeedNoticiasScreen> createState() =>
      _FeedNoticiasScreenState();
}

class _FeedNoticiasScreenState extends State<FeedNoticiasScreen> {
  final NoticiaService _service = NoticiaService();
  final TextEditingController _buscaController =
      TextEditingController();

  List<NoticiaModel> _noticias = [];
  bool _carregando = true;
  bool _simularErro = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarFeed();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarFeed() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _service.buscarNoticias(
        simularErro: _simularErro,
      );

      if (!mounted) return;

      setState(() {
        _noticias = lista;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  List<NoticiaModel> get _noticiasFiltradas {
    final busca = _buscaController.text.trim().toLowerCase();

    if (busca.isEmpty) {
      return _noticias;
    }

    return _noticias.where((noticia) {
      return noticia.titulo.toLowerCase().contains(busca);
    }).toList();
  }

  void _alternarSimulacaoErro() {
    setState(() {
      _simularErro = !_simularErro;
    });

    _carregarFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Notícias'),
        actions: [
          IconButton(
            tooltip: 'Recarregar notícias',
            onPressed: _carregando ? null : _carregarFeed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _buscaController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Buscar por título',
                hintText: 'Digite o título da notícia',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Limpar busca',
                  onPressed: () {
                    _buscaController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _carregando
                    ? null
                    : _alternarSimulacaoErro,
                icon: Icon(
                  _simularErro
                      ? Icons.wifi
                      : Icons.wifi_off,
                ),
                label: Text(
                  _simularErro
                      ? 'Desativar erro simulado'
                      : 'Testar erro de conexão',
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildConteudo(),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erro != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.red,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar as notícias.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _erro!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregarFeed,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_noticias.isEmpty) {
      return const Center(
        child: Text('Nenhuma notícia encontrada.'),
      );
    }

    final noticias = _noticiasFiltradas;

    if (noticias.isEmpty) {
      return const Center(
        child: Text('Nenhuma notícia corresponde à busca.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: noticias.length,
      itemBuilder: (context, index) {
        final noticia = noticias[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              child: Text(noticia.id.toString()),
            ),
            title: Text(
              noticia.titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                noticia.resumo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return DetalheNoticiaScreen(
                      noticia: noticia,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
