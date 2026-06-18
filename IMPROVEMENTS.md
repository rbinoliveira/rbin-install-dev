# Melhorias sugeridas — rbin-install-dev

Revisão técnica do projeto com foco em **manutenibilidade, segurança e robustez**.
Cada item traz o problema, a evidência (`arquivo:linha`) e a correção sugerida.
Priorização: **P0** (faça primeiro), **P1** (importante), **P2** (qualidade de vida).

---

## P0 — Estruturais (maior impacto)

### 1. Duplicação macOS × Linux: dois conjuntos de scripts que divergem
Hoje `macos/scripts/enviroment/` e `linux/scripts/enviroment/` são cópias paralelas
mantidas à mão, com **numeração diferente para a mesma ferramenta**:

| Ferramenta | macOS | Linux |
|---|---|---|
| Claude | `11` | `10` |
| Codex | `11.2` | `10.2` |
| SSH | `13` | `12` |
| Cursor config | `16` | `15` |
| RTK | `20.5` | `19.5` |

Isso já me obrigou a criar o passo novo em **dois números distintos** (`13.5` mac / `12.5` linux)
e a editar dois `00-install-all.sh`. Cada feature nova custa o dobro e corre risco de drift.

**Sugestão:** extrair a lógica de cada passo para um script único em `scripts/` e deixar `macos/`
e `linux/` apenas com as diferenças reais (gerenciador de pacotes, clipboard, paths). Os helpers
em `lib/` (`apt_helper.sh`, `brew_helper.sh`, `platform.sh`) já provam que a abstração é viável —
falta aplicá-la aos passos. Meta: numeração única e **um** `00-install-all.sh`.

### 2. `eval` inseguro ao carregar o `.env`
`lib/env_validator.sh:299` e `macos|linux/.../00-install-all.sh:52` fazem:
```bash
eval "export $line" 2>/dev/null || true
```
Isso é **execução arbitrária de código** (uma linha `FOO=$(rm -rf x)` no `.env` roda) e quebra
silenciosamente com valores que tenham espaço, `#`, aspas ou `$`. O `2>/dev/null || true` ainda
esconde o erro, então a variável simplesmente não é setada e o bug aparece lá na frente.

**Sugestão:** parsing seguro sem `eval`:
```bash
while IFS='=' read -r key val; do
  [[ "$key" =~ ^[[:space:]]*# ]] && continue
  [[ -z "$key" ]] && continue
  val="${val%\"}"; val="${val#\"}"
  printf -v "$key" '%s' "$val"
  export "$key"
done < "$env_file"
```

### 3. Três implementações diferentes de "ler variável do .env"
- `lib/env_helper.sh:20` → `get_env_var` (lê + faz prompt + salva + **exporta** + faz `echo`)
- `lib/env_validator.sh:11` → `get_var_from_env` (só lê)
- `00-install-all.sh:47` → loop inline próprio

Além da duplicação, `get_env_var` **mistura mensagens de log com o valor de retorno no stdout**
(`env_helper.sh:59-89`): ele dá `echo` de "⚠️ required" e "✓ Saved" **e** do valor na mesma saída.
Quem usa `x=$(get_env_var ...)` (ex.: `linux/.../01-configure-git.sh:44`) captura o lixo junto.
Só não explode hoje porque, no fluxo normal, o valor já existe e o caminho de prompt não roda.

**Sugestão:** uma única função canônica em `lib/`. Mensagens vão para `stderr` (`>&2`), valor para
`stdout`. Os outros módulos passam a chamá-la.

---

## P1 — Robustez e segurança

### 4. Guard de "não executar direto" copiado em ~50 arquivos
As ~20 linhas do *Module Guard* (ex.: `13.5-configure-dev-accounts.sh:6-26`) estão repetidas em
todo script. Qualquer ajuste no texto/comportamento exige editar dezenas de arquivos.

**Sugestão:** mover para `lib/guard.sh` e cada script começar com
`source "$(dirname "$0")/../../../lib/guard.sh"`.

### 5. `set -e` + funções que retornam não-zero podem abortar a instalação
`env_helper.sh:14` ativa `set -eo pipefail` ao ser sourçado e `get_env_var` faz `return 1` quando
o valor é vazio (`env_helper.sh:66`). Num script com `set -e`, isso derruba a instalação inteira em
vez de tratar o caso. Vários `check_command` em `00-install-all.sh` também dependem de exit codes
que, sob `set -e`, têm comportamento sutil.

**Sugestão:** padronizar tratamento de erro; funções de leitura não devem usar `return 1` como
sinal de "vazio" sob `set -e`. Cobrir com testes (ver item 8).

### 6. Mensagens "Next, run" desatualizadas / referências mortas
- `macos/.../13-configure-ssh.sh:65` manda rodar `13-configure-file-watchers.sh` — **não existe**.
- `run.sh:271` pula `13-configure-inotify.sh` — passo removido, referência morta.

