
/* Após logar no Postgresql pela primeira vez, preciso criar um usuário (que aqui tem o meu apelido como nome) e dar pra ele certas permissões, além do status de superusuário, 
que utilizo pois caso contrário não consigo utilizar certos comandos, não sei resolver esse problema de outro jeito */

CREATE USER edu WITH PASSWORD 'pset' CREATEDB CREATEROLE SUPERUSER;

SET ROLE edu; --para operar com o usuário dono

/* Com esse usuário, posso agora criar o banco de dados com os parâmetros indicados no pdf do PSET, e também utilizar um comando para me conectar a ela. Mesmo
que o terminal me mostre que estou logado como "postgres" o usuário operante ainda é o meu "edu" */

CREATE DATABASE uvv WITH OWNER edu 
TEMPLATE template0
ENCODING UTF8
LC_COLLATE 'pt_BR.UTF-8'
LC_CTYPE 'pt_BR.UTF-8'
ALLOW_CONNECTIONS true;

\connect uvv 

/* Agora vou criar o SCHEMA lojas, e também alterá-lo para o SCHEMA principal utilizado nesse banco de dados */

CREATE SCHEMA lojas;

SET SEARCH_PATH TO lojas; -- esse metódo funcionou melhor do que o que foi mostrado no pset

/* Agora, crio a tabela lojas, com a primeira coluna sendo a loja_id, que também é a Primary Key */

CREATE TABLE lojas ( loja_id NUMERIC ( 38 ) NOT NULL PRIMARY KEY);  --mesmo com resultados conflitantes, acho que Numeric é o equivalente correto

/* Aqui eu estava encontrando erros iniciais ao qual aprendi depois, então o resto foi criado através da ALTER TABLE */

ALTER TABLE lojas ADD COLUMN nome VARCHAR ( 255 ) NOT NULL,
ADD COLUMN endereco_web VARCHAR ( 100 ),
ADD COLUMN endereco_fisico VARCHAR ( 512 ),
ADD COLUMN latitude NUMERIC,
ADD COLUMN longitude NUMERIC,
ADD COLUMN logo BYTEA,
ADD COLUMN logo_mime_type VARCHAR ( 512 ),
ADD COLUMN logo_arquivo VARCHAR ( 512 ),
ADD COLUMN logo_charset VARCHAR ( 512 ),
ADD COLUMN logo_ultima_atualizacao DATE;

/* Como alguns tipos de dados não existem no Postgres em comparação com a imagem de instrução da UVV, 
pesquisei na internet quais seriam as alternativas equivalentes. */

CREATE TABLE clientes ( cliente_id NUMERIC ( 38 ) NOT NULL PRIMARY KEY,
email VARCHAR ( 255 ) NOT NULL,
nome VARCHAR ( 255 ) NOT NULL,
telefone1 VARCHAR ( 20 ),
telefone2 VARCHAR ( 20 ),
telefone3 VARCHAR ( 20 ) );

CREATE TABLE pedidos ( pedido_id NUMERIC ( 38 ) NOT NULL,
data_hora TIMESTAMP,
cliente_id NUMERIC ( 38 ) NOT NULL,
status VARCHAR ( 15 ),
loja_id NUMERIC ( 38 ) NOT NULL, 
PRIMARY KEY (pedido_id),
FOREIGN KEY (cliente_id) REFERENCES clientes (cliente_id), 
FOREIGN KEY (loja_id) REFERENCES lojas (loja_id) );

CREATE TABLE produtos ( produto_id NUMERIC ( 38 ) NOT NULL PRIMARY KEY,
nome VARCHAR ( 255 ) NOT NULL,
preco_unitario NUMERIC ( 10,2 ),
detalhes BYTEA,
imagem BYTEA,
imagem_mime_type VARCHAR ( 512 ),
imagem_arquivo VARCHAR ( 512 ),
imagem_charset VARCHAR ( 512 ),
imagem_ultima_atualizacao DATE);

CREATE TABLE envios ( envio_id NUMERIC ( 38 ) NOT NULL PRIMARY KEY,
loja_id NUMERIC ( 38 ) NOT NULL,
cliente_id NUMERIC ( 38 ) NOT NULL,
endereco_entrega VARCHAR ( 512 ) NOT NULL,
status VARCHAR ( 15 ) NOT NULL,
FOREIGN KEY (cliente_id) REFERENCES clientes (cliente_id), 
FOREIGN KEY (loja_id) REFERENCES lojas (loja_id) );

CREATE TABLE estoques ( estoque_id NUMERIC ( 38 ) NOT NULL PRIMARY KEY,
loja_id NUMERIC ( 38 ) NOT NULL,
produto_id NUMERIC ( 38 ) NOT NULL,
quantidade NUMERIC ( 38 ) NOT NULL,
FOREIGN KEY (loja_id) REFERENCES lojas (loja_id),
FOREIGN KEY (produto_id) REFERENCES produtos (produto_id) );

CREATE TABLE pedidos_itens ( pedido_id NUMERIC ( 38 ) NOT NULL,
produto_id NUMERIC ( 38 ) NOT NULL,
numero_da_linha NUMERIC ( 38 ) NOT NULL,
preco_unitario NUMERIC ( 10,2 ) NOT NULL,
quantidade NUMERIC ( 38 ) NOT NULL,
envio_id NUMERIC ( 38 ),
FOREIGN KEY (pedido_id) REFERENCES pedidos (pedido_id),
FOREIGN KEY (produto_id) REFERENCES produtos (produto_id),
FOREIGN KEY (envio_id) REFERENCES envios (envio_id) ) ;

ALTER TABLE pedidos_itens ADD PRIMARY KEY (pedido_id,produto_id); 

/* Agora que as tabelas e suas colunas foram criadas, irei criar as respectivas restrições de checagem, as colunas "status" 
dos pedidos e envios precisam receber apenas certos dados específicos, enquanto na tabela "lojas" pelo menos uma das colunas de endereço precisam estar preenchidas */

ALTER TABLE pedidos
ADD CONSTRAINT check_status CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO'));

ALTER TABLE envios
ADD CONSTRAINT check_status CHECK (status IN ('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE'));

ALTER TABLE lojas
ADD CONSTRAINT check_endereco CHECK (endereco_fisico IS NOT NULL OR endereco_web IS NOT NULL);


