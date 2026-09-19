# app.py
# API simples com duas rotas: Produtos e Pedidos
# Tecnologia: Python + Flask

import os
import json
import boto3
from flask import Flask, request, jsonify

app = Flask(__name__)

# Região e URL da fila SQS vêm de variáveis de ambiente definidas pelo Terraform
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
QUEUE_URL = os.environ.get("SQS_QUEUE_URL")

sqs = boto3.client("sqs", region_name=AWS_REGION)

# Lista básica de produtos (em memória, só para demonstração)
produtos = [
    {"id": 1, "nome": "Notebook", "preco": 3500.00},
    {"id": 2, "nome": "Mouse",    "preco": 50.00},
    {"id": 3, "nome": "Teclado",  "preco": 120.00},
]


@app.route("/produtos", methods=["GET"])
def listar_produtos():
    """Retorna a lista básica de produtos."""
    return jsonify(produtos)


@app.route("/pedidos", methods=["POST"])
def criar_pedido():
    """Recebe um pedido e envia como mensagem para a fila SQS."""
    pedido = request.get_json(force=True)

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(pedido),
    )

    return jsonify({"status": "pedido enviado para processamento", "pedido": pedido}), 201


@app.route("/", methods=["GET"])
def health():
    return jsonify({"status": "API no ar"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
