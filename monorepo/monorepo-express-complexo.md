# Anotações - Monorepo com Express (Arquitetura Complexa)

## Criar pasta server

  ```bash
    # Abrir pasta packages
    $ cd packages
    # Criar pasta server
    $ mkdir server
    # Execute
    $ yarn init -y
  ```
## Alterar nome do projeto no package.json
  ```bash
    # Dentro de packages/sever
    $ cd packages/server
    # No arquivo package.json altere o nome do projeto para:
    @NOME_DO_PROJETO/server
  ```

## Criar arquivo .gitignore
  ```bash
    # Dentro de packages/sever
    $ cd packages/server
    # Criar arquivo .gitignore
    .gitignore 
  ```

## Procurar um gitignore para node
Site: [gitignore.io](https://www.toptal.com/developers/gitignore)
Colar no arquivo criado acima

## Adcionar express
  ```bash
    # Dentro de packages/server
    $ cd packages/server
    # Execute
    $ yarn add express
  ```
## Criar arquivo tsconfig.json
  ```bash
    # Dentro de packages/server
    $ cd packages/server
    # Execute
    $ yarn tsc --init
  ```


## Alterar conteúdo do tsconfig.json
```bash
  # Dentro de packages/server
  $ cd packages/server

  # Abrir arquivo tsconfing.json e alterar todo o conteúdo para:

  {
    "extends": "../../tsconfig.json",
    "compilerOptions": {
      "outDir": "./dist",                        
      "rootDir": "./src",  
    },
    "include": ["./src/**/*"]
  }
```

## Adicionar elementos no array de nohois
Dentro de package.json

Adicionar dentro do array de nohoist os dois elementos abaixo:

```bash
"**/typeorm/**",
"**/typeorm"
```

## Criar pasta src
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Criar pasta src
  $ mkdir src
```
## Criar arquivo server.ts
```bash
  # Dentro de packages/server/src
  $ cd packages/server/src
  # criar arquivo
  server.ts
```

## Colocando conteúdo dentro do arquivo server.ts
```bash
  # Dentro de packages/server/src
  $ cd packages/server/src

  # Abra arquivo server.ts e coloque:

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

## Adicionar dependêcia
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add @types/express ts-node-dev -D
```

## Adicionar cors
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add cors
```

## Adicionar dependêcia
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add @types/cors -D
```

## Colocar tag no package.json
```bash
  # Dentro de packages/server
  $ cd packages/server

  # Abra arquivo package.json e adicione a tag:

  "scripts": {
    "build": "tsc",
    "dev:server": "ts-node-dev --inspect --transpile-only --ignore-watch node_modules src/server.ts"
  }, 
```
**Obs: é bom digitar manualmente porque copiando dá problema.**

## Rodar a aplicação
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute 
  $ yarn dev:server
```
**Faça isso para testar se tudo está ok**

## Criar pasta module dentro da pasta server/src
```bash
  # Abrir pastas packages/server/src para criar pasta modules
  $ cd packages/server/src
  # Criar pasta modules
  $ mkdir modules
  # Caminho das pastas packages/server/src/modules
```
## Criar pasta users dentro da pasta modules
```bash
  # Abrir pastas packages/server/src/modules para criar a pasta users
  $ cd packages/server/src/modules
  # Criar pasta users
  $ mkdir users
  # Caminho das pastas packages/server/src/modules/users
```
## Criar pasta shared 
```bash
  # Abrir pastas packages/server/src para criar a pasta shared
  $ cd packages/server/src
  # Criar pasta shared
  $ mkdir shared
  # Caminho das pastas packages/server/src/shared
```

## Criar pasta infra dentro da pasta shared
```bash
  # Abrir pastas packages/server/src/shared para criar a pasta infra
  $ cd packages/server/src/shared
  # Criar pasta infra
  $ mkdir infra
  # Caminho das pastas packages/server/src/shared/infra
```

## Criar pasta errors dentro da pasta shared
```bash
  # Abrir pastas packages/server/src/shared para criar pasta errors
  $ cd packages/server/src/shared
  # Criar pasta errors
  $ mkdir errors
  # Caminho das pastas packages/server/src/shared/errors
```

## Criar arquivo AppError.ts dentro da pasta errors
```bash
  # Abrir pastas packages/server/src/shared/errors para criar arquivo AppError.ts
  $ cd packages/server/src/shared/errors
  # Crie o arquivo AppError.ts dentro da pasta errors

  # Dentro do arquivo AppError.ts adicionar:
    class AppError {
      public readonly message: string

      public readonly statusCode: number

      constructor(message: string, statusCode = 400) {
        this.message = message
        this.statusCode = statusCode
      }
    }

    export default AppError
```

## Criar pasta http dentro da pasta infra
```bash
  # Abrir pastas packages/server/src/shared/infra para criar a pasta http
  $ cd packages/server/src/shared/infra
  # Criar pasta http
  $ mkdir http
  # Caminho das pastas packages/server/src/shared/infra/htpp
```
## Mover arquivo server.ts para pasta http
```bash
  # Mova o arquivo server.ts para dentro da pasta http
  # Caminhos das pastas até o arquivo
  # packages/server/src/shared/infra/http/server.ts
```

## Alterar arquivo tsconfig.json

```bash
  # Alterar arquivo tsconfig.json para:

  {
    "extends": "../../tsconfig.json",
    "compilerOptions": {
      "baseUrl": "./src",
      "outDir": "./dist",                        
      "rootDir": "./src",  
      "experimentalDecorators": true,
      "emitDecoratorMetadata": true,
      "strictPropertyInitialization": false,
      "allowJs": true,
      "paths": {
        "@modules/*": ["modules/*"],
        "@config/*": ["config/*"],
        "@shared/*": ["shared/*"]
      }
    },
    "include": ["./src/**/*"]
  }
```

## Adicionar dependência dentro da pasta server
```bash
  # Abrir pastas packages/server
  $ cd packages/server
  # Dentro da pasta server rodar no terminal:
  $ yarn add tsconfig-paths -D
```

## Alterar tags scripts do arquivo package.json
```bash
  # abrir pastas packages/server/package.json para acessar arquivo package.json
  $ cd packages/server/package.json
  # Alterar as tags scripts para:
  "scripts": {
    "build": "tsc",
    "dev:server": "ts-node-dev -r tsconfig-paths/register --inspect --transpile-only --ignore-watch node_modules src/shared/infra/http/server.ts",
    "typeorm": "ts-node-dev -r tsconfig-paths/register ./node_modules/typeorm/cli.js",
    "test": "jest"
  },
```

## Criar pasta infra
```bash
  # Dentro de packages/server/src/modules/users
  $ cd packages/server/src/modules/users
  # Execute
  $ mkdir infra
```
## Criar pasta repositories
```bash
  # Dentro de packages/server/src/modules/users
  $ cd packages/server/src/modules/users
  # Execute
  $ mkdir repositories
```
## Criar pasta services
```bash
  # Dentro de packages/server/src/modules/users
  $ cd packages/server/src/modules/users
  # Execute
  $ mkdir services
```
## Criar pasta dtos
```bash
  # Dentro de packages/server/src/modules/users
  $ cd packages/server/src/modules/users
  # Execute
  $ mkdir dtos
```
## Criar pasta http
```bash
  # Dentro de packages/server/src/modules/users/infra
  $ cd packages/server/src/modules/users/infra
  # Execute
  $ mkdir http
```
## Criar pasta routes
```bash
  # Dentro de packages/server/src/modules/users/infra/http
  $ cd packages/server/src/modules/users/infra/http
  # Execute
  $ mkdir routes
```
## Criar arquivo users.routes.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/routes
  $ cd packages/server/src/modules/users/infra/http/routes

  # Criar arquivo users.routes.ts e dentro colocar:


  import { Router } from 'express'
  import { celebrate, Segments, Joi } from 'celebrate'

  import multer from 'multer'
  import uploadConfig from '@config/upload'

  import UsersController from '../controllers/UsersController'
  import UserAvatarController from '../controllers/UserAvatarController'

  import ensureAuthenticated from '../middlewares/ensureAuthenticated'

  const usersRouter = Router()
  const usersController = new UsersController()
  const userAvatarController = new UserAvatarController()
  const upload = multer(uploadConfig)

  usersRouter.post(
    '/',
    celebrate({
      [Segments.BODY]: {
        name: Joi.string().required(),
        email: Joi.string().email().required(),
        password: Joi.string().required(),
      },
    }),
    usersController.create,
  )

  usersRouter.patch(
    '/avatar',
    ensureAuthenticated,
    upload.single('avatar'),
    userAvatarController.update,
  )

  export default usersRouter
```

## Add celebrate multer
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add celebrate multer
```
## Criar pasta config
```bash
  # Dentro de packages/server/src
  $ cd packages/server/src
  # Execute
  $ mkdir config
```
## Criar arquivo upload.ts
```bash
  # Dentro de packages/server/src/config
  $ cd packages/server/src/config

  # Criar arquivo  upload.ts e dentro colocar: 

  import multer from 'multer'
  import path from 'path'
  import crypto from 'crypto'

  const tmpFolder = path.resolve(__dirname, '..', '..', 'tmp')

  export default {
    tmpFolder,
    uploadsFolder: path.resolve(tmpFolder, 'uploads'),
    storage: multer.diskStorage({
      destination: tmpFolder,
      filename(request, file, callback) {
        const fileHash = crypto.randomBytes(10).toString('hex')
        const filename = `${fileHash}-${file.originalname}`

        return callback(null, filename)
      },
    }),
  }
```

## Criar pasta controllers
```bash
  # Dentro de packages/server/src/modules/users/infra/http
  $ cd packages/server/src/modules/users/infra/http
  # Execute
  $ mkdir controllers
```

## Criar Arquivo UsersController.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/controllers
  $ cd packages/server/src/modules/users/infra/http/controllers

  # Criar arquivo  UsersController.ts e dentro colocar:

  import { Request, Response } from 'express'
  import { container } from 'tsyringe'
  import { classToClass } from 'class-transformer'

  import CreateUserService from '@modules/users/services/CreateUserService'

  export default class UsersController {
    public async create(request: Request, response: Response): Promise<Response> {
      const { name, email, password } = request.body

      const createUser = container.resolve(CreateUserService)

      const user = await createUser.execute({
        name,
        email,
        password,
      })

      delete user.password

      return response.json(classToClass(user))
    }
  }
```

## Criar Arquivo UserAvatarController.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/controllers
  $ cd packages/server/src/modules/users/infra/http/controllers

  # Criar arquivo UserAvatarController.ts e dentro colocar:

  import { Request, Response } from 'express'
  import { container } from 'tsyringe'
  import { classToClass } from 'class-transformer'

  import UpdateUserAvatarService from '@modules/users/services/UpdateUserAvatarService'

  export default class UserAvatarController {
    public async update(request: Request, response: Response): Promise<Response> {
      const updateUserAvatar = container.resolve(UpdateUserAvatarService)

      const user = await updateUserAvatar.execute({
        user_id: request.user.id,
        avatarFilename: request.file.filename,
      })

      delete user.password

      return response.json(classToClass(user))
    }
  }
```

## Add class-transformer tsyringe
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add class-transformer tsyringe
```

## Criar pasta middlewares
```bash
  # Dentro de packages/server/src/modules/users/infra/http
  $ cd packages/server/src/modules/users/infra/http
  # Execute 
  $ mkdir middlewares
```

## Criar arquivo  ensureAuthenticated.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/middlewares
  $ cd packages/server/src/modules/users/infra/http/middlewares

  # Criar arquivo ensureAuthenticated.ts e dentro colocar:

  import { Request, Response, NextFunction } from 'express'
  import { verify } from 'jsonwebtoken'

  import authConfig from '@config/auth'

  import AppError from '@shared/errors/AppError'

  interface TokenPayload {
    iat: number
    exp: number
    sub: string
  }

  export default function ensureAuthenticated(
    request: Request,
    response: Response,
    next: NextFunction,
  ): void {
    const authHeader = request.headers.authorization

    if (!authHeader) {
      throw new AppError('JWT não foi enviado', 401)
    }

    const [, token] = authHeader.split(' ')

    try {
      const decoded = verify(token, authConfig.jwt.secret)

      const { sub } = decoded as TokenPayload

      request.user = { id: sub }

      return next()
    } catch {
      throw new AppError('JWT inválido', 401)
    }
  }
```

## Add jsonwebtoken
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add jsonwebtoken
```

## Criar arquivo auth.ts
```bash
  # Dentro de packages/server/src/config
  $ cd packages/server/src/config

  # Criar arquivo auth.ts e dentro colocar:

  export default {
    jwt: {
      secret: process.env.APP_SECRET || 'default',
      expiresIn: '1d',
    },
  }
```

## Criar arquivo .env
```bash
  # Dentro de packages/server
  $ cd packages/server

  # Criar arquivo .env e dentro colocar:

  APP_SECRET=
  APP_WEB_URL=http://localhost:3000
  APP_API_URL=http://localhost:3333
```

## Criar arquivo .env.example
```bash
  # Dentro de packages/server
  $ cd packages/server

  # Criar arquivo .env.example e dentro colocar:

  APP_SECRET=
  APP_WEB_URL=http://localhost:3000
  APP_API_URL=http://localhost:3333
```

## Add dotenv
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add dotenv
```

## Criar pasta services e arquivo CreateUserService.ts
```bash
  # Dentro de packages/server/src/modules/users
  $ cd packages/server/src/modules/users
  # Execute
  $ mkdir services

  # Criar arquivo CreateUserService.ts e dentro colocar:


  import { injectable, inject } from 'tsyringe'

  import ICacheProvider from '@shared/container/providers/CacheProvider/models/ICacheProvider'

  import AppError from '@shared/errors/AppError'
  import IUsersRepository from '../repositories/IUsersRepository'
  import IHashProvider from '../providers/HashProvider/models/IHashProvider'

  import User from '../infra/typeorm/entities/User'

  interface IRequest {
    name: string
    email: string
    password: string
  }

  @injectable()
  class CreateUserService {
    constructor(
      @inject('UsersRepository')
      private usersRepository: IUsersRepository,

      @inject('HashProvider')
      private hashProvider: IHashProvider,

      @inject('CacheProvider')
      private cacheProvider: ICacheProvider,
    ) {}

    public async execute({ name, email, password }: IRequest): Promise<User> {
      const checkUserExists = await this.usersRepository.findByEmail(email)

      if (checkUserExists) {
        throw new AppError('O e-mail já existe na base de dados')
      }

      const hashedPassword = await this.hashProvider.generateHash(password)

      const user = await this.usersRepository.create({
        name,
        email,
        password: hashedPassword,
      })

      await this.cacheProvider.invalidatePrefix('providers-list')

      return user
    }
  }

  export default CreateUserService
```

## Criar arquivo IUsersRepository.ts
```bash
  # Dentro de packages/server/src/modules/users/repositories
  $ cd  packages/server/src/modules/users/repositories

  # Criar arquivo IUsersRepository.ts e dentro colocar


  import User from '../infra/typeorm/entities/User'
  import ICreateUserDTO from '../dtos/ICreateUserDTO'

  export default interface IUsersRepository {
    findById(id: string): Promise<User | undefined>
    findByEmail(email: string): Promise<User | undefined>
    create(data: ICreateUserDTO): Promise<User>
    save(user: User): Promise<User>
  }
```

## Criar pasta typeorm
```bash
  # Dentro de packages/server/src/modules/users/infra
  $ cd ackages/server/src/modules/users/infra
  # Execute
  $ mkdir typeorm
```

## Criar pasta entities
```bash
  # Dentro de packages/server/src/modules/users/infra/typeorm 
  $ cd ackages/server/src/modules/users/infra/typeorm 
  # Execute
  $ mkdir entities
```

## Criar arquivo User.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/typeorm/entities
  $ cd ackages/server/src/modules/users/infra/typeorm/entities

  # Criar arquivo User.ts e dentro colocar:

  import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    CreateDateColumn,
    UpdateDateColumn,
  } from 'typeorm'

  import { Exclude, Expose } from 'class-transformer'

  @Entity('users')
  class User {
    @PrimaryGeneratedColumn('uuid')
    id: string

    @Column()
    name: string

    @Column()
    email: string

    @Column()
    @Exclude()
    password: string

    @Column()
    avatar: string

    @CreateDateColumn()
    created_at: Date

    @UpdateDateColumn()
    updated_at: Date

    @Expose({ name: 'avatar_url' })
    getAvatarUrl(): string | null {
      return this.avatar
        ? `${process.env.APP_API_URL}/files/${this.avatar}`
        : null
    }
  }

  export default User
