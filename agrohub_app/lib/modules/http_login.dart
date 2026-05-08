import 'dart:convert';
import 'package:agrohub_app/constants.dart';
import 'package:http/http.dart' as http;

class LoginResult {
  final int status;
  final String message;
  final String? token;

  LoginResult({
    required this.status,
    required this.message,
    this.token,
  });
}

Future<LoginResult> loginRequest(String login, String password) async {
  try {
    final url = Uri.parse('$api/auth');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"login": login, "senha": password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody = jsonDecode(response.body);
      return LoginResult(
        status: response.statusCode,
        message: 'Autenticação realizada!',
        token: responseBody['token'],
      );
    } else if (response.statusCode == 401) {
      return LoginResult(
        status: response.statusCode,
        message: 'Login incorreto!',
      );
    } else {
      return LoginResult(
        status: response.statusCode,
        message: 'Falha na requisição, resposta: ${response.body}',
      );
    }
  } catch (e) {
    return LoginResult(
      status: 500,
      message: 'Não foi possível conectar ao servidor, Erro: $e',
    );
  }
}