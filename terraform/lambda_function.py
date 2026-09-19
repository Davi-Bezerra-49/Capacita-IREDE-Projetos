# lambda_function.py
# Função Lambda disparada pelo SQS.
# Toda mensagem gerada aqui via print()/logging vai automaticamente para o CloudWatch Logs.

import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    for record in event.get("Records", []):
        body = record.get("body")
        logger.info("Novo pedido recebido da fila: %s", body)

    return {"statusCode": 200, "body": "Processamento concluido"}