```

## Add typeorm pg mongodb
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add typeorm pg mongodb
```

## Criar arquivo ICreateUserDTO.ts
```bash
  # Dentro de packages/server/src/modules/users/dtos
  $ cd packages/server/src/modules/users/dtos

  # Criar arquivo ICreateUserDTO.ts e dentro colocar:

  export default interface ICreateUserDTO {
    name: string
    email: string
    password: string
  }
```

## Criar pasta @types
```bash
  # Dentro de packages/server/src
  $ cd packages/server/src
  # Execute 
  $ mkdir @types
```
## Criar arquivo express.d.ts
```bash
  # Dentro de packages/server/src/@types
  $ cd packages/server/src/@types

  # Criar arquivo express.d.ts e dentro colocar:

  declare namespace Express {
    export interface Request {
      user: {
        id: string
      }
    }
  }
```

## Criar pasta providers
```bash
  # Dentro de packages/server/src/modules/users
  $ cd packages/server/src/modules/users
  # Execute
  $ mkdir providers
```

## Criar arquivo index.ts
```bash
  # Dentro de packages/server/src/modules/users/providers
  $ cd packages/server/src/modules/users/providers

  # Criar arquivo index.ts e dentro colocar: 

  import { container } from 'tsyringe'

  import IHashProvider from './HashProvider/models/IHashProvider'
  import BCryptHashProvider from './HashProvider/implementations/BCryptHashProvider'

  container.registerSingleton<IHashProvider>('HashProvider', BCryptHashProvider)
```

