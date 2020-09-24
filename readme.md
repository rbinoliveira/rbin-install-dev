# Monorepo

## Passo 1
Rodar no terminal:

```yarn init -y```

## Passo 2
Adicionar em
package.json
a tag:

```"private": "true",```

## Passo 3
Adicionar em
package.json
a tag:

```
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

## Passo 4
Criar pasta
packages

## Passo 5
Criar arquivo
.gitignore

## Passo 6
Dentro de
.gitignore
colocar:

```
node_modules
dist
yarn-error.log
```

## Passo 7
Criar pasta
packages > server

## Passo 8
Dentro de
packages > server
rodar no terminal:

```yarn init -y```

## Passo 9
Dentro de
packages > server
criar arquivo 
.gitignore

## Passo 10
Procurar um gitignore para node na internet e colar no arquivo criado acima

## Passo 11
Dentro de
packages > server
rodar no terminal:

```yarn add express```

## Passo 12
Dentro de
packages > server
rodar no terminal:

```yarn add typescript -D```

## Passo 13
Dentro de
packages > server
rodar no terminal:

```yarn tsc --init```

## Passo 14
Criar pasta
packages > server > src

## Passo 15
Criar arquivo
packages > server > src > server.ts

## Passo 16
Dentro de
packages > server > src > server.ts
colocar:

```
import express from 'express'
import cors from 'cors'

const app = express();

app.use(cors())

app.get("/", (request, response) => {
  return response.json({ message: "Hello World" });
});

app.listen(3333, () => {
  console.log("Server stated on port 3333");
});
```

## Passo 17
Dentro de 
packages > server > tsconfig.json
alterar as seguintes tags para:

```"outDir": "./dist",```

```"rootDir": "./src",```

## Passo 18
Dentro de 
packages > server
rodar no terminal: 

```yarn add @types/express ts-node-dev -D```

## Passo 19
Dentro de 
packages > server
rodar: 

```yarn add cors```

## Passo 20
Dentro de 
packages > server
rodar: 

```yarn add @types/cors -D```

## Passo 21
Dentro de 
packages > server > package.json
adicionar tag:

```
"scripts": {
  "build": "tsc",
  "dev:server": "ts-node-dev --inspect --transpile-only --ignore-watch node_modules src/server.ts"
}, 
```

Obs: é bom digitar manualmente porque copiando dá problema.

## Passo 22
Rode a aplicação com

```yarn dev:server```

dentro de 
packages > server
para testar se tudo está ok

## Passo 23
Dentro de 
packages > server > package.json
alterar o nome do projeto para 
@NOME_DO_PROJETO/server

## Passo 24
Dentro de
packages
rodar no terminal:

```npx create-react-app web --template typescript```

## Passo 25
Dentro de
packages > web
excluir arquivo readme

## Passo 26
Excluir arquivos desnecessários de
packages > web > src
deixando somente os arquivos que aparecem no anexo 1

## Passo 27
Trocar conteúdo de
packages > web > src > index.tsx
por: 

```
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
document.getElementById("root")
);
```

## Passo 28
Trocar conteúdo de
packages > web > src > App.tsx
por:

```
import React from 'react';

const App: React.FC = () => <h1>Projeto vazio</h1>