Num fluxo onde tudo roda via `00-install-all.sh`, esses "Next, run: bash NN-..." confundem e
envelhecem. **Sugestão:** remover as linhas "Next, run" ou gerá-las a partir da ordem real.

### 7. `.gitignore` ignora arquivos que estão versionados
`.gitignore` lista `CLAUDE.md`, `AGENTS.md`, `.claude/`, `.mcp.json`, mas `CLAUDE.md`/`AGENTS.md`
existem no repo. `.gitignore` não "desrastreia" o que já está commitado, então o resultado é
confuso: edições nesses arquivos aparecem/não aparecem dependendo do estado. **Sugestão:** decidir
— ou versiona (tira do ignore) ou `git rm --cached` e mantém ignorado. (✅ `.env` está corretamente
ignorado e **não** rastreado.)

### 8. Zero testes e zero lint
`package.json:10` → `"test": "echo \"No tests yet\""`. Para um projeto que mexe em `~/.gitconfig`,
`~/.ssh` e `~/.zshrc` do usuário, a ausência de testes é o maior risco de regressão.

**Sugestão mínima e barata:**
- `shellcheck` em todos os `.sh` (acha 80% dos bugs de shell automaticamente).
- [bats](https://github.com/bats-core/bats-core) para os helpers de `lib/` (parsing de `.env`,
  `includeIf`, idempotência) rodando com `HOME` temporário — como fiz manualmente ao validar o
  `13.5`.
- GitHub Actions rodando shellcheck + bats em macOS e Ubuntu a cada PR.

### 9. Idempotência do SSH agent
`macos/.../13-configure-ssh.sh:49` roda `eval "$(ssh-agent -s)"` a cada execução, **subindo um novo
agente** toda vez. Em reinstalações isso acumula agentes órfãos. **Sugestão:** reusar o agente
existente (checa `SSH_AUTH_SOCK`) ou usar o keychain no macOS, como o `13.5` faz.

---

## P2 — Qualidade de vida e consistência

### 10. Reprodutibilidade: tudo instala "latest"
Não há fixação de versões (Node, ferramentas, casks). Duas máquinas configuradas em datas
diferentes ficam diferentes. **Sugestão:** um `versions.env` opcional com pins e fallback para
latest.

### 11. Sem desinstalação / rollback
O projeto escreve em vários dotfiles mas não oferece `uninstall`. **Sugestão:** registrar o que foi
alterado (ou um `run.sh --uninstall`) para reverter com segurança.

### 12. Segredos em texto plano no `.env`
`GITHUB_TOKEN` (`env_validator.sh:163`) fica em claro no `.env`. O mascaramento em
`env_validator.sh:271-272` é só na exibição. **Sugestão:** oferecer `gh auth login` / Keychain /
`secret-tool` em vez de persistir token no arquivo.

### 13. README de 23 KB tende a divergir do código
`readme.md` (~24 KB) documenta passos à mão. Com a numeração mudando entre plataformas, ele
envelhece. **Sugestão:** gerar a lista de passos a partir dos arquivos reais (o `run.sh:348`
já sabe derivar nome/numero — dá para extrair um `--list` que alimenta o README).

### 14. `.env.example` versus campos opcionais novos
Acabei de adicionar `DEV_ACCOUNT_*` ao `.env.example`. Como são opcionais (com prompt no terminal),
vale documentar no README a diferença entre "obrigatório" (valida em `env_validator`) e "perguntado
on-demand" (via `get_env_var`), para o usuário saber o que precisa preencher antes.

### 15. Bash 3.2 (macOS) vs recursos modernos
O macOS ainda traz Bash 3.2. `run.sh` já evita arrays associativos de propósito (`run.sh:335`), mas
convém um teste de CI no Bash 3.2 para garantir que nada novo (ex.: `${var,,}`, `mapfile`) entre sem
querer.

---

## Resumo executivo

| # | Item | Prioridade | Esforço |
|---|---|---|---|
| 1 | Unificar scripts mac/linux | P0 | Alto |
| 2 | Remover `eval` do parse de `.env` | P0 | Baixo |
| 3 | Uma função única de leitura de env (valor só no stdout) | P0 | Médio |
| 4 | Module guard em `lib/` | P1 | Baixo |
| 5 | Revisar `set -e` + `return 1` | P1 | Médio |
| 6 | Limpar mensagens "Next, run" mortas | P1 | Baixo |
| 7 | Resolver `.gitignore` vs arquivos versionados | P1 | Baixo |
| 8 | shellcheck + bats + CI | P1 | Médio |
| 9 | Idempotência do ssh-agent | P1 | Baixo |
| 10–15 | Pins, uninstall, segredos, README, Bash 3.2 | P2 | Vários |

**Maior alavanca:** itens **1, 2 e 3** — eles atacam a causa raiz (duplicação e parsing frágil de
`.env`) de onde nascem a maioria dos bugs e do retrabalho.
