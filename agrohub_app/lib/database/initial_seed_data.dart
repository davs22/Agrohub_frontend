import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class InitialSeedData {
  static const String fazendaDocumento = '11222333000181';
  static const String comercioDocumento = '22333444000181';
  static const String adminPassword = 'Agro2026';
  static const String operationPassword = 'Campo2026';

  static const String _fallbackPngBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

  static Future<void> seed(Database db) async {
    final fazendasCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM fazendas'),
        ) ??
        0;
    final comerciosCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM comercios'),
        ) ??
        0;

    if (fazendasCount > 0 || comerciosCount > 0) {
      return;
    }

    await db.transaction((txn) async {
      final now = DateTime.now();
      final fazendaId = await txn.insert(
          'fazendas',
          _withDates(now, {
            'nome': 'Fazenda AgroHub Demonstracao',
            'documento': fazendaDocumento,
            'hectares': 1840.5,
            'latitude': '-15.7801',
            'longitude': '-47.9292',
            'telefone': '61998887766',
            'email': 'fazenda.demo@agrohub.local',
            'senha_adm': adminPassword,
            'senha_operacao': operationPassword,
            'status': 'ATIVO',
          }));

      await txn.insert(
          'comercios',
          _withDates(now, {
            'nome': 'Comercio AgroHub Demonstracao',
            'documento': comercioDocumento,
            'cep': '72800000',
            'rua': 'Avenida Central do Agronegocio, 1200',
            'telefone': '61997776655',
            'email': 'comercio.demo@agrohub.local',
            'senha_adm': adminPassword,
            'senha_operacao': operationPassword,
            'status': 'ATIVO',
          }));

      final operadorIds = <int>[];
      for (var index = 0; index < _operadores.length; index++) {
        final operador = _operadores[index];
        final id = await txn.insert(
            'operadores',
            _withDates(
              now.subtract(Duration(days: 70 - index)),
              {
                'documento_admin': fazendaDocumento,
                'nome_completo': operador.nome,
                'cpf': operador.cpf,
                'email': operador.email,
                'telefone': operador.telefone,
                'senha': 'Operador${(index + 1).toString().padLeft(2, '0')}',
                'status': index % 9 == 0 ? 'INATIVO' : 'ATIVO',
              },
            ));
        operadorIds.add(id);
      }

      final talhaoIds = <int>[];
      for (var index = 0; index < _talhoes.length; index++) {
        final talhao = _talhoes[index];
        final operadorId = operadorIds[index % operadorIds.length];
        final id = await txn.insert(
            'talhoes',
            _withDates(
              now.subtract(Duration(days: 54 - index)),
              {
                'talhao_id_nuvem':
                    'TLH-DEMO-${(index + 1).toString().padLeft(3, '0')}',
                'usuario_id': operadorId.toString(),
                'nome': talhao.nome,
                'tamanho_hectares': talhao.hectares,
                'cultura_atual': talhao.cultura,
                'status': index % 8 == 0 ? 'INATIVO' : 'ATIVO',
              },
            ));
        talhaoIds.add(id);
      }

      final loteRows = <Map<String, dynamic>>[];
      for (var index = 0; index < _produtos.length; index++) {
        final produto = _produtos[index];
        final operadorId = operadorIds[index % operadorIds.length];
        final talhaoId = talhaoIds[index % talhaoIds.length];
        final imageBase64 = await _assetBase64(produto.assetPath);
        final loteId = await txn.insert(
            'lotes',
            _withDates(
              now.subtract(Duration(days: 35 - index)),
              {
                'lote_id_nuvem':
                    'LOT-DEMO-${(index + 1).toString().padLeft(3, '0')}',
                'instancia_id': fazendaId.toString(),
                'usuario_id': operadorId.toString(),
                'talhao_id': talhaoId.toString(),
                'operador_id': operadorId.toString(),
                'codigo_rastreio':
                    'AGH-${DateTime.now().year}-${(index + 1).toString().padLeft(4, '0')}',
                'produto': produto.nome,
                'quantidade': produto.quantidade,
                'unidade_medida': produto.unidade,
                'status': index % 11 == 0 ? 'RESERVADO' : 'ATIVO',
                'imagem_base64': imageBase64,
                'imagem_nome_arquivo': produto.assetPath.split('/').last,
                'is_published': 1,
              },
            ));
        loteRows.add({
          'id_local': loteId,
          'instancia_id': fazendaId.toString(),
          'talhao_id': talhaoId.toString(),
          'operador_id': operadorId.toString(),
          'codigo_rastreio':
              'AGH-${DateTime.now().year}-${(index + 1).toString().padLeft(4, '0')}',
          'produto': produto.nome,
          'quantidade': produto.quantidade,
          'unidade_medida': produto.unidade,
          'imagem_base64': imageBase64,
          'imagem_nome_arquivo': produto.assetPath.split('/').last,
          'talhao_nome': _talhoes[index % _talhoes.length].nome,
          'operador_nome': _operadores[index % _operadores.length].nome,
        });
      }

      for (var index = 0; index < loteRows.length; index++) {
        final lote = loteRows[index];
        final compradorId =
            operadorIds[(index + 3) % operadorIds.length].toString();
        await txn.insert(
            'carrinho_itens',
            _withDates(
              now.subtract(Duration(days: 20 - index)),
              {
                'operador_id': compradorId,
                'lote_id': lote['id_local'].toString(),
                'instancia_id': lote['instancia_id'],
                'talhao_id': lote['talhao_id'],
                'operador_lote_id': lote['operador_id'],
                'codigo_rastreio': lote['codigo_rastreio'],
                'produto': lote['produto'],
                'quantidade': lote['quantidade'],
                'unidade_medida': lote['unidade_medida'],
                'imagem_base64': lote['imagem_base64'],
                'imagem_nome_arquivo': lote['imagem_nome_arquivo'],
                'talhao_nome': lote['talhao_nome'],
                'operador_nome': lote['operador_nome'],
                'status': 'ATIVO',
              },
            ));
      }
    });
  }

  static Map<String, dynamic> _withDates(
    DateTime date,
    Map<String, dynamic> values,
  ) {
    final isoDate = date.toIso8601String();
    return {
      ...values,
      'data_registro': isoDate,
      'data_atualizacao': isoDate,
      'status_sincronizacao': 1,
    };
  }

  static Future<String> _assetBase64(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return base64Encode(data.buffer.asUint8List());
    } catch (_) {
      return _fallbackPngBase64;
    }
  }

  static const List<_OperadorSeed> _operadores = [
    _OperadorSeed('Ana Paula Ribeiro', '12345000198',
        'ana.ribeiro@agrohub.local', '61990010001'),
    _OperadorSeed('Bruno Carvalho Mendes', '12345000279',
        'bruno.mendes@agrohub.local', '61990010002'),
    _OperadorSeed('Camila Torres Almeida', '12345000350',
        'camila.almeida@agrohub.local', '61990010003'),
    _OperadorSeed('Diego Martins Rocha', '12345000430',
        'diego.rocha@agrohub.local', '61990010004'),
    _OperadorSeed('Elisa Nunes Prado', '12345000511',
        'elisa.prado@agrohub.local', '61990010005'),
    _OperadorSeed('Felipe Augusto Lima', '12345000600',
        'felipe.lima@agrohub.local', '61990010006'),
    _OperadorSeed('Gabriela Pires Costa', '12345000783',
        'gabriela.costa@agrohub.local', '61990010007'),
    _OperadorSeed('Henrique Souza Barros', '12345000864',
        'henrique.barros@agrohub.local', '61990010008'),
    _OperadorSeed('Isabela Freitas Gomes', '12345000945',
        'isabela.gomes@agrohub.local', '61990010009'),
    _OperadorSeed('Joao Pedro Siqueira', '12345001089',
        'joao.siqueira@agrohub.local', '61990010010'),
    _OperadorSeed('Karen Lopes Batista', '12345001160',
        'karen.batista@agrohub.local', '61990010011'),
    _OperadorSeed('Lucas Araujo Teixeira', '12345001240',
        'lucas.teixeira@agrohub.local', '61990010012'),
    _OperadorSeed('Marina Castro Vieira', '12345001321',
        'marina.vieira@agrohub.local', '61990010013'),
    _OperadorSeed('Nelson Ferreira Dias', '12345001402',
        'nelson.dias@agrohub.local', '61990010014'),
    _OperadorSeed('Olivia Moreira Campos', '12345001593',
        'olivia.campos@agrohub.local', '61990010015'),
    _OperadorSeed('Paulo Henrique Matos', '12345001674',
        'paulo.matos@agrohub.local', '61990010016'),
    _OperadorSeed('Renata Barbosa Leal', '12345001755',
        'renata.leal@agrohub.local', '61990010017'),
    _OperadorSeed('Samuel Correia Reis', '12345001836',
        'samuel.reis@agrohub.local', '61990010018'),
    _OperadorSeed('Tatiane Monteiro Farias', '12345001917',
        'tatiane.farias@agrohub.local', '61990010019'),
    _OperadorSeed('Victor Hugo Santana', '12345002050',
        'victor.santana@agrohub.local', '61990010020'),
  ];

  static const List<_TalhaoSeed> _talhoes = [
    _TalhaoSeed('Talhao Primavera Norte', 82.4, 'Soja'),
    _TalhaoSeed('Talhao Buriti Central', 64.8, 'Milho'),
    _TalhaoSeed('Talhao Vereda Alta', 51.2, 'Cafe'),
    _TalhaoSeed('Talhao Santa Luzia', 73.5, 'Arroz'),
    _TalhaoSeed('Talhao Lagoa Seca', 45.0, 'Trigo'),
    _TalhaoSeed('Talhao Horizonte', 38.7, 'Tomate'),
    _TalhaoSeed('Talhao Ipe Amarelo', 29.4, 'Batata'),
    _TalhaoSeed('Talhao Boa Esperanca', 34.9, 'Cebola'),
    _TalhaoSeed('Talhao Rio Claro', 22.3, 'Cenoura'),
    _TalhaoSeed('Talhao Vale Verde', 18.6, 'Alface'),
    _TalhaoSeed('Talhao Serra Dourada', 41.5, 'Laranja'),
    _TalhaoSeed('Talhao Mata Fria', 27.8, 'Banana'),
    _TalhaoSeed('Talhao Pedra Azul', 24.6, 'Uva'),
    _TalhaoSeed('Talhao Estrela Sul', 16.8, 'Morango'),
    _TalhaoSeed('Talhao Campo Novo', 58.1, 'Feijao'),
    _TalhaoSeed('Talhao Riacho Fundo', 46.9, 'Mandioca'),
    _TalhaoSeed('Talhao Santo Antonio', 91.0, 'Cana-de-acucar'),
    _TalhaoSeed('Talhao Chapada', 66.2, 'Algodao'),
    _TalhaoSeed('Talhao Agua Limpa', 37.4, 'Amendoim'),
    _TalhaoSeed('Talhao Sol Poente', 19.9, 'Pimentao'),
    _TalhaoSeed('Talhao Cerrado Leste', 53.7, 'Sorgo'),
    _TalhaoSeed('Talhao Campo Alegre', 31.5, 'Abobora'),
    _TalhaoSeed('Talhao Capao Redondo', 28.2, 'Melancia'),
    _TalhaoSeed('Talhao Vista Bela', 44.3, 'Gergelim'),
  ];

  static const List<_ProdutoSeed> _produtos = [
    _ProdutoSeed('Soja em graos - safra 2026', 1200, 'sacas',
        'assets/seed_products/01_soybean.jpg'),
    _ProdutoSeed('Milho amarelo selecionado', 980, 'sacas',
        'assets/seed_products/02_corn.jpg'),
    _ProdutoSeed('Cafe arabica beneficiado', 320, 'sacas',
        'assets/seed_products/03_coffee.jpg'),
    _ProdutoSeed('Arroz irrigado tipo 1', 740, 'sacas',
        'assets/seed_products/04_rice.jpg'),
    _ProdutoSeed(
        'Trigo grao limpo', 610, 'sacas', 'assets/seed_products/05_wheat.jpg'),
    _ProdutoSeed('Tomate longa vida', 430, 'caixas',
        'assets/seed_products/06_tomato.jpg'),
    _ProdutoSeed('Batata lavada especial', 560, 'sacos',
        'assets/seed_products/07_potato.jpg'),
    _ProdutoSeed('Cebola branca classificada', 390, 'sacos',
        'assets/seed_products/08_onion.jpg'),
    _ProdutoSeed('Cenoura extra AA', 280, 'caixas',
        'assets/seed_products/09_carrot.jpg'),
    _ProdutoSeed('Alface crespa hidroponica', 850, 'unidades',
        'assets/seed_products/10_lettuce.jpg'),
    _ProdutoSeed('Laranja pera madura', 700, 'caixas',
        'assets/seed_products/11_orange.jpg'),
    _ProdutoSeed('Banana prata climatizada', 640, 'caixas',
        'assets/seed_products/12_banana.jpg'),
    _ProdutoSeed('Uva niagara de mesa', 210, 'caixas',
        'assets/seed_products/13_grapes.jpg'),
    _ProdutoSeed('Morango bandeja premium', 520, 'bandejas',
        'assets/seed_products/14_strawberry.jpg'),
    _ProdutoSeed('Feijao carioca tipo 1', 480, 'sacas',
        'assets/seed_products/15_beans.jpg'),
    _ProdutoSeed('Mandioca de mesa', 360, 'caixas',
        'assets/seed_products/16_cassava.jpg'),
    _ProdutoSeed('Cana-de-acucar para moagem', 1500, 'toneladas',
        'assets/seed_products/17_sugarcane.jpg'),
    _ProdutoSeed('Algodao em pluma', 260, 'fardos',
        'assets/seed_products/18_cotton.jpg'),
    _ProdutoSeed('Amendoim graudo descascado', 300, 'sacas',
        'assets/seed_products/19_peanut.jpg'),
    _ProdutoSeed('Pimentao verde selecionado', 240, 'caixas',
        'assets/seed_products/20_pepper.jpg'),
  ];
}

class _OperadorSeed {
  final String nome;
  final String cpf;
  final String email;
  final String telefone;

  const _OperadorSeed(this.nome, this.cpf, this.email, this.telefone);
}

class _TalhaoSeed {
  final String nome;
  final double hectares;
  final String cultura;

  const _TalhaoSeed(this.nome, this.hectares, this.cultura);
}

class _ProdutoSeed {
  final String nome;
  final int quantidade;
  final String unidade;
  final String assetPath;

  const _ProdutoSeed(this.nome, this.quantidade, this.unidade, this.assetPath);
}
