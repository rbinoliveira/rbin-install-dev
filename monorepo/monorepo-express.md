# Anotações - Monorepo com Express (Arquitetura Simples)

## Passo 1
criar pasta 
packages > server
e dentro de
packages > server
rodar no terminal:

`yarn init -y`

## Passo 16
Dentro de 
packages > server > package.json
alterar o nome do projeto para 
@NOME_DO_PROJETO/server

## Passo 2
Dentro de
packages > server
criar arquivo 
.gitignore

## Passo 3
Procurar um gitignore para node na internet e colar no arquivo criado acima

## Passo 4
Dentro de
packages > server
rodar no terminal:

`yarn add express`

## Passo 6
Dentro de
packages > server
rodar no terminal:

`yarn tsc --init`

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

## Passo 7
Criar pasta
packages > server > src

## Passo 8
Criar arquivo
packages > server > src > server.ts

## Passo 9
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

## Passo 11
Dentro de 
packages > server
rodar no terminal: 

`yarn add @types/express ts-node-dev -D`

## Passo 12
Dentro de 
packages > server
rodar: 

`yarn add cors`

## Passo 13
Dentro de 
packages > server
rodar: 

`yarn add @types/cors -D`

## Passo 14
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

## Passo 15
Rode a aplicação com

`yarn dev:server`

dentro de 
packages > server
para testar se tudo está ok

## Passo 16
Criar arquivo
packages > server > src > routes > index.ts

## Passo 17
Dentro de
packages > server > src > routes > index.ts
colocar:

```
import { Router } from 'express'

const routes = Router()

routes.get('/', (request, response) =>
  response.json({ message: 'Hello World' })
)

export default routes
```

## Passo 18
Substituir conteúdo de
packages > server > src > server.ts
por:

```
import express from 'express'
import cors from 'cors'
import routes from './routes'

const app = express()

app.use(cors())
app.use(express.json())

app.use(routes)

app.listen(3333, () => {
  console.log('Server stated on port 3333')
})
```

## Passo 19
Criar arquivo
packages > server > ormconfig.json

## Passo 20
Dentro de
packages > server
rodar no terminal

`yarn add typeorm pg`

## Passo 21
Dentro de
packages > server > ormconfig.json
colocar:

```
{
  "type": "postgres",
  "host": "localhost",
  "port": 5432,
  "username": "postgres",
  "password": "docker",
  "database": "dbname"
}
```

## Passo 22:
criar arquivo
packages > server > src > database > index.ts

## Passo 23:
Dentro de
packages > server > src > database > index.ts
colocar:

```
import { createConnection } from 'typeorm'

createConnection()
```

## Passo 24:
Dentro de
packages > server > src > server.ts
adicionar

`import './database'`

após a importação de routes

## Passo 25:
Dentro de
package.json
adicionar dentro do array de nohoist os dois elementos abaixo:

```
"**/typeorm/**",
"**/typeorm"
```

## Passo 26:
Rode o servidor para ver se está tudo ok agora que foi adicionado o banco

## Passo 27:
Criar pasta
packages > server > src > database > migrations

## Passo 28:
Alterar conteúdo de 
packages > server > ormconfig.json para:

```
{
  "type": "postgres",
  "host": "localhost",
  "port": 5432,
  "username": "postgres",
  "password": "docker",
  "database": "sampleprojectdb",
  "entities": ["./src/models/*.ts"],
  "migrations": ["./src/database/migrations/*.ts"],
  "cli": {
    "migrationsDir": "./src/database/migrations"
  }
}
```

# Passo 29:
alterar conteúdo de 
packages > server > tsconfig.json
por:

```
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",                        
    "rootDir": "./src",  
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "strictPropertyInitialization": false
  },
  "include": ["./src/**/*"]
}
```

## Passo 30:
Criar pasta
packages > server > src > models

## Passo 31:
Criar arquivo
packages > server > src > models > User.ts
e dentro colocar:

