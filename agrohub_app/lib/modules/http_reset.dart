import 'dart:convert';
import 'package:agrohub_app/constants.dart';
import 'package:http/http.dart' as http;

Future<DefaultResult> sendResetCodeRequest(String login) async {
  try {
    final url = Uri.parse('$api/auth/send-code/$login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DefaultResult(
        status: response.statusCode,
        message: 'Código enviado com sucesso!',
      );
    } else {
      return DefaultResult(
        status: response.statusCode,
        message: 'Falha ao enviar código, resposta: ${response.body}',
      );
    }
  } catch (e) {
    return DefaultResult(
      status: 500,
      message: 'Não foi possível conectar ao servidor. Erro: $e',
    );
  }
}

Future<DefaultResult> resetPasswordRequest(String login, String code, String novaSenha) async {
  try {
    final url = Uri.parse('$api/auth/reset-password/$login?code=$code');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"senha": novaSenha}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DefaultResult(
        status: response.statusCode,
        message: 'Senha redefinida com sucesso!',
      );
    } else {
      return DefaultResult(
        status: response.statusCode,
        message: 'Falha ao redefinir senha, resposta: ${response.body}',
      );
    }
  } catch (e) {
    return DefaultResult(
      status: 500,
      message: 'Não foi possível conectar ao servidor. Erro: $e',
    );
  }
}