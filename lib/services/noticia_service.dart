
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/noticia_model.dart';

class NoticiaService {
  static const String _endpoint =
      'https://jsonplaceholder.typicode.com/posts';

  Future<List<NoticiaModel>> buscarNoticias({
    bool simularErro = false,
  }) async {
    try {
      final String url = simularErro
          ? 'https://url-invalida-exemplo-12345.com/posts'
          : _endpoint;

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> listaJson =
            jsonDecode(response.body) as List<dynamic>;

        return listaJson.map((json) {
          return NoticiaModel.fromJson(
            json as Map<String, dynamic>,
          );
        }).toList();
      } else {
        throw Exception(
          'Status HTTP de erro: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Falha ao conectar com a API: $e',
      );
    }
  }
}