## Criar pasta HashProvider
```bash
  # Dentro de packages/server/src/modules/users/providers
  $ cd packages/server/src/modules/users/providers
  # Execute 
  $ mkdir HashProvider
```

## Criar pasta models
```bash
  # Dentro de packages/server/src/modules/users/providers/HashProvider
  $ cd packages/server/src/modules/users/providers/HashProvider
  # Execute
  $ mkdir models
```

## Criar arquivo IHashProvider.ts
```bash
  # Dentro de packages/server/src/modules/users/providers/HashProvider/models
  $ cd packages/server/src/modules/users/providers/HashProvider/models

  # Criar arquivo IHashProvider.ts e dentro colocar: 

  export default interface IHashProvider {
    generateHash(payload: string): Promise<string>
    compareHash(payload: string, hashed: string): Promise<boolean>
  }
```

## Criar pasta implementations
```bash
  # Dentro de packages/server/src/modules/users/providers/HashProvider
  $ cd packages/server/src/modules/users/providers/HashProvider
  # Execute
  $ mkdir implementations
```

## Criar arquivo BCryptHashProvider.ts
```bash
  # Dentro de packages/server/src/modules/users/providers/HashProvider/implementation
  $ cd packages/server/src/modules/users/providers/HashProvider/implementation

  # Criar arquivo BCryptHashProvider.ts e dentro colocar: 

  import { hash, compare } from 'bcryptjs'
  import IHashProvider from '../models/IHashProvider'

  export default class BCryptHashProvider implements IHashProvider {
    public async generateHash(payload: string): Promise<string> {
      return hash(payload, 8)
    }

    public async compareHash(payload: string, hashed: string): Promise<boolean> {
      return compare(payload, hashed)
    }
  }
```

## Add bcryptjs
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute
  $ yarn add bcryptjs
```

## Criar arquivo UpdateUserAvatarService.ts
```bash
  # Dentro de packages/server/src/modules/users/services
  $ cd packages/server/src/modules/users/services

  # Criar arquivo UpdateUserAvatarService.ts e dentro colocar: 

  import { injectable, inject } from 'tsyringe'

  import AppError from '@shared/errors/AppError'

  import IStorageProvider from '@shared/container/providers/StorageProvider/models/IStorageProvider'
  import IUsersRepository from '../repositories/IUsersRepository'

  import User from '../infra/typeorm/entities/User'

  interface IRequest {
    user_id: string
    avatarFilename: string
  }

  @injectable()
  class UpdateAvatarUserService {
    constructor(
      @inject('UsersRepository')
      private usersRepository: IUsersRepository,

      @inject('StorageProvider')
      private storageProvider: IStorageProvider,
    ) {}

    public async execute({ user_id, avatarFilename }: IRequest): Promise<User> {
      const user = await this.usersRepository.findById(user_id)

      if (!user) {
        throw new AppError(
          'Somente usuários autenticados podem trocar a foto',
          401,
        )
      }

      if (user.avatar) {
        await this.storageProvider.deleteFile(user.avatar)
      }

      const filename = await this.storageProvider.saveFile(avatarFilename)

      user.avatar = filename

      await this.usersRepository.save(user)

      return user
    }
  }

  export default UpdateAvatarUserService
```

## Criar pasta container
```bash
  # Dentro de packages/server/src/shared
  $ cd packages/server/src/shared
  # Execute
  $ mkdir container
```

## Criar arquivo index.ts
```bash
  # Dentro de packages/server/src/shared/container
  $ cd packages/server/src/shared/container

  # Criar arquivo index.ts e dentro colocar: 

  import { container } from 'tsyringe'

  import '@modules/users/providers'
  import './providers'

  import IUsersRepository from '@modules/users/repositories/IUsersRepository'
  import UsersRepository from '@modules/users/infra/typeorm/repositories/UsersRepository'

  import IUserTokensRepository from '@modules/users/repositories/IUserTokensRepository'
  import UserTokensRepository from '@modules/users/infra/typeorm/repositories/UserTokensRepository'

  import INotificationsRepository from '@modules/notifications/repositories/INotificationsRepository'
  import NotificationsRepository from '@modules/notifications/infra/typeorm/repositories/NotificationsRepository'

  container.registerSingleton<IUsersRepository>(
    'UsersRepository',
    UsersRepository,
  )

  container.registerSingleton<IUserTokensRepository>(
    'UserTokensRepository',
    UserTokensRepository,
  )

  container.registerSingleton<INotificationsRepository>(
    'NotificationsRepository',
    NotificationsRepository,
  )
```

## Criar pasta providers
```bash
  # Dentro de packages/server/src/shared/container
  $ cd packages/server/src/shared/container
  # Execute
  $ mkdir providers
```

## Criar arquivo index.ts
```bash
  # Dentro de packages/server/src/shared/container/providers
  $ cd packages/server/src/shared/container/providers

  # Criar arquivo index.ts e dentro colocar: 

  import './StorageProvider'
```

## Criar pasta StorageProvider
```bash
  # Dentro de packages/server/src/shared/container/providers
  $ cd packages/server/src/shared/container/providers
  # Execute 
  $ mkdir StorageProvider
```

## Criar arquivo index.ts
```bash
  # Dentro de packages/server/src/shared/container/providers/StorageProvider
  $ cd packages/server/src/shared/container/providers/StorageProvider

  # Criar arquivo index.ts e dentro colocar: 

  import { container } from 'tsyringe'

  import IStorageProvider from './models/IStorageProvider'
  import DiskStorageProvider from './implementations/DiskStorageProvider'

  container.registerSingleton<IStorageProvider>(
    'StorageProvider',
    DiskStorageProvider
  )
```

## Criar pasta models
```bash
  # Dentro de packages/server/src/shared/container/providers/StorageProvider
  $ cd packages/server/src/shared/container/providers/StorageProvider
  # Execute
  $ mkdir models
```

## Criar arquivo IStorageProvider.ts
```bash
  # Dentro de packages/server/src/shared/container/providers/StorageProvider/models
  $ cd packages/server/src/shared/container/providers/StorageProvider/models

  # Criar arquivo IStorageProvider.ts e dentro colocar: 

  export default interface IStorageProvider {
    saveFile(file: string): Promise<string>
    deleteFile(file: string): Promise<void>
  }
```

## Criar pasta implementations
```bash
  # Dentro de packages/server/src/shared/container/providers/StorageProvider
  $ cd packages/server/src/shared/container/providers/StorageProvider
  # Execute
  $ mkdir implementations
```

## Criar arquivo DiskStorageProvider.ts
```bash
  # Dentro de packages/server/src/shared/container/providers/StorageProvider/implementations
  $ cd packages/server/src/shared/container/providers/StorageProvider/implementations

  # Criar arquivo DiskStorageProvider.ts e dentro colocar: 

  import fs from 'fs'
  import path from 'path'
  import uploadConfig from '@config/upload'
  import IStorageProvider from '../models/IStorageProvider'

  class DiskStorageProvider implements IStorageProvider {
    public async saveFile(file: string): Promise<string> {
      await fs.promises.rename(
        path.resolve(uploadConfig.tmpFolder, file),
        path.resolve(uploadConfig.uploadsFolder, file),
      )

      return file
    }

    public async deleteFile(file: string): Promise<void> {
      const filePath = path.resolve(uploadConfig.uploadsFolder, file)

      try {
        await fs.promises.stat(filePath)
      } catch {
        return
      }

      await fs.promises.unlink(filePath)
    }
  }

  export default DiskStorageProvider
```

## Criar pasta repositories
```bash
  # Dentro de packages/server/src/modules/users/infra/typeorm 
  $ cd packages/server/src/modules/users/infra/typeorm 
  # Execute
  $ mkdir repositories
```

## Criar arquivo UsersRepository.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/typeorm/repositories
  $ cd packages/server/src/modules/users/infra/typeorm/repositories

  # Criar arquivo UsersRepository.ts e dentro colocar: 

  import { getRepository, Repository } from 'typeorm'

  import IUsersRepository from '@modules/users/repositories/IUsersRepository'
  import ICreateUserDTO from '@modules/users/dtos/ICreateUserDTO'

  import User from '@modules/users/infra/typeorm/entities/User'

  class UsersRepository implements IUsersRepository {
    private ormRepository: Repository<User>

    constructor() {
      this.ormRepository = getRepository(User)
    }

    public async findById(id: string): Promise<User | undefined> {
      const user = await this.ormRepository.findOne(id)

      return user
    }

    public async findByEmail(email: string): Promise<User | undefined> {
      const user = await this.ormRepository.findOne({ where: { email } })

      return user
    }

    public async create(userData: ICreateUserDTO): Promise<User> {
      const user = this.ormRepository.create(userData)

      await this.ormRepository.save(user)

      return user
    }

    public async save(user: User): Promise<User> {
      return this.ormRepository.save(user)
    }
  }

  export default UsersRepository
```

