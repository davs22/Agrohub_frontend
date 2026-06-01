import 'dart:convert';
import 'package:agrohub_app/constants.dart';
import 'package:http/http.dart' as http;

Future<DefaultResult> registerRequest(Map<String, dynamic> userData) async {
  try {
    final url = Uri.parse('$api/user/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DefaultResult(
        status: response.statusCode,
        message: 'Cadastro realizado com sucesso!',
        data: jsonDecode(response.body),
      );
    } else {
      return DefaultResult(
        status: response.statusCode,
        message: 'Falha ao cadastrar, resposta: ${response.body}',
      );
    }
  } catch (e) {
    return DefaultResult(
      status: 500,
      message: 'Não foi possível conectar ao servidor. Erro: $e',
    );
  }
}