export default App;
```

## Passo 29
Excluir arquivos desnecessários de
packages > web > public
deixando somente os arquivos que aparecem no anexo 2

## Passo 30
Dentro de 
packages > web > public > index.html
excluir linhas desnecessárias deixando apenas as linhas que aparecem no anexo 3 e a tag description.

## Passo 31
Dentro de 
packages > web > package.json
alterar nome do projeto para
@NOME_DO_PROJETO/web

## Passo 32
Dentro de
packages > web
rodar no terminal:

```yarn start```

para testar a aplicação web

## Passo 33
Dentro de
packages
rodar no terminal:
```npx react-native init mobile --template react-native-template-typescript```

## Passo 34
Usar o buscador do vs code para procurar por

../node_modules

e adicionar 

../../ 

antes das importações para as importações refletirem para o node_modules da raiz do projeto.

Obs: só alterar arquivos que tá dentro da pasta mobile e verificar e somente onde tiver ../node_modules, ficando assim após a alteração:

../../../node_modules

## Passo 35
Dentro de
packages > mobile > metro.config.js
adicionar

```const path = require('path');```

fora do modules.exports

e adicionar

```
projectRoot: path.resolve(__dirname, '.'),
watchFolders: [path.resolve(__dirname, '../../node_modules')],
```

dentro de modules.exports, antes de transformer.

Dica: ver anexo 4 se ficar com dúvidas

## Passo 36
Dentro de 
packages > mobile > ios > Podfile
alterar linha que tem use_react_native para:

```use_react_native!(:path => '../../../node_modules/react-native')```

Obs: basta mudar após path => 

## Passo 37
Alterar o nome do projeto mobile para
@NOME_DO_PROJETO/mobile em
packages > mobile > package.json

## Passo 38
Criar pasta
packages > mobile > src

## Passo 39
Dentro de
packages > mobile > src
criar arquivo
packages > mobile > src > App.tsx

## Passo 40
Dentro de
packages > mobile > src > App.tsx
Colocar:

```
import React from 'react';

import {View} from 'react-native';

const App: React.FC = () => <View style={{flex: 1, backgroundColor: '#000'}} />;

export default App;

```

## Passo 41
Excluir
packages > mobile > App.tsx

## Passo 42
dentro de index trocar a importação de App para:

```import App from './src/App';```

## Passo 43
Dentro de
packages > mobile
rode no terminal:

```yarn android```
```yarn start```

para testar se o mobile está funcionando

## Passo 44
Na raiz do projeto rodar no terminal:

```yarn add typescript -DW```

## Passo 45
Criar pasta
packages > shared > eslint-config

## Passo 46
Dentro de 
packages > shared > eslint-config
rodar no terminal:

```yarn init -y```

## Passo 47
Trocar nome do projeto para
@NOME_DO_PROJETO/eslint-config
em
packages > shared > eslint-config > package.json

## Passo 48
Dentro de
packages > shared > eslint-config
Rodar no terminal os seguintes comandos:

```yarn add @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint eslint-config-prettier -D```

```yarn add eslint-config-standard eslint-import-resolver-typescript eslint-plugin-import -D```

```yarn add eslint-plugin-node eslint-plugin-prettier eslint-plugin-promise eslint-plugin-react -D```

```yarn add eslint-plugin-standard prettier -D```

## Passo 49
Dentro de
packages > shared > eslint-config
rodar no terminal:

`yarn`

## Passo 50
Criar arquivo
Dentro de
packages > eslint-config > .eslintrc.js

## Passo 51
Dentro de
packages > eslint-config > .eslintrc.js
colocar:

```
module.exports = {
  env: {
    browser: true,
    es2020: true,
    node: true,
    jest: true
  },
  extends: [
    'plugin:react/recommended',
    'standard',
    'plugin:@typescript-eslint/recommended',
    'prettier/@typescript-eslint',
    'prettier/standard',
    'prettier/react'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    },
    ecmaVersion: 11,
    sourceType: 'module'
  },
  plugins: ['react', '@typescript-eslint', 'prettier', 'react-hooks'],
  rules: {
    'prettier/prettier': 'error',
    '@typescript-eslint/ban-types': 'off',
    'space-before-function-paren': ['error', 'never'],
    'no-useless-constructor': 'off',
    '@typescript-eslint/no-useless-constructor': ['error'],
    'react/prop-types': 'off',
    'space-before-function-paren': 'off',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    'no-unused-expressions': 'off',
    '@typescript-eslint/interface-name-prefix': [
      'error',
      { 'prefixWithI': 'always' }
    ],
    '@typescript-eslint/no-unused-vars': [
      'error',
      {
        'argsIgnorePattern': '_'
      }
    ],
    '@typescript-eslint/explicit-function-return-type': [
      'error',
      {
        'allowExpressions': true
      }
    ],
  },
  settings: {
    'import/resolver': {
      typescript: {}
    },
    react: {
      version: 'detect'
    }
  }
}
```

## Passo 52
Dentro de
packages > eslint-config > package;json
alterar a tag main para:

```"main": ".eslintrc.js",```

## Passo 53
Criar arquivo
prettier.config.js
na raiz do projeto mesmo

## Passo 54
dentro de
prettier.config.js
colocar:

```
module.exports = {
  semi: false,
  singleQuote: true,
  arrowParens: 'avoid',
  trailingComma: 'none',
  endOfLine: 'auto'
}
```

## Passo 55
Criar arquivo
.eslintrc.js
na raiz do projeto

## Passo 56
Dentro de 
package.json
adicionar na tag devDependecies o projeto eslint-config.
Vai ficar mais ou menos assim:

```
"devDependencies": {
  "typescript": "^4.0.2",
  "@NOME_DO_PROJETO/eslint-config": "*"
}
```

## Passo 57
Na raiz do projeto rodar no terminal:

`yarn`

## Passo 58
Dentro de
.eslintrc.js
colocar:

```
const config = require('@NOME_DO_PROJETO/eslint-config')