## Criar arquivo UserTokensRepository.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/typeorm/repositories
  $ cd packages/server/src/modules/users/infra/typeorm/repositories

  # Criar arquivo UserTokensRepository.ts e dentro colocar: 

  import { getRepository, Repository } from 'typeorm'

  import IUserTokensRepository from '@modules/users/repositories/IUserTokensRepository'

  import UserToken from '@modules/users/infra/typeorm/entities/UserToken'

  class UserTokensRepository implements IUserTokensRepository {
    private ormRepository: Repository<UserToken>

    constructor() {
      this.ormRepository = getRepository(UserToken)
    }

    public async findByToken(token: string): Promise<UserToken | undefined> {
      const userToken = await this.ormRepository.findOne({
        where: { token },
      })

      return userToken
    }

    public async generate(user_id: string): Promise<UserToken> {
      const userToken = this.ormRepository.create({ user_id })

      await this.ormRepository.save(userToken)

      return userToken
    }
  }

  export default UserTokensRepository
```

## Criar arquivo UserToken.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/typeorm/entities
  $ cd packages/server/src/modules/users/infra/typeorm/entities

  # Criar arquivo UserToken.ts e dentro colocar: 

  import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    CreateDateColumn,
    UpdateDateColumn,
    Generated,
  } from 'typeorm'

  @Entity('user_tokens')
  class UserToken {
    @PrimaryGeneratedColumn('uuid')
    id: string

    @Column()
    @Generated('uuid')
    token: string

    @Column()
    user_id: string

    @CreateDateColumn()
    created_at: Date

    @UpdateDateColumn()
    updated_at: Date
  }

  export default UserToken
```

## Criar arquivo IUserTokensRepository.ts
```bash
  # Dentro de packages/server/src/modules/users/repositories
  $ cd packages/server/src/modules/users/repositories

  # Criar arquivo IUserTokensRepository.ts e dentro colocar: 

  import UserToken from '../infra/typeorm/entities/UserToken'

  export default interface IUserTokensRepository {
    generate(user_id: string): Promise<UserToken>
    findByToken(token: string): Promise<UserToken | undefined>
  }
```

## Criar pasta notifications
```bash
  # Dentro de packages/server/src/modules 
  $ cd packages/server/src/modules
  # Execute
  $ mkdir notifications
```

## Criar pasta repositories
```bash
  # Dentro de packages/server/src/modules/notifications 
  $ cd packages/server/src/modules/notifications
  # Execute
  $ mkdir repositories
```

## Criar arquivo INotificationsRepository.ts
```bash
  # Dentro de packages/server/src/modules/notifications/repositories 
  $ cd packages/server/src/modules/notifications/repositories

  # Criar arquivo INotificationsRepository.ts e dentro colocar: 

  import ICreateNotificationDTO from '../dtos/ICreateNotificationDTO'
  import Notification from '../infra/typeorm/schemas/Notification'

  export default interface INotificationsRepository {
    create(data: ICreateNotificationDTO): Promise<Notification>
  }
```

## Criar pasta infra
```bash
  # Dentro de packages/server/src/modules/notifications 
  $ cd packages/server/src/modules/notifications 
  # Execute
  $ mkdir infra
```

## Criar pasta typeorm
```bash
  # Dentro de packages/server/src/modules/notifications/infra 
  $ cd packages/server/src/modules/notifications/infra
  # Execute
  $ mkdir typeorm
```

## Criar pasta repositories
```bash
  # Dentro de packages/server/src/modules/notifications/infra/typeorm 
  $ cd packages/server/src/modules/notifications/infra/typeorm
  # Execute 
  $ mkdir repositories
```

## Criar arquivo NotificationsRepository.ts
```bash
  # Dentro de packages/server/src/modules/notifications/infra/typeorm/repositories
  $ cd packages/server/src/modules/notifications/infra/typeorm/repositories

  # Criar arquivo NotificationsRepository.ts e dentro colocar:

  import { getMongoRepository, MongoRepository } from 'typeorm'

  import INotificationsRepository from '@modules/notifications/repositories/INotificationsRepository'
  import ICreateNotificationDTO from '@modules/notifications/dtos/ICreateNotificationDTO'

  import Notification from '@modules/notifications/infra/typeorm/schemas/Notification'

  class NotificationsRepository implements INotificationsRepository {
    private ormRepository: MongoRepository<Notification>

    constructor() {
      this.ormRepository = getMongoRepository(Notification, 'mongo')
    }

    public async create({
      content,
      recipient_id,
    }: ICreateNotificationDTO): Promise<Notification> {
      const notification = this.ormRepository.create({
        content,
        recipient_id,
      })

      await this.ormRepository.save(notification)

      return notification
    }
  }

  export default NotificationsRepository
```

## Criar pasta schemas
```bash
  # Dentro de packages/server/src/modules/notifications/infra/typeorm
  $ cd packages/server/src/modules/notifications/infra/typeorm
  # Execute
  $ mkdir schemas
```

## Criar arquivo Notification.ts
```bash
  # Dentro de packages/server/src/modules/notifications/infra/typeorm/schemas
  $ cd packages/server/src/modules/notifications/infra/typeorm/schemas

  # Criar arquivo Notification.ts e dentro colocar:

  import {
    ObjectID,
    Entity,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ObjectIdColumn,
  } from 'typeorm'

  @Entity('notifications')
  class Notification {
    @ObjectIdColumn()
    id: ObjectID

    @Column()
    content: string

    @Column('uuid')
    recipient_id: string

    @Column({ default: false })
    read: boolean

    @CreateDateColumn()
    created_at: Date

    @UpdateDateColumn()
    updated_at: Date
  }

  export default Notification
```

## Criar pasta dtos
```bash
  # Dentro de packages/server/src/modules/notifications
  $ cd packages/server/src/modules/notifications
  # Execute 
  $ mkdir dtos
```

## Criar arquivo ICreateNotificationDTO.ts
```bash
  # Dentro de packages/server/src/modules/notifications/dtos
  $ cd packages/server/src/modules/notifications/dtos

  # Criar arquivo ICreateNotificationDTO.ts e dentro colocar:

  export default interface ICreateNotificationDTO {
    content: string
    recipient_id: string
  }
```

## Criar pasta routes
```bash
  # Dentro de packages/server/src/shared/infra/http 
  $ cd packages/server/src/shared/infra/http 
  # Execute
  $ mkdir routes
```

## Criar arquivo index.ts
```bash
  # Dentro de packages/server/src/shared/infra/http/routes 
  $ cd packages/server/src/shared/infra/http/routes

  # Criar arquivo index.ts e dentro colocar:

  import { Router } from 'express'

  import usersRouter from '@modules/users/infra/http/routes/users.routes'
  import sessionsRouter from '@modules/users/infra/http/routes/sessions.routes'
  import passwordRouter from '@modules/users/infra/http/routes/password.routes'
  import profileRouter from '@modules/users/infra/http/routes/profile.routes'

  const routes = Router()

  routes.use('/users', usersRouter)
  routes.use('/sessions', sessionsRouter)
  routes.use('/password', passwordRouter)
  routes.use('/profile', profileRouter)

  export default routes
```

## Substituir conteúdo de server.ts
```bash
  # Dentro de packages/server/src/shared/infra/http
  $ cd packages/server/src/shared/infra/http

  # Substituir conteúdo de server.ts por: 

  import 'reflect-metadata'
  import 'dotenv/config'

  import express, { Request, Response, NextFunction } from 'express'
  import cors from 'cors'
  import { errors } from 'celebrate'
  import 'express-async-errors'

  import uploadConfig from '@config/upload'
  import AppError from '@shared/errors/AppError'
  import routes from './routes'

  import '@shared/infra/typeorm'
  import '@shared/container'

  const app = express()

  app.use(cors())
  app.use(express.json())
  app.use('/files', express.static(uploadConfig.uploadsFolder))
  app.use(routes)

  app.use(errors())

  app.use((err: Error, request: Request, response: Response, _: NextFunction) => {
    if (err instanceof AppError) {
      return response.status(err.statusCode).json({
        status: 'error',
        message: err.message
      })
    }

    console.error(err)

    return response.status(500).json({
      status: 'error',
      message: 'Internal server error'
    })
  })

  app.listen(3333, () => {
    console.log('Server stated on port 3333')
  })
```

## Criar arquivo sessions.routes.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/routes 
  $ cd packages/server/src/modules/users/infra/http/routes

  # Criar arquivo sessions.routes.ts e dentro colocar:

  import { Router } from 'express'
  import { celebrate, Segments, Joi } from 'celebrate'

  import SessionsController from '../controllers/SessionsController'

  const sessionsRouter = Router()
  const sessionsController = new SessionsController()

  sessionsRouter.post(
    '/',
    celebrate({
      [Segments.BODY]: {
        email: Joi.string().email().required(),
        password: Joi.string().required(),
      },
    }),
    sessionsController.create,
  )

  export default sessionsRouter
```

## Criar arquivo SessionsController.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/controllers
  $ cd packages/server/src/modules/users/infra/http/controllers

  # Criar arquivo SessionsController.ts e dentro colocar:

  import { Request, Response } from 'express'
  import { container } from 'tsyringe'
  import { classToClass } from 'class-transformer'

  import AuthenticateUserService from '@modules/users/services/AuthenticateUserService'

  export default class SessionsController {
    public async create(request: Request, response: Response): Promise<Response> {
      const { email, password } = request.body

      const authenticateUser = container.resolve(AuthenticateUserService)

      const { user, token } = await authenticateUser.execute({
        email,
        password,
      })

      return response.json({ user: classToClass(user), token })
    }
  }
```

