from infra.auth import AuthRepository
from infra.database.agencia import AgenciaDb


class AuthService:
    agencia_db: AgenciaDb
    auth_repository: AuthRepository

    def __init__(self, agencia_db: AgenciaDb, auth_repository: AuthRepository):
        self.agencia_db = agencia_db
        self.auth_repository = auth_repository

    def get_agencia_from_token(self, token: str) -> int:
        if not token or not isinstance(token, str):
            raise Exception(status_code=401, detail="Token ausente ou malformado")

        return self.auth_repository.verify_token(token).get("agencia")

    async def verify_agencia_password(self, agencia: int, senha: str):
        senha_hash = await self.agencia_db.get_senha_by_agencia_id(agencia)
        if self.auth_repository.verify_password(senha, senha_hash):
            return self.generate_token_with_agencia(agencia)
        raise Exception(status_code=401, detail="Autenticação inválida")

    def generate_token_with_agencia(self, agencia: int) -> str:
        return self.auth_repository.create_token({"agencia": str(agencia)})
