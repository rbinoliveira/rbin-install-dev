# Anotações de Monorepo

## Rodar yarn init na pasta raiz

```bash
  # Rodar no terminal da raiz:
  $ yarn init -y
```

## Configuração do package.json da raiz

```bash
  Adicionar no arquivo package.json da raiz as tags:
  "private": "true",
  "workspaces": {
    "packages": [
      "packages/*",
      "packages/shared/*"
    ],
    "nohoist": [
      "**/jest",
      "**/ts-jest"
    ]
  },
```

## Criar pasta packages

``` bash
  # criar pasta packages
  $ mkdir packages
```

## Criar arquivo gitignore da raiz

  Criar arquivo
``` bash
  .gitignore

```

## Configuração do gitignore da raiz

 Abrir arquivo .gitignore da raiz e adicionar:
```bash
  node_modules
  dist
  yarn-error.log
```

## Adicionar dependência typescript

Na raiz do projeto rodar no terminal:
```bash
 $ yarn add typescript -DW
 ```

## Criar pasta shared e eslint-config

``` bash
  # Entrar na pasta packages
  $ cd packages
  # Dentro da pasta packages criar pasta shared
  $ mkdir shared
  # Entrar na pasta shared 
  $ cd shared
  # Dentro da pasta shared criar pasta eslint-config
  $ mkdir eslint-config

  # Caminho das pastas
  packages > shared > eslint-config
```

## Rodar yarn init -y no eslint-config

```bash
  # Abrir pasta packages/shared/eslint-config
  $ cd packages/shared/eslint-config
  # Dentro da pasta eslint-config rodar no terminal
  $ yarn init -y
```

## Alterar nome do projeto no package.json do eslint-config

``` bash
  # Abrir arquivo package.json da pasta eslint-config
  $ cd packages/shared/eslint-config/package.json
  # Trocar nome do projeto para:
  @NOME_DO_PROJETO/eslint-config

```

## Adicionar plugins

```bash
  # Abrir a pasta eslint-config
  $ cd packages/shared/eslint-config
  # Rodar no terminal os seguintes comandos:
  $ yarn add @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint@6.8.0 eslint-config-prettier eslint-config-standard eslint-import-resolver-typescript eslint-plugin-import eslint-plugin-node eslint-plugin-prettier eslint-plugin-promise eslint-plugin-react eslint-plugin-standard prettier -D

```

## Rodar yarn na pasta eslint-config

```bash
  # Abrir pastas packages/shared/eslint-config
  $ cd packages/shared/eslint-config
  # Rodar o seguinte comando no terminal:
  $ yarn

```

## Criar arquivo eslintrc.js

```bash
  # Abrir as pastas packages/eslint-config
  $ cd packages/eslint-config
  # Criar arquivo:
  .eslintrc.js

```

## Adicionar configuração no arquivo .eslintrc.js

 ```bash
  # Abrir pastas para acessar o arquivo .eslintrc.js
  $ cd packages/eslint-config/.eslintrc.js
  ```
  Adicionar configuração  que se encontra : [aqui](monorepo-eslint.md)



## Alterar a tag main 

```bash
  # Abrir pastas para acessar o package.json
  $ cd packages/eslint-config/package.json
  # alterar a tag main do package.json para:
  `"main": ".eslintrc.js",`

```

## Criar arquivo prettier.config.js

Na raiz do projeto criar o arquivo:
```bash
  prettier.config.js
```

## Adicionar configuração no prettier.config.js

  No arquivo prettier.config.js adicionar:
```bash
  module.exports = {
    semi: false,
    singleQuote: true,
    arrowParens: 'avoid',
    trailingComma: 'none',
    endOfLine: 'auto'
  }
```

## Criar arquivo .eslintrc.js

Na raiz do projeto criar o arquivo:

```bash
  .eslintrc.js

```

## Adicionar tag devDependencies

No arquivo package.json adicionar na tag devDependecies o projeto eslint-config.
Vai ficar mais ou menos assim:

```
"devDependencies": {
  "typescript": "^4.0.2",
  "@NOME_DO_PROJETO/eslint-config": "*"
}
```

## Rodar yarn na raiz

Na raiz do projeto rodar no terminal:
```bash
  $ yarn
```

## Adicionar configuração no arquivo .eslintrc.js

  No arquivo .eslintrc.js adicionar:

```bash
  const config = require('@NOME_DO_PROJETO/eslint-config')

  module.exports = config
```

## Criar arquivo .eslintignore

 Na raiz do projeto criar o arquivo:
  .eslintignore

## Adicionar configuração no arquivo .eslintignore

  No arquivo .eslintignore adicionar:

```bash
.eslintrc.js
packages/**/*.js
node_modules
dist
```

## Criar arquivo tsconfig.json

Criar arquivo tsconfig.json

## Adicionar configuração no arquivo tsconfig.json

  No arquivo tsconfig.json adicionar:

```bash
{
  "compilerOptions": {
    "target": "es2017",
    "module": "commonjs",
    "noEmit": true,
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

## Configurando os projetos separadamente

Configure os projetos separadamente acessando os links abaixo:

- [Server](monorepo-express.md)<br>
- [ReactJS](monorepo-react.md)<br>
- [Next](monorepo-next.md)<br>
- [React Native](monorepo-react-native.md)<br>
- [Server Complexo](monorepo-express-complexo.md)<br>

Caso precise do axios ou de testes com jest volte para esse tutorial para continuar os próximos passos.

## Criar pasta axios-config

```bash
  # Abrir pasta packages/shared
  $ cd packages/shared
  # Criar pasta axios-config
  $ mkdir axios-config
```

## Rodar yarn init -y

```bash
  # Abrir pastas packages/shared/axios-config
  $ cd packages/shared/axios-config
  # Rodar no terminal o  seguinte comando:
  $ yarn init -y 

```

## Adicionar axios

```bash
  # Abrir pastas packages/shared/axios-config
  $ cd packages/shared/axios-config
  # Rodar no terminal o  seguinte comando:
  $ yarn add axios 

```

## Alterar nome do projeto

```bash
  # Abrir pastas packages/shared/axios-config/package.json para acessar o arquivo package.json
  $ cd packages/shared/package.json
  # Alterar o nome do projeto para:
  @NOME_DO_PROJETO/axios-config
```

## Criar arquivo index.ts

```bash
  # Abrir pastas packages/shared/axios-config para criar arquivo index.ts
  $ cd packages/shared/axios-config
  # Criar o arquivo 
  index.ts

```

## Adicionando configuração no arquivo index.ts

```bash
  # Abrir pastas packages/shared/axios-config/index.ts para acessar o arquivo index.ts e adicionar configuração:
  $ cd packages/shared/axios-config/index.ts
  # Adicionar a seguinte configuração:
  import axios from 'axios'

  const api = axios.create({
    baseURL: 'http://localhost:3333'
  })

  export default api

```

## Alterar a tag main

```bash
  # Abrir pastas packages/shared/axios-config/package.json
  $ cd packages/shared/axios-config/package.json
  # No arquivo package.json alterar a tag main para :
  "main": "index.ts",
```

## Como usar o axios nos projetos

```bash
  Dentro do projeto que você deseja usar, como o web, no arquivo package.json adicione:
  "@NOME_DO_PROJETO/axios-config": "*"

  Depois no arquivo que for utilizar importe com:
  import api from '@NOME_DO_PROJETO/axios-config'
```

## Adicionar  jest

  Na raiz do projeto rodar no terminal:
```bash
  $ yarn add @types/jest -DW
```