## Criar arquivo AuthenticateUserService.ts
```bash
  # Dentro de packages/server/src/modules/users/services 
  $ cd packages/server/src/modules/users/services 

  # Criar arquivo AuthenticateUserService.ts e dentro colocar:

  import { sign } from 'jsonwebtoken'
  import authConfig from '@config/auth'
  import { injectable, inject } from 'tsyringe'

  import AppError from '@shared/errors/AppError'
  import IHashProvider from '../providers/HashProvider/models/IHashProvider'
  import IUsersRepository from '../repositories/IUsersRepository'

  import User from '../infra/typeorm/entities/User'

  interface IRequest {
    email: string
    password: string
  }

  interface IResponse {
    user: User
    token: string
  }

  @injectable()
  class AuthenticateUserService {
    constructor(
      @inject('UsersRepository')
      private usersRepository: IUsersRepository,

      @inject('HashProvider')
      private hashProvider: IHashProvider,
    ) {}

    public async execute({ email, password }: IRequest): Promise<IResponse> {
      const user = await this.usersRepository.findByEmail(email)

      if (!user) {
        throw new AppError('E-mail ou senha inválidos', 401)
      }

      const passwordMatched = await this.hashProvider.compareHash(
        password,
        user.password,
      )

      if (!passwordMatched) {
        throw new AppError('E-mail ou senha inválidos', 401)
      }

      const { secret, expiresIn } = authConfig.jwt

      const token = sign({}, secret, {
        subject: user.id,
        expiresIn,
      })

      return { user, token }
    }
  }

  export default AuthenticateUserService
``` 

## Criar arquivo password.routes.ts dentro da pasta routes
```bash
  # Abrir pastas packages/server/src/modules/users/infra/http/routes
  $ cd packages/server/src/modules/users/infra/http/routes
  # Dentro da pasta routes criar o arquivo password.routes.ts
  # Caminho das pastas ate o arquivo packages/server/src/modules/users/infra/http/routes/password.routes.ts
  # Dentro do arquivo password.routes.ts adicionar:

  import { Router } from 'express'
  import { celebrate, Segments, Joi } from 'celebrate'

  import ForgotPasswordController from '../controllers/ForgotPasswordController'
  import ResetPasswordController from '../controllers/ResetPasswordController'

  const passwordRouter = Router()
  const forgotPasswordController = new ForgotPasswordController()
  const resetPasswordController = new ResetPasswordController()

  passwordRouter.post(
    '/forgot',
    celebrate({
      [Segments.BODY]: {
        email: Joi.string().email().required(),
      },
    }),
    forgotPasswordController.create,
  )
  passwordRouter.post(
    '/reset',
    celebrate({
      [Segments.BODY]: {
        token: Joi.string().uuid().required(),
        password: Joi.string().required(),
        password_confirmation: Joi.string().required().valid(Joi.ref('password')),
      },
    }),
    resetPasswordController.create,
  )

  export default passwordRouter
```

## Criar arquivo ForgotPasswordController.ts dentro da pasta controllers
```bash
  # Abrir pastas packages/server/src/modules/users/infra/http/controllers
  $ cd packages/server/src/modules/users/infra/http/controllers
  # Criar arquivo ForgotPasswordController.ts dentro da pasta controllers
  # Caminho das pastas até o arquivo packages/server/src/modules/users/infra/http/controllers/ForgotPasswordController.ts
  # Dentro do arquivo ForgotPasswordController.ts adicionar:

  import { Request, Response } from 'express'
  import { container } from 'tsyringe'

  import SendForgotPasswordEmailService from '@modules/users/services/SendForgotPasswordEmailService'

  export default class ForgotPasswordController {
    public async create(request: Request, response: Response): Promise<Response> {
      const { email } = request.body

      const sendForgotPasswordEmail = container.resolve(
        SendForgotPasswordEmailService,
      )

      await sendForgotPasswordEmail.execute({
        email,
      })

      return response.status(204).json()
    }
  }
```

## Criar arquivo ResetPasswordController.ts dentro da pasta controllers
```bash
  # Abrir pastas packages/server/src/modules/infra/http/controllers
  $ cd packages/server/src/modules/infra/http/controllers
  # Criar arquivo ResetPasswordController.ts dentro da pasta controllers
  # Caminho das pastas até o arquivo packages/server/src/modules/infra/http/controllers/ResetPasswordController.ts
  # Dentro do arquivo ResetPasswordController.ts adicionar:

  import { Request, Response } from 'express'
  import { container } from 'tsyringe'

  import ResetPasswordService from '@modules/users/services/ResetPasswordService'

  export default class ResetPasswordController {
    public async create(request: Request, response: Response): Promise<Response> {
      const { password, token } = request.body

      const resetPassword = container.resolve(ResetPasswordService)

      await resetPassword.execute({
        token,
        password,
      })

      return response.status(204).json()
    }
  }
```

## Criar arquivo SendForgotPasswordEmailService.ts
```bash
  # Abrir pastas packages/server/src/modules/users/services
  $ cd packages/server/src/modules/users/services
  # Criar o arquivo SendForgotPasswordEmailService.ts dentro da pasta service
  # Caminho das pastas até o arquivo packages/server/src/modules/users/services/SendForgotPasswordEmailService.ts
  # Dentro do arquivo SendForgotPasswordEmailService.ts adicionar:

  import { injectable, inject } from 'tsyringe'
  import path from 'path'

  import AppError from '@shared/errors/AppError'
  import IMailProvider from '@shared/container/providers/MailProvider/models/IMailProvider'
  import IUsersRepository from '../repositories/IUsersRepository'
  import IUserTokensRepository from '../repositories/IUserTokensRepository'

  interface IRequest {
    email: string
  }

  @injectable()
  class SendForgotPasswordEmailService {
    constructor(
      @inject('UsersRepository')
      private usersRepository: IUsersRepository,

      @inject('MailProvider')
      private mailProvieder: IMailProvider,

      @inject('UserTokensRepository')
      private userTokensRepository: IUserTokensRepository,
    ) {}

    public async execute({ email }: IRequest): Promise<void> {
      const user = await this.usersRepository.findByEmail(email)

      if (!user) {
        throw new AppError('Usuário não existe')
      }

      const { token } = await this.userTokensRepository.generate(user.id)

      const forgotPasswordTemplate = path.resolve(
        __dirname,
        '..',
        'views',
        'forgot_password.hbs',
      )

      await this.mailProvieder.sendMail({
        to: {
          name: user.name,
          email: user.email,
        },
        subject: '[Equipe x] Recuperação de senha',
        templateData: {
          file: forgotPasswordTemplate,
          variables: {
            name: user.name,
            link: `${process.env.APP_WEB_URL}/reset-password?token=${token}`,
          },
        },
      })
    }
  }

  export default SendForgotPasswordEmailService
```

## Criar arquivo ResetPasswordService.ts dentro da pasta service
```bash
  # Abrir pastas packages/server/src/modules/users/service
  $ cd packages/server/src/modules/users/service
  # Criar arquivo ResetPasswordService.ts dentro da pasta service
  # Caminho das pastas até o arquivo packages/server/src/modules/users/service/ResetPasswordService.ts
  # Dentro do arquivo ResetPasswordService.ts adicionar:

  import { injectable, inject } from 'tsyringe'
  import { isAfter, addHours } from 'date-fns'

  import AppError from '@shared/errors/AppError'
  import IUsersRepository from '../repositories/IUsersRepository'
  import IUserTokensRepository from '../repositories/IUserTokensRepository'
  import IHashProvider from '../providers/HashProvider/models/IHashProvider'

  interface IRequest {
    password: string
    token: string
  }

  @injectable()
  class ResetPasswordService {
    constructor(
      @inject('UsersRepository')
      private usersRepository: IUsersRepository,

      @inject('UserTokensRepository')
      private userTokensRepository: IUserTokensRepository,

      @inject('HashProvider')
      private hashProvider: IHashProvider,
    ) {}

    public async execute({ token, password }: IRequest): Promise<void> {
      const userToken = await this.userTokensRepository.findByToken(token)

      if (!userToken) {
        throw new AppError('Token de usuário inexistente')
      }

      const user = await this.usersRepository.findById(userToken.user_id)

      if (!user) {
        throw new AppError('Usuário não existente')
      }

      const tokenCreatedAt = userToken.created_at
      const compareDate = addHours(tokenCreatedAt, 2)

      if (isAfter(Date.now(), compareDate)) {
        throw new AppError('Token expirado')
      }

      user.password = await this.hashProvider.generateHash(password)

      await this.usersRepository.save(user)
    }
  }

  export default ResetPasswordService
```

## Adicionar dependencia dentro de server 
```bash
  # Abrir pastas packages/server
  $ cd packages/server
  # Rodar no terminal dentro da pasta server:
  $ yarn add date-fns express-async-errors
```