```
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn
} from 'typeorm'

@Entity('users')
class User {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column()
  name: string

  @Column()
  email: string

  @Column()
  type: string

  @Column('boolean')
  isActive: boolean

  @Column()
  password: string

  @CreateDateColumn()
  created_at: Date

  @UpdateDateColumn()
  updated_at: Date
}

export default User
```

## Passo 32: 
Adicionar scrip em:
packages > server > package.json

vai ficar assim a tag scripts:

```
"scripts": {
  "build": "tsc",
  "dev:server": "ts-node-dev --inspect --transpile-only --ignore-watch node_modules src/server.ts",
  "typeorm": "ts-node-dev ./node_modules/typeorm/cli.js"  
},
```

## Passo 33:
Rodar no terminal em
packages > server

`yarn typeorm migration:create -n CreateUsers`

## Passo 34:
Dentro de
packages > server > src > database > migrations
alterar métodos up e down por:

```
public async up(queryRunner: QueryRunner): Promise<void> {
  await queryRunner.createTable(
    new Table({
      name: 'users',
      columns: [
        {
          name: 'id',
          type: 'uuid',
          isPrimary: true,
          generationStrategy: 'uuid',
          default: 'uuid_generate_v4()'
        },
        {
          name: 'name',
          type: 'varchar',
          isNullable: false
        },
        {
          name: 'email',
          type: 'varchar',
          isNullable: false,
          isUnique: true
        },
        {
          name: 'password',
          type: 'varchar',
          isNullable: false
        },
        {
          name: 'created_at',
          type: 'timestamp',
          default: 'now()'
        },
        {
          name: 'updated_at',
          type: 'timestamp',
          default: 'now()'
        }
      ]
    })
  )
}

public async down(queryRunner: QueryRunner): Promise<void> {
  await queryRunner.dropTable('users')
}
```

## Passo 35
no terminal rodar em
packages > server

`yarn typeorm migration:run`

## Passo 36
no terminal rodar em
packages > server

`yarn add reflect-metadata`

## Passo 37
Adicionar em
packages > server > src > server.ts
no começo do arquivo a linha

`import 'reflect-metadata'`

## Passo 38
Trocar todo o conteúdo de
packages > server > src > routes > index.ts
por:

```
import { Router } from 'express'
import usersRouter from './users.routes'

const routes = Router()
routes.use('/users', usersRouter)

export default routes
```

## Passo 39
Criar arquivo
packages > server > src > routes > users.routes.ts
e dentro colocar:

```
import { Router } from 'express'

import CreateUserService from '../services/CreateUserService'

const usersRouter = Router()

usersRouter.post('/', async (request, response) => {
  try {
    const { name, email, password } = request.body

    const createUser = new CreateUserService()

    const user = await createUser.execute({
      name,
      email,
      password
    })

    delete user.password

    return response.json(user)
  } catch (err) {
    return response.status(400).json({ error: err.message })
  }
})

export default usersRouter
```

## Passo 40
Criar arquivo
packages > server > src > services > CreateUserService.ts
e dentro colocar:

```
import { getRepository } from 'typeorm'

import { hash } from 'bcryptjs'

import User from '../models/User'

interface Request {
  name: string
  email: string
  password: string
}

class CreateUserService {
  public async execute({ name, email, password }: Request): Promise<User> {
    const usersRepository = getRepository(User)

    const checkUserExists = await usersRepository.findOne({
      where: { email }
    })

    if (checkUserExists) {
      throw new Error(
        'E-mail já existente na base de dados, tente outro e-mail.'
      )
    }

    const hashedPassword = await hash(password, 8)

    const user = usersRepository.create({
      name,
      email,
      type: 'common',
      isActive: true,
      password: hashedPassword
    })

    await usersRepository.save(user)

    return user
  }
}

export default CreateUserService
```

## Passo 38
No terminal dentro de
packages > server
rodar dois comandos:

`yarn add bcryptjs`
`yarn add @types/bcryptjs -D`
