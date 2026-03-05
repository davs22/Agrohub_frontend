# Define a imagem base
# Flutter e Dart instalados
# Atribui apelido 'build' para captura de dados
FROM cirrusci/flutter:stable AS build

# Cria e entra na pasta /app dentro do container
# Todas as atividades acontecerão neste diretório
WORKDIR /app

# Copia todos os arquivos onde está o Dockerfile
# Move para dentro da pasta /app do container
COPY . .

# Baixa as dependências do projeto
# Compila o app para a plataforma web
# Resultado gerado em build/web
RUN flutter pub get && flutter build web


# Inicia uma imagem Nginx
# Servidor web
# Minimalista
FROM nginx:alpine

# Vai até o estágio anterior (--from=build)
# Pega apenas a pasta onde o site foi compilado
# Copia para a pasta padrão do Nginx
# Deixa o SDK do Flutter e o código-fonte para trás
COPY --from=build /app/build/web /usr/share/nginx/html

# Informa a porta de conexão do container
EXPOSE 80

# Define o comando que mantém o servidor rodando
# daemon off para que o container continue ativo
CMD ["nginx","-g","daemon off;"]