## Criar pasta MailProvider
```bash
  # Abrir pastas packages/server/src/shared/container/providers
  $ cd packages/server/src/shared/container/providers
  # Criar pasta MailProvider
  $ mkdir MailProvider
  # Caminho das pastas packages/server/src/shared/container/providers/MailProvider
```
## Criar arquivo index.ts dentro da pasta MailProvider
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailProvider
  $ cd packages/server/src/shared/container/providers/MailProvider
  # Criar arquivo index.ts dentro da pasta MailProvider
  # Caminho das pastas até o arquivo packages/server/src/shared/container/providers/MailProvider/index.ts
  # Dentro do arquivo index.ts adicionar:

  import { container } from 'tsyringe'

  import IMailProvider from './models/IMailProvider'
  import EtherealMailProvider from './implementations/EtherealMailProvider'

  container.registerInstance<IMailProvider>(
    'MailProvider',
    container.resolve(EtherealMailProvider)
  )
```

## Criar pasta models 
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailProvider
  $ cd packages/server/src/shared/container/providers/MailProvider
  # Criar pasta models
  $ mkdir models
  # Caminho das pastas packages/server/src/shared/container/providers/MailProvider/models
```
## Criar arquivo IMailProvider.ts dentro da pasta models
```bash
   # Abrir pastas packages/server/src/shared/container/providers/MailProvider/models
   $ cd packages/server/src/shared/container/providers/MailProvider/models
   # Criar arquivo IMailProvider.ts dentro da pasta models
   # Caminho das pastas até o arquivo packages/server/src/shared/container/providers/MailProvider/models/IMailProvider.ts
   # Dentro do arquivo IMailProvider.ts adicionar:

  import ISendMailDTO from '../dtos/ISendMailDTO'

  export default interface IMailProvider {
    sendMail(data: ISendMailDTO): Promise<void>
  }
```

## Criar pasta implementations
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailProvider
  $ cd packages/server/src/shared/container/providers/MailProvider
  # Criar pasta implementations 
  $ mkdir implementations
  # Caminho das pastas packages/server/src/shared/container/providers/MailProvider/implementations
```
## Criar arquivo EtherealMailProvider.ts dentro da pasta implementations
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailProvider/implementations
  $ cd packages/server/src/shared/container/providers/MailProvider/implementations
  # Criar arquivo EtherealMailProvider.ts dentro da pasta implementations
  # Caminho das pastas até o arquivo packages/server/src/shared/container/providers/MailProvider/implementations/EtherealMailProvider.ts
  # Dentro do arquivo EtherealMailProvider.ts adicionar:

  import nodemailer, { Transporter } from 'nodemailer'
  import { inject, injectable } from 'tsyringe'

  import IMailTemplateProvider from '@shared/container/providers/MailTemplateProvider/models/IMailTemplateProvider'
  import IMailProvider from '../models/IMailProvider'
  import ISendMailDTO from '../dtos/ISendMailDTO'

  @injectable()
  export default class EtherealMailProvider implements IMailProvider {
    private client: Transporter

    constructor(
      @inject('MailTemplateProvider')
      private mailTemplateProvider: IMailTemplateProvider
    ) {
      nodemailer.createTestAccount().then(account => {
        const transporter = nodemailer.createTransport({
          host: account.smtp.host,
          port: account.smtp.port,
          secure: account.smtp.secure,
          auth: {
            user: account.user,
            pass: account.pass
          }
        })

        this.client = transporter
      })
    }

    public async sendMail({
      to,
      from,
      subject,
      templateData
    }: ISendMailDTO): Promise<void> {
      const message = await this.client.sendMail({
        from: {
          name: from?.name || 'Equipe X',
          address: from?.email || 'equipe@x.com.br'
        },
        to: {
          name: to.name,
          address: to.email
        },
        subject,
        html: await this.mailTemplateProvider.parse(templateData)
      })

      console.log('Message sent: %s', message.messageId)
      console.log('Preview URL: %s', nodemailer.getTestMessageUrl(message))
    }
  }
```


## Criar pasta dtos
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailProvider
  $ cd packages/server/src/shared/container/providers/MailProvider
  # Criar pasta dtos
  $ mkdir dtos
  # Caminho das pastas packages/server/src/shared/container/providers/MailProvider/dtos
```
## Criar arquivo ISendMailDTO.ts dentro da pasta dtos
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailProvider/dtos
  $ cd packages/server/src/shared/container/providers/MailProvider/dtos
  # Criar arquivo ISendMailDTO.ts dentro da pasta dtos
  # Caminho das pastas até o arquivo packages/server/src/shared/container/providers/MailProvider/dtos/ISendMailDTO.ts
  # Dentro do arquivo ISendMailDTO.ts adicionar:

  import IParseMailTemplateDTO from '@shared/container/providers/MailTemplateProvider/dtos/IParseMailTemplateDTO'

  interface IMailContact {
    name: string
    email: string
  }

  export default interface ISendMailDTO {
    to: IMailContact
    from?: IMailContact
    subject: string
    templateData: IParseMailTemplateDTO
  }
```

## Criar pasta MailTemplateProvider 
```bash
  # Abrir pastas packages/server/src/shared/container/providers
  $ cd packages/server/src/shared/container/providers
  # Criar pasta MailTemplateProvider
  $ mkdir MailTemplateProvider
  # Caminho das pastas packages/server/src/shared/container/providers/MailTemplateProvider
```
## Criar arquivo index.ts dentro da pasta MailTemplateProvider
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailTemplateProvider
  $ cd packages/server/src/shared/container/providers/MailTemplateProvider
  # Criar arquivo index.ts dentro da pasta MailTemplateProvider
  # caminho das pastas até o arquivo packages/server/src/shared/container/providers/MailTemplateProvider/index.ts
  # Dentro do arquivo index.ts adicionar:

  import { container } from 'tsyringe'

  import IMailTemplateProvider from './models/IMailTemplateProvider'
  import HandlebarsMailTemplateProvider from './implementations/HandlebarsMailTemplateProvider'

  container.registerSingleton<IMailTemplateProvider>(
    'MailTemplateProvider',
    HandlebarsMailTemplateProvider
  )
```

## Criar pasta models dentro da pasta MailTemplateProvider
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailTemplateProvider
  $ cd packages/server/src/shared/container/providers/MailTemplateProvider
  # Criar pasta models
  $ mkdir models
  # Caminho das pastas packages/server/src/shared/container/providers/MailTemplateProvider/models
```
## Criar arquivo IMailTemplateProvider.ts dentro da pasta models
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailTemplateProvider/models
  $ cd packages/server/src/shared/container/providers/MailTemplateProvider/models
  # Criar arquivo IMailTemplateProvider.ts dentro da pasta models
  # Caminho das pastas até o arquivo packages/server/src/shared/container/providers/MailTemplateProvider/models/IMailTemplateProvider.ts
  # Dentro do arquivo IMailTemplateProvider.ts adicionar:

  import IParseMailTemplateDTO from '../dtos/IParseMailTemplateDTO'

  export default interface IMailTemplateProvider {
    parse(data: IParseMailTemplateDTO): Promise<string>
  }
```

## Criar pasta implementations dentro da pasta MailTemplateProvider
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailTemplateProvider
  $ cd packages/server/src/shared/container/providers/MailTemplateProvider
  # Criar pasta implementations
  $ mkdir implementations
  # Caminho das pastas packages/server/src/shared/container/providers/MailTemplateProvider/implementations
```

## Criar arquivo HandlebarsMailTemplateProvider.ts dentro da pasta implementations
```bash
  # Abrir pastas packages/server/src/shared/container/providers/MailTemplateProvider/implementations
  $ cd  packages/server/src/shared/container/providers/MailTemplateProvider/implementations
  # Criar arquivo HandlebarsMailTemplateProvider.ts dentro da pasta implementations
  # caminho das pastas até o arquivo packages/server/src/shared/container/providers/MailTemplateProvider/implementations/HandlebarsMailTemplateProvider.ts
  # Dentro do arquivo HandlebarsMailTemplateProvider.ts adicionar:

  import handlebars from 'handlebars'
  import fs from 'fs'

  import IParseMailTemplateDTO from '../dtos/IParseMailTemplateDTO'
  import IMailTemplateProvider from '../models/IMailTemplateProvider'

  class HandlebarsMailTemplateProvider implements IMailTemplateProvider {
    public async parse({
      file,
      variables,
    }: IParseMailTemplateDTO): Promise<string> {
      const templateFileContent = await fs.promises.readFile(file, {
        encoding: 'utf-8',
      })

      const parseTemplate = handlebars.compile(templateFileContent)

      return parseTemplate(variables)
    }
  }

  export default HandlebarsMailTemplateProvider
```

## Criar pasta dtos dentro da pasta MailTemplateProvider
```bash
  # Abrir pastas packages/server/src/shared/container/providers/ MailTemplateProvider 
  $ cd packages/server/src/shared/container/providers/ MailTemplateProvider 
  # Criar pasta dtos
  $ mkdir dtos
  # Caminho das pastas packages/server/src/shared/container/providers/MailTemplateProvider/dtos
```
## Criar arquivo IParseMailTemplateDTO.ts
```bash
  # Dentro de packages/server/src/shared/container/providers/MailTemplateProvider/dtos 
  $ cd packages/server/src/shared/container/providers/MailTemplateProvider/dtos 
  
  # Criar arquivo IParseMailTemplateDTO.ts e dentro colocar:


  interface ITemplateVariables {
    [key: string]: string | number
  }

  export default interface IParseMailTemplateDTO {
    file: string
    variables: ITemplateVariables
  }
```

