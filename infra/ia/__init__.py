import json
import uuid
import re

import boto3


class IaRepository:
    session: boto3.Session
    agent_id: str
    agent_alias: str

    def __init__(self, session: boto3.Session, agent_id: str, agent_alias: str):
        self.session = session
        self.agent_id = agent_id
        self.agent_alias = agent_alias

    def consultar_cooperado(self, dados: dict) -> str:
        dados_json = json.dumps(dados, ensure_ascii=False)

        client = self.session.client("bedrock-agent-runtime")

        output_text = ''
        response = client.invoke_agent(
            agentId=self.agent_id,
            agentAliasId=self.agent_alias,
            sessionId=str(uuid.uuid4()),
            inputText=dados_json,
        )

        try:
            if "completion" in response:
                for event in response["completion"]:
                    if "chunk" in event:
                        chunk = event["chunk"]
                        part = chunk.get("bytes", b"").decode("utf-8")
                        output_text += part
            else:
                output_text = response.get("outputText", "")

            matches = re.findall(r'\{.*?\}', output_text, re.DOTALL)
            resultado_dict = json.loads(matches[0])
        except:
            resultado_dict = {
                "colaboradores": [],
                "propor": [],
                "evitar": [],
                "ia": output_text or "Me desculpe! Buguei ;(",
            }

        return resultado_dict
