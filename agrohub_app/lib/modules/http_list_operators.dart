import 'dart:convert';
import 'package:agrohub_app/constants.dart';
import 'package:http/http.dart' as http;

Future<DefaultResult> listOperatorsRequest({String? token}) async {
  try {
    final url = Uri.parse('$api/user/list-all-operators');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DefaultResult(
        status: response.statusCode,
        message: 'Operadores listados com sucesso!',
        data: jsonDecode(response.body),
      );
    } else {
      return DefaultResult(
        status: response.statusCode,
        message: 'Falha ao listar operadores, resposta: ${response.body}',
      );
    }
  } catch (e) {
    return DefaultResult(
      status: 500,
      message: 'Não foi possível conectar ao servidor. Erro: $e',
    );
  }
}