## Add handlebars nodemailer
```bash
  # Dentro de packages/server
  $ cd packages/server
  # Execute 
  $ yarn add handlebars nodemailer
```

## Criar pasta views
```bash
  # Dentro de packates/server/src/modules/users 
  $ cd packates/server/src/modules/users
  # Execute
  $ mkdir views
```

## Criar arquivo forgot_password.hbs
```bash
  # Dentro de packates/server/src/modules/users/views
  $ cd packates/server/src/modules/users/views

  # Criar arquivo forgot_password.hbs e dentro colocar:

  <style>
    .message-content {
      font-family: Arial, Helvetica, sans-serif;
      max-width: 600px;
      font-size: 18px;
      line-height: 21px;
    }
  </style>

  <div class="message-content">
    <p>Olá, {{name}}</p>
    <p>Parece que uma troca de senha para sua conta foi solicitada.</p>
    <p>Se foi você, então clique no link abaixo para escolher uma nova senha:</p>
    <p>
      <a href="{{link}}">Resetar senha</a>
    </p>
    <p>Se não foi você, então descarte esse email!</p>
    <strong>Equipe X</strong>
  </div>
```

## Criar arquivo profile.routes.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/routes
  $ cd packages/server/src/modules/users/infra/http/routes

  # Criar arquivo profile.routes.ts e dentro colocar:

  import { Router } from 'express'
  import { celebrate, Segments, Joi } from 'celebrate'

  import ProfileController from '../controllers/ProfileController'

  import ensureAuthenticated from '../middlewares/ensureAuthenticated'

  const profileRouter = Router()
  const profileController = new ProfileController()

  profileRouter.use(ensureAuthenticated)

  profileRouter.get('/', profileController.show)
  profileRouter.put(
    '/',
    celebrate({
      [Segments.BODY]: {
        name: Joi.string().required(),
        email: Joi.string().email().required(),
        old_password: Joi.string(),
        password: Joi.string(),
        password_confirmation: Joi.string().valid(Joi.ref('password')),
      },
    }),
    profileController.update,
  )

  export default profileRouter
```

## Criar arquivo ProfileController.ts
```bash
  # Dentro de packages/server/src/modules/users/infra/http/controllers
  $ cd packages/server/src/modules/users/infra/http/controllers

  # Criar arquivo ProfileController.ts e dentro colocar:

  import { Request, Response } from 'express'
  import { container } from 'tsyringe'
  import { classToClass } from 'class-transformer'

  import UpdateProfileService from '@modules/users/services/UpdateProfileService'
  import ShowProfileService from '@modules/users/services/ShowProfileService'

  export default class ProfileController {
    public async show(request: Request, response: Response): Promise<Response> {
      const user_id = request.user.id

      const showProfile = container.resolve(ShowProfileService)

      const user = await showProfile.execute({ user_id })

      return response.json(classToClass(user))
    }

    public async update(request: Request, response: Response): Promise<Response> {
      const user_id = request.user.id
      const { name, email, old_password, password } = request.body

      const updateProfile = container.resolve(UpdateProfileService)

      const user = await updateProfile.execute({
        user_id,
        name,
        email,
        old_password,
        password,
      })

      delete user.password

      return response.json(classToClass(user))
    }
  }
```

## Criar arquivo UpdateProfileService.ts
```bash
  # Dentro de packages/server/src/modules/users/services
  $ cd packages/server/src/modules/users/services

  # Criar arquivo UpdateProfileService.ts e dentro colocar:

  import { injectable, inject } from 'tsyringe'

  import AppError from '@shared/errors/AppError'

  import IHashProvider from '../providers/HashProvider/models/IHashProvider'
  import IUsersRepository from '../repositories/IUsersRepository'

  import User from '../infra/typeorm/entities/User'

  interface IRequest {
    user_id: string
    name: string
    email: string
    old_password?: string
    password?: string
  }

  @injectable()
  class UpdateProfileService {
    constructor(
      @inject('UsersRepository')
      private usersRepository: IUsersRepository,

      @inject('HashProvider')
      private hashProvider: IHashProvider,
    ) {}

    public async execute({
      user_id,
      name,
      email,
      old_password,
      password,
    }: IRequest): Promise<User> {
      const user = await this.usersRepository.findById(user_id)

      if (!user) {
        throw new AppError('Usuário não encontrado')
      }

      const userWithUpdatedEmail = await this.usersRepository.findByEmail(email)

      if (userWithUpdatedEmail && userWithUpdatedEmail.id !== user_id) {
        throw new AppError('O e-mail passado já existe na base de dados')
      }

      user.name = name
      user.email = email

      if (password && !old_password) {
        throw new AppError(
          'Você precisa informar a senha antiga para alterar sua senha',
        )
      }

      if (password && old_password) {
        const checkOldPassword = await this.hashProvider.compareHash(
          old_password,
          user.password,
        )

        if (!checkOldPassword) {
          throw new AppError('Senha antiga incorreta')
        }

        user.password = await this.hashProvider.generateHash(password)
      }

      return this.usersRepository.save(user)
    }
  }

  export default UpdateProfileService
```

## Criar arquivo ShowProfileService.ts
```bash
  # Dentro de packages/server/src/modules/users/services
  $ cd packages/server/src/modules/users/services

  # Criar arquivo ShowProfileService.ts e dentro colocar:

  import { injectable, inject } from 'tsyringe'

  import AppError from '@shared/errors/AppError'

  import IUsersRepository from '../repositories/IUsersRepository'

  import User from '../infra/typeorm/entities/User'

  interface IRequest {
    user_id: string
  }

  @injectable()
  class ShowProfileService {
    constructor(
      @inject('UsersRepository')
      private usersRepository: IUsersRepository,
    ) {}

    public async execute({ user_id }: IRequest): Promise<User> {
      const user = await this.usersRepository.findById(user_id)

      if (!user) {
        throw new AppError('Usuário não encontrado')
      }

      return user
    }
  }

  export default ShowProfileService
```

## Alterar conteúdo de index.ts
```bash
  # Dentro de packages/server/src/shared/container/providers
  $ cd packages/server/src/shared/container/providers

  # Alterar conteúdo de index.ts por: 

  import './MailTemplateProvider'
  import './MailProvider'
  import './StorageProvider'
```

## Criar pasta typeorm
```bash
  # Dentro de packages/server/src/shared/infra
  $ cd packages/server/src/shared/infra
  # Execute
  $ mkdir typeorm
```

## Criar arquivo index.ts
```bash
  # Dentro de packages/server/src/shared/infra/typeorm 
  $ cd packages/server/src/shared/infra/typeorm

  # Criar arquivo index.ts e dentro colocar:

  import { createConnections } from 'typeorm'

  createConnections()
```

## Criar pasta migrations
```bash
  # Dentro de packages/server/src/shared/infra/typeorm 
  $ cd packages/server/src/shared/infra/typeorm
  # Execute
  $ mkdir migrations
```

## Criar arquivo ormconfig.json
```bash
  # Dentro de packages/server 
  $ cd packages/server
  
  # Criar arquivo ormconfig.json e dentro colocar:

  [
    {
      "name": "default",
      "type": "postgres",
      "host": "localhost",
      "port": 5432,
      "username": "postgres",
      "password": "docker",
      "database": "dbname",
      "entities": ["./src/modules/**/infra/typeorm/entities/*.ts"],
      "migrations": ["./src/shared/infra/typeorm/migrations/*.ts"],
      "cli": {
        "migrationsDir": "./src/shared/infra/typeorm/migrations"
      }
    },
    {
      "name": "mongo",
      "type": "mongodb",
      "host": "localhost",
      "port": 27017,
      "database": "dbname",
      "useUnifiedTopology": true,
      "entities": ["./src/modules/**/infra/typeorm/schemas/*.ts"]
    }
  ]
```

## Criar migration de criar usuário na pasta server
```bash
   # Abrir pastas packages/server
   $ cd packages/server
   # Roda no terminal dentro da pasta server:
   $ yarn typeorm migration:create -n CreateUsers
```

## Alterar os métodos UP e DOWN na migration criada
```bash
  # Abrir pastas packages/server/src/shared/infra/typeorm/migrations
  $ cd packages/server/src/shared/infra/typeorm/migrations
  # Na migration criada alterar os métodos UP e DOWN para:

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
            name: 'avatar',
            type: 'varchar',
            isNullable: true
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

## Criar migration de tokens na pasta server
```bash
  # Abrir pastas packages/server
  $ cd packages/server
  # Rodar no terminal dentro da pasta server:
  $ yarn typeorm migration:create -n CreateUserTokens
```

