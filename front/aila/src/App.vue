<template>
  <div class="d-flex align-items-center justify-content-center min-vh-100 bg-light p-4">
    <div class="card shadow w-100" style="max-width: 500px">
      <div class="card-body">
        <h1 class="card-title text-center mb-4">Consultar Cooperado</h1>

        <!-- Tela de login -->
        <template v-if="!token">
          <div class="d-flex justify-content-center">
            <h5>Logue com sua agência</h5>
          </div>
          <form @submit.prevent="login">
            <div class="mb-3">
              <input
                v-model="agencia"
                type="text"
                class="form-control"
                placeholder="Agência"
              />
            </div>
            <div class="mb-4">
              <input
                v-model="senha"
                type="password"
                class="form-control"
                placeholder="Senha"
              />
            </div>
            <button type="submit" class="btn btn-success w-100" :disabled="logando">
              <p v-if="!logando">Entrar</p>
              <p v-else>Entrando...</p>
            </button>
            <div class="d-flex justify-content-center">
              <p v-if="loginError" class="text-danger m-2">{{ loginError }}</p>
            </div>
          </form>
        </template>

        <!-- Tela de consulta -->
        <template v-else>
          <form @submit.prevent="consultar">
            <div class="mb-3">
              <input
                v-model="cpf"
                type="text"
                class="form-control"
                placeholder="Digite o CPF"
              />
            </div>
            <button type="submit" class="btn btn-success w-100" :disabled="consultando">
              <p v-if="!consultando">Consultar</p>
              <p v-else="!consultando">Gerando consulta...</p>
            </button>
            <div class="d-flex justify-content-center">
              <p v-if="consultaError" class="text-danger m-2">{{ consultaError }}</p>
            </div>
          </form>
          <button @click="logout" class="btn btn-danger w-100 mt-3"><p>Sair</p></button>

          <hr class="m-5" />

          <!-- Sugestões de abordagem -->
          <h2 class="text-center mb-3">Sugestões de Abordagem</h2>
          <div class="mt-3">
            <div
              class="card shadow-sm border mb-4"
              v-for="registro in registros"
              :key="registro.nome"
            >
              <div class="card-body">
                <h5 class="card-title">{{ registro.nome }}</h5>
                <div v-if="!registro.ia">
                  <div class="mt-3">
                    <h6 class="fw-bold">🧑‍💼 Ordem dos Colaboradores:</h6>
                    <ol class="list-group list-group-numbered mb-3">
                      <li
                        v-for="(colab, index) in registro.colaboradores"
                        :key="index"
                        class="list-group-item"
                      >
                        {{ colab }}
                      </li>
                    </ol>
                  </div>

                  <div class="mb-3">
                    <h6 class="fw-bold text-success">🟢 Assuntos para Propor:</h6>
                    <div>
                      <span
                        v-for="(item, index) in registro.propor"
                        :key="index"
                        class="badge bg-success d-block py-2 mb-2 text-wrap"
                      >
                        {{ item }}
                      </span>
                    </div>
                  </div>

                  <div>
                    <h6 class="fw-bold text-danger">🟠 Assuntos a Evitar:</h6>
                    <div>
                      <span
                        v-for="(item, index) in registro.evitar"
                        :key="index"
                        class="badge bg-danger d-block py-2 mb-2 text-wrap"
                      >
                        {{ item }}
                      </span>
                    </div>
                  </div>
                </div>
                <div v-else>
                  <p class="card-title">
                    Infelizmente ia gerou fora do modelo proposto. Mas ainda podes ver sua
                    resposta:
                  </p>
                  <div>
                    <span>
                      {{ registro.ia }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import axios from "axios";

type registro = {
  nome: string;
  ia?: string;
  colaboradores: string[];
  propor: string[];
  evitar: string[];
};

const agencia = ref<string>("");
const senha = ref<string>("");
const loginError = ref<string>("");
const consultaError = ref<string>("");
const logando = ref<boolean>(false);
const consultando = ref<boolean>(false);
const token = ref<string | null>(null);

const cpf = ref<string>("");
const registros = ref<registro[]>([]);

const api = axios.create({
  baseURL: import.meta.env.VITE_API,
});

let intervaloId: number | null = null;

onMounted(() => {
  const storedToken = localStorage.getItem("token");
  if (storedToken) token.value = storedToken;

  buscarRegistros();
  intervaloId = window.setInterval(buscarRegistros, 5000);
});

onUnmounted(() => {
  if (intervaloId) clearInterval(intervaloId);
});

function login(): void {
  if (!agencia.value || !senha.value) {
    loginError.value = "Agência e/ou senha não informados";
    return;
  }

  logando.value = true;
  api
    .post("/get_token/", {
      agencia: agencia.value,
      senha: senha.value,
    })
    .then(({ data }) => {
      token.value = data.token as string;
      localStorage.setItem("token", token.value);
      loginError.value = "";
    })
    .catch((error) => {
      loginError.value = error.response?.data?.detail || error.message;
    })
    .finally(() => {
      logando.value = false;
      agencia.value = "";
      senha.value = "";
    });
}

function logout(): void {
  token.value = null;
  localStorage.removeItem("token");
  cpf.value = "";
}

async function consultar(): Promise<void> {
  if (!token.value) return;
  consultando.value = true;

  api
    .post(
      "/consulta/",
      {
        cooperado: cpf.value,
      },
      {
        headers: {
          Authorization: `Bearer ${token.value}`,
        },
      }
    )
    .then(() => {
      cpf.value = "";
      consultaError.value = "";
    })
    .catch((error) => {
      if (error.status == 401) logout();
      consultaError.value = error.response?.data?.detail || error.message;
    })
    .finally(() => {
      consultando.value = false;
    });
}

function buscarRegistros(): void {
  if (!token.value) return;

  api
    .get("/consulta/", {
      headers: {
        Authorization: `Bearer ${token.value}`,
      },
    })
    .then(({ data }) => {
      registros.value = data;
    })
    .catch((error) => {
      if (error.status == 401) logout();
      console.error(error.response?.data?.detail || error.message);
    });
}
</script>

<style>
h1 {
  font-family: "Exo 2", sans-serif;
  color: #165c7d !important;
}

h2,
h3,
h4,
h5,
h6 {
  font-family: "Open Sans", sans-serif;
  font-weight: 700;
  color: #165c7d !important;
}

p {
  font-family: "Open Sans", sans-serif;
  font-weight: 700;
  margin: 0;
  padding: 0;
}

span {
  font-family: "Open Sans", sans-serif;
  font-weight: 300;
}
</style>