module.exports = config
```

## Passo 59
Dentro de
packages > web > package.json
excluir a tag:

```
"eslintConfig": {
  "extends": "react-app"
},
```

## Passo 60
Dentro de
packages > mobile
excluir arquivos .eslintrc.js e prettier.config.js

## Passo 61
Dentro de
packages > mobile > package.json

excluir as seguintes linhas:

```"lint": "eslint . --ext .js,.jsx,.ts,.tsx"```
```"eslint": "^6.5.1",```
```"typescript": "^3.8.3"```
```"prettier": "^2.0.4",```
```"@typescript-eslint/parser": "^2.27.0",```
```"@typescript-eslint/eslint-plugin": "^2.27.0",```
```"@react-native-community/eslint-config": "^1.1.0",```

## Passo 62
Dentro de
packages > mobile
rodar no terminal:

`yarn`

## Passo 63
Criar arquivo
.eslintignore
na raiz do projeto

## Passo 64
Dentro de
.eslintignore
colocar:

```
.eslintrc.js
packages/**/*.js
node_modules
dist
```

## Passo 65
Tente rodar o projeto com yarn start,
provavalmente um problema com compatibilidade de eslint ocorrerá,
então use a versão do eslint que o react-scripts recomenda no projeto eslint-config

altere isso em

packages > shared > eslint-config > package.json

## Passo 66
na raiz do projeto rodar no terminal:

```yarn add @types/jest -DW```

## Passo 67
Dentro de
packages > mobile
remover pasta __tests__
pois por enquanto não configuramos os testes ainda no mobile

## Passo 68
Criar arquivo
tsconfig.json

## Passo 69
Dentro de 
tsconfig.json
adicionar:

```
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

## Passo 70
Dentro de
packages > web > tsconfig.json
alterar todo o conteúdo para:

```
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "lib": ["esnext", "dom"],   
    "allowJs": false,          
    "checkJs": false,         
    "jsx": "react"
  },
  "include": [
    "./src/**/*"
  ]
}
```

## Passo 71
Dentro de
packages > server > tsconfig.json
alterar todo o conteúdo para:

```
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",                        
    "rootDir": "./src",  
  },
  "include": ["./src/**/*"]
}
```

## Passo 72
Dentro de
packages > mobile > tsconfig.json
alterar todo o conteúdo para:

```
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "lib": ["esnext", "dom"],   
    "allowJs": false,          
    "checkJs": false,         
    "jsx": "react-native"
  },
  "include": [
    "./src/**/*"
  ]
}
```

## Passo 73
Criar pasta
packages > shared > axios-config

## Passo 74
Dentro de 
packages > shared > axios-config
rodar no terminal:

```yarn init -y```

## Passo 75
Dentro de 
packages > shared > axios-config > package.json
alterar nome do projeto para
@NOME_DO_PROJETO/axios-config

## Passo 76
Criar arquivo
packages > shared > axios-config > index.ts

## Passo 77
Dentro de 
packages > shared > axios-config > index.ts
colocar:

```
import axios from 'axios'

const api = axios.create({
  baseURL: 'http://localhost:3333'
})

export default api

```

# Passo 78
Dentro de 
packages > shared > axios-config > package.json
alterar tag main para:

```"main": "index.ts",```