## Alterar os métodos UP e DOWN na migration de tokens criada
```bash
  # Abrir pastas packages/server/src/shared/infra/typeorm/migrations
  $ cd packages/server/src/shared/infra/typeorm/migrations
  # Alterar os métodos UP e DOWN para:

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'user_tokens',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()'
          },
          {
            name: 'token',
            type: 'uuid',
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()'
          },
          {
            name: 'user_id',
            type: 'uuid'
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
        ],
        foreignKeys: [
          {
            name: 'TokenUser',
            referencedTableName: 'users',
            referencedColumnNames: ['id'],
            columnNames: ['user_id'],
            onDelete: 'CASCADE',
            onUpdate: 'CASCADE'
          }
        ]
      })
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('user_tokens')
  }
```

## Rodar migration:run na pasta server
```bash
  # Abrir pastas packages/server
  $ cd packages/server
  # Roda no terminal:
  $ yarn typeorm migration:run
```

## Criar pasta tmp
```bash
  # Abrir pastas packages/server/tmp
  $ cd packages/server/tmp
  # Criar a pasta tmp
  $ mkdir tmp
  # Caminho das pastas packages/server/tmp
```

## Criar pasta uploads
```bash
  # Abrir pastas packages/server/tmp
  $ cd packages/server/tmp
  # Criar pasta uploads
  $ mkdir uploads
  # Caminho das pastas packages/server/tmp/uploads
```

## Criar arquivo .gitkeep dentro da pasta uploads
```bash
  # Abrir pastas packages/server/tmp/uploads
  $ cd packages/server/tmp/uploads
  # Criar o arquivo .gitkeep
  # Caminho das pastas até o arquivo packages/server/tmp/uploads/.gitkeep
```

## Adicionar conteúdo no .gitignore  
```bash
  # Abrir pastas packages/server/.gitignore para acessar o arquivo .gitignore
  $ cd packages/server/.gitignore
  # Dentro do .gitignore adicionar:

  tmp/uploads/*
  !tmp/uploads/.gitkeep
```
**OBS: Se necessário excluir com git rm arquivos indesejados do controle de versão**

## Rodar dependência do jest na pasta server
```bash
   # Abrir pastas packages/server
   $ cd packages/server
   # Roda no terminal a dependência jest:
   $ yarn add jest @types/jest ts-jest -D
```

## Rodar no terminal jest --init
```bash
  # Abrir pastas packages/server
  $ cd packages/server
  # Rodar no terminal dentro da pasta server:
  $ yarn jest --init
```

## Selecionar opções
```bash
  Selecionar opções como abaixo:

  1 - Would you like to use Jest when running "test" script in "package.json"? ... yes
  2 - Choose the test environment that will be used for testing » node
  3 - Do you want Jest to add coverage reports? ... no
  4 - Which provider should be used to instrument code for coverage? » babel
  5 - Automatically clear mock calls and instances between every test? ... yes
```
## Descomentar e modificar tag no arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Descomentar tag e modificar para:

  preset: 'ts-jest',
```

## Descomentar e modificar tag no arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Descomentar tag e modificar para:

  testMatch: ['**/*.spec.ts']
```

## Adicionar código no início do arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar o arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Adicionar no início do arquivo jest.config.js o código:

  const { pathsToModuleNameMapper } = require('ts-jest/utils')
  const { compilerOptions } = require('./tsconfig.json')
```

## Descomentar e modificar tag no arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Descomentar tag e modificar para:

  moduleNameMapper: pathsToModuleNameMapper(compilerOptions.paths, {
    prefix: '<rootDir>/src/'
  }),
```

## Descomentar e modificar tag no arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Descomentar tag e modificar para:

  collectCoverage: true,
```

## Descomentar e modificar tag no arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Descomentar tag e modificar para:

  collectCoverageFrom: ['<rootDir>/src/modules/**/services/*.ts'],  
```

## Descomentar e modificar tag no arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Descomentar tag e modificar para:

  coverageDirectory: 'coverage',
```

## Descomentar e modificar tag no arquivo jest.config.js
```bash
  # Abrir pastas packages/server/jest.config.js para acessar arquivo jest.config.js
  $ cd packages/server/jest.config.js
  # Descomentar tag e modificar para:
  
  coverageReporters: ['text-summary', 'lcov'],
```
  
## Criar arquivo CreateUserService.spec.ts 
```bash
  # Abrir pastas packages/server/src/modules/users/service
  $ cd  packages/server/src/modules/users/service
  # Criar o arquivo CreateUserService.spec.ts 
  # Caminho das pastas até o arquivo packages/server/src/modules/users/service/CreateUserService.spec.ts
  # Dentro do arquivo CreateUserService.spec.ts adicionar:

  import AppError from '@shared/errors/AppError'

  import FakeHashProvider from '../providers/HashProvider/fakes/FakeHashProvider'
  import FakeUsersRepository from '../repositories/fakes/FakeUsersRepository'
  import CreateUserService from './CreateUserService'

  let fakeUsersRepository: FakeUsersRepository
  let fakeHashProvider: FakeHashProvider
  let createUser: CreateUserService

  describe('CreateUser', () => {
    beforeEach(() => {
      fakeUsersRepository = new FakeUsersRepository()
      fakeHashProvider = new FakeHashProvider()
      createUser = new CreateUserService(fakeUsersRepository, fakeHashProvider)
    })

    it('should be able to create a new user', async () => {
      const user = await createUser.execute({
        name: 'Junior Oliveira',
        email: 'junior@gmail.com',
        password: '12345678'
      })

      expect(user).toHaveProperty('id')
    })

    it('should not be able to create a new user with same email', async () => {
      await createUser.execute({
        name: 'Junior Oliveira',
        email: 'junior@gmail.com',
        password: '12345678'
      })

      await expect(
        createUser.execute({
          name: 'Junior Oliveira',
          email: 'junior@gmail.com',
          password: '12345678'
        })
      ).rejects.toBeInstanceOf(AppError)
    })
  })
```

## Criar pasta fakes
```bash
  # Abrir pastas packages/server/src/modules/users/providers/HashProvider
  $ cd packages/server/src/modules/users/providers/HashProvider
  # Criar pasta fakes dentro da pasta HashProvider
  $ mkdir fakes
  # Caminho das pastas packages/server/src/modules/users/providers/HashProvider/fakes
```

## Criar arquivo FakeHashProvider.ts
```bash
  # Abrir pastas packages/server/src/modules/users/providers/HashProvider/fakes
  $ cd packages/server/src/modules/users/providers/HashProvider/fakes
  # Criar arquivo FakeHashProvider.ts dentro da pasta fakes
  # Caminho das pastas até o arquivo packages/server/src/modules/users/providers/HashProvider/fakes/FakeHashProvider.ts
  # Dentro do arquivo FakeHashProvider.ts adicionar:

  import IHashProvider from '../models/IHashProvider'

  export default class FakeHashProvider implements IHashProvider {
    public async generateHash(payload: string): Promise<string> {
      return payload
    }

    public async compareHash(payload: string, hashed: string): Promise<boolean> {
      return payload === hashed
    }
  }
```

## Criar pasta fakes dentro da pasta repositories
```bash
  # Abrir pastas packages/server/src/modules/users/repositories
  $ cd packages/server/src/modules/users/repositories
  # Criar pasta fakes dentro da pasta repositories
  $ mkdir fakes
  # Caminho das pastas packages/server/src/modules/users/repositories/fakes
```
## Criar arquivo FakeUsersRepository.ts
```bash
  # Abrir pastas packages/server/src/modules/users/repositories/fakes
  $ cd packages/server/src/modules/users/repositories/fakes
  # Criar arquivo FakeUsersRepository.ts dentro da pasta fakes
  # Caminho das pastas até o arquivo packages/server/src/modules/users/repositories/fakes/FakeUsersRepository.ts
  # Dentro do arquivo FakeUsersRepository.ts adicionar:

  import { uuid } from 'uuidv4'

  import IUsersRepository from '@modules/users/repositories/IUsersRepository'
  import ICreateUserDTO from '@modules/users/dtos/ICreateUserDTO'
  import User from '@modules/users/infra/typeorm/entities/User'

  class FakeUsersRepository implements IUsersRepository {
    private users: User[] = []

    public async findById(id: string): Promise<User | undefined> {
      const findUser = this.users.find(user => user.id === id)

      return findUser
    }

    public async findByEmail(email: string): Promise<User | undefined> {
      const findUser = this.users.find(user => user.email === email)

      return findUser
    }

    public async create(userData: ICreateUserDTO): Promise<User> {
      const user = new User()

      Object.assign(user, { id: uuid() }, userData)

      this.users.push(user)

      return user
    }

    public async save(user: User): Promise<User> {
      const findIndex = this.users.findIndex(findUser => findUser.id === user.id)

      this.users[findIndex] = user

      return user
    }
  }

  export default FakeUsersRepository
```
## Adicionar uuidv4 
```bash
  # Abrir pastas packages/server
  $ cd packages/server
  # Rodar no terminal na pasta server:
  $ yarn add uuidv4
```

## Rodar testes
```bash
  # Abrir pastas packages/server
  $ cd packages/server
  # Rodar no terminal na pasta server:
  $ yarn test
```
