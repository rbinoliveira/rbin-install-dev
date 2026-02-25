# Tasks – Unificação e modo Pessoal / Empresa

Documento gerado a partir do prompt: unificar uso nos dois projetos com destino `rbin-install-dev`; primeiro passo ao rodar `run.sh` é escolher modo pessoal ou empresa; modo empresa com AWS/Java/.NET; modo pessoal sem; remover passo inotify.

---

## 1. Escolha de modo como primeira pergunta no `run.sh`

- [x] Ao iniciar `bash run.sh`, a **primeira** interação deve ser perguntar: **Modo pessoal** ou **Modo empresa**.
- [x] Definir e exportar variável (ex.: `RBIN_MODE=personal` ou `RBIN_MODE=enterprise`) para o resto do fluxo.
- [x] Mensagens claras: modo pessoal = ambiente dev sem AWS/Java/.NET; modo empresa = inclui AWS, Java e .NET.

---

## 2. Remover o passo inotify

- [x] **Linux:** remover a execução de `13-configure-inotify.sh` do `linux/scripts/enviroment/00-install-all.sh`.
- [x] **Linux:** remover entrada de `13-configure-inotify.sh` em `lib/check_installed.sh` (se existir).
- [x] **Linux:** remover referência “próximo passo: 13-configure-inotify” em `linux/scripts/enviroment/12-configure-ssh.sh`.
- [x] Opcional: remover ou arquivar o arquivo `linux/scripts/enviroment/13-configure-inotify.sh` (arquivo removido).
- [x] Atualizar `readme.md` (e qualquer doc) que cite o script inotify.

---

## 3. Modo empresa: AWS, Java e .NET

- [x] Copiar/incorporar `lib/aws_helper.sh` do projeto work para `rbin-install-dev/lib/`.
- [x] No `run.sh`, em modo empresa: carregar `lib/aws_helper.sh` e validar (ou solicitar) variáveis de ambiente AWS quando aplicável.
- [x] Trazer scripts do projeto work que são só de empresa para `rbin-install-dev` (renumerar se necessário para não conflitar com scripts existentes):
  - AWS: instalação AWS CLI, AWS VPN client, configure AWS SSO.
  - Java: script de instalação Java.
  - .NET: script de instalação .NET.
- [x] Ajustar `linux/scripts/enviroment/00-install-all.sh` e `macos/scripts/enviroment/00-install-all.sh` para:
  - Se `RBIN_MODE=enterprise`: incluir e executar os scripts de AWS, Java e .NET (e quaisquer outros exclusivos de empresa).
  - Se `RBIN_MODE=personal`: não executar esses scripts.
- [x] Garantir que a lista de scripts exibida em “Select scripts” (ou equivalente) no `run.sh` respeite o modo: modo pessoal lista só scripts pessoais; modo empresa lista pessoal + empresa (ou apenas os que fazem sentido para o fluxo).

---

## 4. Validação de ambiente por modo

- [x] **Modo pessoal:** validar apenas variáveis necessárias para uso pessoal (ex.: Git, etc.), sem exigir AWS/Java/.NET.
- [x] **Modo empresa:** além do pessoal, validar (ou guiar) configuração de AWS (ex.: `.env` com `AWS_SSO_*`, etc.) e qualquer variável necessária para Java/.NET se aplicável.
- [x] Atualizar `.env.example` em `rbin-install-dev` para incluir seção opcional de empresa (AWS, etc.) e comentário indicando “obrigatório só em modo empresa”.

---

## 5. Consistência entre projetos (destino único)

- [x] Considerar `rbin-install-dev` como **único** repositório de uso; o outro (work) será removido do GitHub depois.
- [x] Garantir que documentação (README, comentários no `run.sh`) deixe claro: modo pessoal vs empresa e que inotify foi removido do fluxo.

---

## Resumo de arquivos a tocar

| Ação | Arquivo / local |
|------|------------------|
| Alterar | `run.sh` – primeira pergunta modo, export `RBIN_MODE`, carregar `aws_helper` em modo empresa, listar scripts por modo |
| Alterar | `linux/scripts/enviroment/00-install-all.sh` – remover inotify; condicional por `RBIN_MODE` para scripts empresa |
| Alterar | `macos/scripts/enviroment/00-install-all.sh` – condicional por `RBIN_MODE` para scripts empresa (se existirem no macos) |
| Alterar | `lib/check_installed.sh` – remover `13-configure-inotify.sh` |
| Alterar | `linux/scripts/enviroment/12-configure-ssh.sh` – remover “next: 13-configure-inotify” |
| Adicionar | `lib/aws_helper.sh` (copiar do work) |
| Adicionar | Scripts empresa em `linux/` e `macos/` (AWS, Java, .NET, etc.) com numeração alinhada |
| Atualizar | `.env.example` – seção empresa opcional |
| Atualizar | `readme.md` – remover referência inotify; documentar modos pessoal/empresa |

---

*Destino do projeto unificado: `/home/pessoal/dev/github/rbin-install-dev`.*
