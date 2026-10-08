# AgroHub

Aplicativo Flutter para a gestão interna de fazendas e comércios agrícolas. O catálogo é uma visão do estoque: exibe produtos, quantidades e preços cadastrados, sem fluxo de compra.

## Funcionalidades

- Painéis de administração e operação com navegação separada por perfil.
- Cadastro e consulta de operadores, talhões e lotes com pesquisa, filtros e grade responsiva de até quatro colunas.
- Preço unitário e validade opcional nos lotes.
- Registro de receitas e despesas, com resultado, margem e valor estimado do estoque.
- Tema claro, escuro ou automático; foto local e oito avatares agrícolas, separados por login e perfil.
- Dados locais em SQLite, com migração das versões anteriores.

## Executar

Na pasta `agrohub_app`:

```bash
flutter pub get
flutter run
```

Para usar no navegador:

```bash
flutter run -d chrome
```

O suporte web usa os arquivos `web/sqlite3.wasm` e `web/sqflite_sw.js` já incluídos no projeto. Para gerar novamente esses arquivos após atualizar a dependência de SQLite web, execute `dart run sqflite_common_ffi_web:setup`.

## Dados de demonstração

Uma instalação local vazia recebe uma fazenda, um comércio, 20 operadores, 24 talhões e 20 lotes de exemplo. Na tela inicial, entre com a fazenda `11222333000181` e a senha `Agro2026`. Na etapa seguinte, use o mesmo documento com a senha de operação `Campo2026` ou abra a área de administrador. O comércio de exemplo usa o documento `22333444000181` com as mesmas senhas.

Os preços e cinco lançamentos financeiros da instalação de demonstração são ilustrativos. Empresas cadastradas pelo usuário começam sem lançamentos; os indicadores passam a refletir os registros feitos no aplicativo. Não há sincronização remota, pagamento ou compra neste projeto.

## Verificação

```bash
flutter analyze
flutter test
flutter build web --release
```
