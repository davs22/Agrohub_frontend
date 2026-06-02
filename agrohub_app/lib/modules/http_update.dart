import 'dart:convert';
import 'package:agrohub_app/constants.dart';
import 'package:http/http.dart' as http;

Future<DefaultResult> updateRequest(String usuarioId, Map<String, dynamic> userData, {String? token}) async {
  try {
    final url = Uri.parse('$api/user/update/$usuarioId');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(userData),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DefaultResult(
        status: response.statusCode,
        message: 'Atualização realizada com sucesso!',
        data: jsonDecode(response.body),
      );
    } else {
      return DefaultResult(
        status: response.statusCode,
        message: 'Falha ao atualizar, resposta: ${response.body}',
      );
    }
  } catch (e) {
    return DefaultResult(
      status: 500,
      message: 'Não foi possível conectar ao servidor. Erro: $e',
    );
  }
}