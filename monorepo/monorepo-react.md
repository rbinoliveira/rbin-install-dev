# Anotações - Monorepo com React

## Criar pasta web

```bash
  # Abrir pasta packages
  $ cd packages
  # Rodar no terminal dentro da pasta packages
  $ npx create-react-app web --template typescript
```

## Alterar conteúdo tsconfig.json da pasta web


```bash
  # Abrir pastas packages/web/tsconfig.json para acessar o arquivo tsconfig.json
  $ cd packages/web/tsconfig.json

  # Alterar todo o conteúdo para:
  
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

## Excluir tag de package.json da pasta web

```bash
  # Abrir pastas packages/web/package.json para acessar arquivo package.json
  $ cd packages/web/package.json

  # Apagar a seguinte tag:

  "eslintConfig": {
    "extends": "react-app"
  },
```

## Excluir readme da pasta web

```bash
  # Abrir pastas packages/web
  $ cd packages/web

  # Excluir o arquivo readme.md
```

## Excluir arquivos desnecessários da pasta web/src

```bash
  # Abrir pastas packages/web/src e acessar os arquivos da pasta src
  $ cd packages/web/src
  # Excluir arquivos desnecessários deixando somente os arquivos:
  - App.tsx e index.tsx
```

## Trocar conteúdo do index.tsx da pasta web/src

```bash
  # Abrir pastas packages/web/src/index.tsx
  $ cd packages/web/src/index.tsx

  # Trocar todo o conteúdo do index.tsx por:

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

## Trocar conteúdo do arquivo App.tsx da pasta web/src

```bash
  # Abrir pastas packages/web/src/App.tsx
  $ cd packages/web/src/App.tsx

  # Trocar todo o conteúdo do App.tsx para:

  import React from 'react';

  const App: React.FC = () => <h1>Projeto vazio</h1>

  export default App;
```

## Excluir arquivos desnecessários da pasta web/public
```bash 
  # Abrir pastas packages/web/public
  $ cd packages/web/public

  # Excluir os arquivos desnecessários deixando somente os arquivos:
  - index.html e robots.txt
```

## Excluir comentários e linhas do index.html da pasta web/public

```bash
  # Abrir pastas  packages/web/public/index.html para acessar arquivo index.html
  $ cd packages/web/public/index.html

  # Excluir os seguintes comentários e linhas:
  <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
  <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
  <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
```

## Alterar nome do projeto do arquivo package.json da pasta web

```bash
  # Abrir pastas packages/web/package.json e acessar arquivo package.json
  $ cd packages/web/package.json
  # Alterar nome do projeto para:
  @NOME_DO_PROJETO/web
```

## Testar aplicação web

```bash
  # Abrir pastas packages/web
  $ cd packages/web
  # Rodar no terminal para testar a aplicação web:
  $ yarn start
```

## Adicionar dependências do styled-components

```bash
  # Abrir pastas packages/web
  $ cd packages/web
  # Rodar no terminal:
  yarn add styled-components polished
  yarn add @types/styled-components -D
```

## Criar pasta styles

```bash
  # Abrir pastas packages/web/src
  $ cd packages/web/src/
  # Criar pasta styles
  $ mkdir styles
  # caminho das pastas packages/web/src/styles
```

## Criar arquivo global.ts da pasta web/src

```bash
  # Abrir pastas packages/web/src/global.ts e criar o arquivos global.ts
  $ packages/web/src
  # Crie o arquivo:
   global.ts
   # Caminho das pastas packages/web/src/global.ts
```

## Colocar conteúdo no arquivo global.ts

```bash
  # Abrir pastas packages/web/src/global.ts
  $ cd packages/web/src/global.ts

  # Colocar o conteúdo abaixo no arquivo global.ts:

  import { createGlobalStyle } from 'styled-components'

  export const GlobalStyle = createGlobalStyle`
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      outline: 0;
    }

    :root {
      font-size: 62.5%;
      --primary-color: #00b3b4;
      --secondary-color: #0078b5;
      --contrast-color: #fff;
      --error-color: #c53030;
    }

    body {
      background: var(--primary-color);
      color: var(--font-color);
      -webkit-font-smoothing: antialiased;
    }

    body, input, button {
      font-family: 'Roboto', sans-serif;
      font-size: 1.6rem;
    }

    button {
      cursor: pointer;
    }
  `
  
```

## Trocar conteúdo do arquivo App.tsx da pasta web/src


```bash
  # Abrir pastas packages/web/src/App.tsx para acessar o arquivo App.tsx
  $ cd packages/web/src/App.tsx

  # Trocar o conteúdo do arquivo App.tsx para:

  import React from 'react'
  import { GlobalStyle } from './styles/global'

  const App: React.FC = () => (
    <>
      <p>Projeto vazio</p>
      <GlobalStyle />
    </>
  )

  export default App
```

## Criar pasta SignIn dentro da pasta web/src/pages/SignIn

```bash
  # Abrir pastas packages/web/src/pages
  $ cd packages/web/src/pages
  # Criar a pasta SignIn
  $ mkdir SignIn
  # Caminho das pastas packages/web/src/pages/SignIn
```

## Criar arquivos index.tsx e styles.ts na pasta SignIn

```bash
  # Abrir pastas packages/web/src/pages/SignIn
  $ cd packages/web/src/pages/SignIn
  # Crie os arquivos abaixo dentro da pasta SignIn
   index.tsx e o styles.ts
```
## Colocar conteúdo no arquivo index.tsx da pasta SignIn

```bash
  # Abrir pastas packages/web/src/pages/SignIn/index.tsx para acessar o arquivo index.tsx
  $ cd packages/web/src/pages/SignIn/index.tsx

  # Colocar no arquivo index.tsx o seguinte conteúdo:

  import React from 'react'

  import { Container, Content } from './styles'

  const SignIn: React.FC = () => {
    return (
      <Container>
        <Content>
          <form>
            <h1>Faça seu login</h1>

            <input placeholder="E-mail" />
            <input placeholder="Senha" type="password" />
            <button type="submit">Entrar</button>
          </form>

          <a href="teste">Criar Conta</a>
        </Content>
      </Container>
    )
  }

export default SignIn
```

## Colocar conteúdo no arquivo styles.ts da pasta SignIn

```bash
  # Abrir pastas packages/web/src/pages/SignIn/styles.ts
  $ cd packages/web/src/pages/SignIn/styles.ts

  # Adicione no arquivo styles.ts o seguinte conteúdo:

  import styled from 'styled-components'
  import { shade } from 'polished'

  export const Container = styled.div`
    height: 100vh; // Forçar a altura da tela ser a altura total do navegador

    display: flex;
    justify-content: center;
    align-items: stretch; // Força os elementos filhos esticarem para terem 100vh;
  `

  export const Content = styled.div`
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;

    width: 100%;
    max-width: 70rem;

    form {
      margin: 8rem 0;
      width: 34rem;
      text-align: center;

      h1 {
        margin-bottom: 2.4rem;
        color: var(--contrast-color);
      }

      input {
        background: var(--contrast-color);
        border-radius: 10px;
        border: 2px solid var(--contrast-color);
        padding: 1.6rem;
        width: 100%;

        & + input {
          margin-top: 0.8rem;
        }
      }

      button {
        background: var(--secondary-color);
        height: 56px;
        border-radius: 10px;
        border: 0;
        padding: 0 1.6rem;
        width: 100%;
        color: var(--contrast-color);
        margin-top: 1.6rem;
        transition: background-color 0.2s;

        &:hover {
          background: ${shade(0.2, '#0078b5')};
        }
      }
    }

    a {
      color: var(--contrast-color);
      display: block;
      margin-top: 2.4rem;
      text-decoration: none;
      transition: color 0.2s;

      &:hover {
        color: ${shade(0.2, '#fff')};
      }
    }
  `
```

## Trocar conteúdo do arquivo App.tsx da pasta web/src

```bash
  # Abrir pastas packages/web/src/App.tsx
  $ cd packages/web/src/App.tsx

  # Troque o conteúdo arquivo App.tsx  por:
  import React from 'react'
  import SignIn from './pages/SignIn'
  import { GlobalStyle } from './styles/global'

  const App: React.FC = () => (
    <>
      <SignIn />
      <GlobalStyle />
    </>
  )

  export default App
```

## Adicionar dependencia de icones

```bash
  # Abrir pastas packages/web
  $ cd packages/web
  # Rodar no terminal dentro da pasta web:
  $ yarn add react-icons @unform/core @unform/web

```

## Criar pastas components e Input

```bash
  # Abrir pastas packages/web/src
  $ cd packages/web/src
  # Criar a pasta 
  $ mkdir components
  # Entrar na pasta components 
  $ cd components
  # Criar a pasta Input
  $ mkdir Input
  # Caminho das pastas packages/web/src/components/Input

```

## Criar arquivo index.tsx dentro da pasta Input e adicionar conteúdo

```bash
  # Abrir pastas packages/web/src/components/Input/index.tsx para acessar o arquivo index.tsx
  $ cd packages/web/src/components/Input/index.tsx
  # Crie o arquivo index.tsx dentro da pasta Input

  # Adicione no arquivo index.tsx o seguinte conteúdo:

  import React, {
    InputHTMLAttributes,
    useEffect,
    useRef,
    useState,
    useCallback
  } from 'react'
  import { IconBaseProps } from 'react-icons'
  import { FiAlertCircle } from 'react-icons/fi'
  import { useField } from '@unform/core'

  import { Container, Error } from './styles'

  interface IInputProps extends InputHTMLAttributes<HTMLInputElement> {
    name: string
    containerStyle?: Object
    icon: React.ComponentType<IconBaseProps>
  }

  const Input: React.FC<IInputProps> = ({
    name,
    containerStyle = {},
    icon: Icon,
    ...rest
  }) => {
    const inputRef = useRef<HTMLInputElement>(null)

    const [isFocused, setIsFocused] = useState(false)
    const [isFilled, setIsFilled] = useState(false)

    const { fieldName, defaultValue, error, registerField } = useField(name)

    const handleInputFocus = useCallback(() => {
      setIsFocused(true)
    }, [])

    const handleInputBlur = useCallback(() => {
      setIsFocused(false)

      setIsFilled(!!inputRef.current?.value)
    }, [])

    useEffect(() => {
      registerField({
        name: fieldName,
        ref: inputRef.current,
        path: 'value'
      })
    }, [fieldName, registerField])

    return (
      <Container
        style={containerStyle}
        isErrored={!!error}
        isFilled={isFilled}
        isFocused={isFocused}
        data-testid="input-container"
      >
        {Icon && <Icon size={20} />}
        <input
          onFocus={handleInputFocus}
          onBlur={handleInputBlur}
          defaultValue={defaultValue}
          ref={inputRef}
          {...rest}
        />
        {error && (
          <Error title={error}>
            <FiAlertCircle color="var(--error-color)" size={20} />
          </Error>
        )}
      </Container>
    )
  }

  export default Input
```

## Criar arquivo Input/styles.ts e adicionar conteúdo

```bash
  # Abrir pastas packages/web/src/components/Input
  $ cd packages/web/src/components/Input
  # Crie o arquivo styles.ts dentro da pasta Input

  # Adicione no arquivo styles.ts o seguinte conteúdo:

  import styled, { css } from 'styled-components'

  import Tooltip from '../Tooltip'

  interface IContainerProps {
    isFocused: boolean
    isFilled: boolean
    isErrored: boolean
  }

  export const Container = styled.div<IContainerProps>`
    background: var(--contrast-color);
    border-radius: 10px;
    padding: 1.6rem;
    width: 100%;
    border: 2px solid var(--contrast-color);
    display: flex;
    align-items: center;
    & + div {
      margin-top: 0.8rem;
    }
    ${props =>
      props.isErrored &&
      css`
        border-color: var(--error-color);
      `}
    ${props =>
      props.isFocused &&
      css`
        color: var(--secondary-color);
        border-color: var(--secondary-color);
      `}
    ${props =>
      props.isFilled &&
      css`
        color: var(--secondary-color);
      `}
    input {
      flex: 1;
      background: transparent;
      border: 0;
    }
    svg {
      margin-right: 1.6rem;
    }
  `

  export const Error = styled(Tooltip)`
    height: 20px;
    margin-left: 1.6rem;
    svg {
      margin: 0;
    }
    span {
      background: var(--error-color);
      color: #fff;
      &::before {
        border-color: var(--error-color) transparent;
      }
    }
  `

```

## Criar pasta Tooltip

```bash
  # Abrir pastas packages/web/src/components
  $ cd packages/web/src/components
  # Dentro da pasta components criar a pasta Tooltip
  $ mkdir Tooltip
  # Caminho das pastas packages/web/src/components/Tooltip
```

## Criar arquivo Tooltip/index.tsx 

```bash
  # Abrir pastas packages/web/src/components/Tooltip
  $ cd packages/web/src/components/Tooltip
  # Crie o arquivo index.tsx

  # Adicione no arquivo index.tsx da pasta Tooltip o seguinte conteúdo:

  import React from 'react'

  import { Container } from './styles'

  interface ITooltipProps {
    title: string
    className?: string
  }

  const Tooltip: React.FC<ITooltipProps> = ({
    title,
    className = '',
    children,
  }) => {
    return (
      <Container className={className}>
        {children}
        <span>{title}</span>
      </Container>
    )
  }

  export default Tooltip
```

## Criar arquivo Tooltip/styles.ts 

```bash
  # Abrir pastas packages/web/src/components/Tooltip/styles.ts
  $ cd packages/web/src/components/Tooltip
  # Crie na pasta Tooltip o arquivo styles.ts

  # Adicione no arquivo styles.ts da pasta Tooltip o seguinte conteúdo:

  import styled from 'styled-components'

  export const Container = styled.div`
    position: relative;
    span {
      width: 160px;
      background: var(--secondary-color);
      padding: 0.8rem;
      border-radius: 4px;
      font-size: 1.4rem;
      font-weight: 500;
      opacity: 0;
      transition: opacity 0.4s;
      visibility: hidden;
      position: absolute;
      bottom: calc(100% + 12px);
      left: 50%;
      transform: translateX(-50%);
      color: var(--primary-color);
      &::before {
        content: '';
        border-style: solid;
        border-color: var(--secondary-color) transparent;
        border-width: 6px 6px 0 6px;
        top: 100%;
        position: absolute;
        left: 50%;
        transform: translateX(-50%);
      }
    }
    &:hover span {
      opacity: 1;
      visibility: visible;
    }
  `
  
```

## Adicionar dependência react-router-dom

```bash
  # Abrir pastas packages/web
  $ cd packages/web
  # Rodar no terminal:
  $ yarn add yup react-router-dom
```

## Adicionar dependência 

```bash
  # Abrir pastas packages/web
  $ cd packages/web
  # rodar no terminal:
  $ yarn add @types/yup @types/react-router-dom -D
```

## Criar pasta utils dentro da pasta web

```bash
  # Abrir pastas packages/web
  $ cd packages/web
  # Dentro da pasta web criar a pasta utils
  $ mkdir utils
  # Caminho das pastas packages/web/utils
```

## Criar arquivo getValidationErros.ts dentro da pasta utils

```bash
  # Abrir pastas packages/web/utils
  $ cd packages/web/utils
  # Criar o arquivo getValidationErros.ts dentro da pasta utils
  # Caminhos das pastas até o arquivo packages/web/utils/getValidationErros.ts

  # Dentro do arquivo getValidationErros.ts adicionar:

  import { ValidationError } from 'yup'

  interface IErrors {
    [key: string]: string
  }

  export default function getValidationErrors(err: ValidationError): IErrors {
    const validationErrors: IErrors = {}

    err.inner.forEach(error => {
      validationErrors[error.path] = error.message
    })

    return validationErrors
  }
```

## Criar pasta components/Button

```bash
  # Abrir pastas packages/web/src/components
  $ cd packages/web/src/components
  # Dentro da pasta components criar a pasta Button
  $ mkdir Button
  # Caminho das pastas packages/web/src/components/Button
```

## Criar arquivo Button/index.tsx 

```bash
  # Abrir pastas packages/web/src/components/Button
  $ cd packages/web/src/components/Button
  # Crie o arquivo index.tsx dentro da pasta Button

  # Dentro do arquivo index.tsx adicione:

  import React, { ButtonHTMLAttributes } from 'react'

  import { Container } from './styles'

  type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
    loading?: boolean
  }

  const Button: React.FC<ButtonProps> = ({ children, loading, ...rest }) => (
    <Container type="button" {...rest}>
      {loading ? 'Carregando...' : children}
    </Container>
  )

  export default Button

```

## Criar arquivo Button/styles.ts 

```bash
  # Abrir pastas packages/web/src/components/Button
  $ cd packages/web/src/components/Button
  # Crie o arquivo styles.ts dentro da pasta Button

  # Dentro do arquivo styles.ts adicione:

  import styled from 'styled-components'
  import { shade } from 'polished'

  export const Container = styled.button`
    background: var(--secondary-color);
    height: 56px;
    border-radius: 10px;
    border: 0;
    padding: 0 1.6rem;
    color: var(--contrast-color);
    width: 100%;
    font-weight: 500;
    margin-top: 1.6rem;
    transition: background-color 0.2s;
    &:hover {
      background: ${shade(0.2, '#0078b5')};
    }
  `
```

## Substituir conteúdo do arquivo SignIn/index.tsx 

```bash
  # Abrir pastas packages/web/src/pages/SignIn
  $ cd packages/web/src/pages/SignIn

  # Substituir conteúdo do arquivo index.tsx por:

  import React, { useCallback, useRef } from 'react'
  import { Form } from '@unform/web'
  import { Container, Content } from './styles'
  import * as Yup from 'yup'

  import Button from '../../components/Button'
  import Input from '../../components/input'
  import { FormHandles } from '@unform/core'
  import { useHistory } from 'react-router-dom'
  import { FiLock, FiMail } from 'react-icons/fi'
  import getValidationErrors from '../../utils/getValidationErrors'

  interface ISignInFormData {
    email: string
    password: string
  }

  const SignIn: React.FC = () => {
    const formRef = useRef<FormHandles>(null)

    // const { signIn } = useAuth()

    const history = useHistory()

    const handleSubmit = useCallback(
      async (data: ISignInFormData) => {
        try {
          formRef.current?.setErrors({})

          const schema = Yup.object().shape({
            email: Yup.string()
              .required('E-mail obrigatório')
              .email('E-mail inválido'),
            password: Yup.string().required('Senha obrigatória')
          })

          await schema.validate(data, {
            abortEarly: false
          })

          // await signIn({
          //   email: data.email,
          //   password: data.password
          // })

          history.push('/dashboard')
        } catch (err) {
          if (err instanceof Yup.ValidationError) {
            const errors = getValidationErrors(err)

            formRef.current?.setErrors(errors)
          }
        }
      },
      [history]
    )

    return (
      <Container>
        <Content>
          <Form ref={formRef} onSubmit={handleSubmit}>
            <h1>Faça seu login</h1>

            <Input icon={FiMail} name="email" placeholder="E-mail" />
            <Input
              icon={FiLock}
              name="password"
              placeholder="Senha"
              type="password"
            />
            <Button type="submit">Entrar</Button>
          </Form>

          <a href="temporário">Criar Conta</a>
        </Content>
      </Container>
    )
  }

  export default SignIn
```

## Trocar conteúdo do arquivo SignIn/styles.ts 

```bash
  # Abrir pastas packages/web/src/pages/SignIn/styles.ts para acessar arquivo styles.ts
  $ cd packages/web/src/pages/SignIn/styles.ts

  # Trocar conteúdo do arquivo styles.ts por:

  import styled from 'styled-components'
  import { shade } from 'polished'

  export const Container = styled.div`
    height: 100vh; // Forçar a altura da tela ser a altura total do navegador

    display: flex;
    justify-content: center;
    align-items: stretch; // Força os elementos filhos esticarem para terem 100vh;
  `

  export const Content = styled.div`
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;

    width: 100%;
    max-width: 70rem;

    form {
      margin: 8rem 0;
      width: 34rem;
      text-align: center;

      h1 {
        margin-bottom: 2.4rem;
        color: var(--contrast-color);
      }
    }

    a {
      color: var(--contrast-color);
      display: block;
      margin-top: 2.4rem;
      text-decoration: none;
      transition: color 0.2s;

      &:hover {
        color: ${shade(0.2, '#fff')};
      }
    }
  `
```

## Criar pasta routes dentro da pasta web/src

```bash 
  # Abrir pastas src/packages/web/src
  $  cd src/packages/web/src
  # Crie a pasta routes
  $ mkdir routes
  # Caminho das pastas src/packages/web/src/routes
```

## Criar arquivo web/src/index.tsx 

```bash
  # Abrir pastas packages/web/src/index.tsx
  $ cd packages/web/src/index.tsx

  # Dentro do arquivo index.tsx adicionar:

  import React from 'react'
  import { Switch } from 'react-router-dom'

  import Route from './Route'

  import SignIn from '../pages/SignIn'
  // import SignUp from '../pages/SignUp'

  // import Dashboard from '../pages/Dashboard'

  const Routes: React.FC = () => (
    <Switch>
      <Route path="/" exact component={SignIn} />
      {/* <Route path="/signup" component={SignUp} /> */}

      {/* <Route path="/dashboard" component={Dashboard} isPrivate /> */}
    </Switch>
  )

  export default Routes
```

## Criar arquivo web/src/routes/Route.tsx

```bash
  # Abrir pastas packages/web/src/routes
  $ cd packages/web/src/routes
  # Criar o arquivo Route.tsx

  # Dentro do arquivo Route.tsx adicionar:

  import React from 'react'
  import {
    Route as ReactDOMRoute,
    RouteProps as ReactDOMRouteProps,
    Redirect,
  } from 'react-router-dom'

  import { useAuth } from '../hooks/auth'

  interface IRouteProps extends ReactDOMRouteProps {
    isPrivate?: boolean
    component: React.ComponentType
  }

  const Route: React.FC<IRouteProps> = ({
    isPrivate = false,
    component: Component,
    ...rest
  }) => {
    const { user } = useAuth()

    return (
      <ReactDOMRoute
        {...rest}
        render={({ location }) => {
          return isPrivate === !!user ? (
            <Component />
          ) : (
            <Redirect
              to={{
                pathname: isPrivate ? '/' : '/dashboard',
                state: { from: location },
              }}
            />
          )
        }}
      />
    )
  }

  export default Route
```

## Criar pasta hooks

```bash
  # Abrir pastas packages/web/src
  $ cd packages/web/src
  # Criar pasta hooks
  $ mkdir hooks
  # Caminho das pastas packages/web/src/hooks
```

## Criar arquivo hooks/index.tsx 
```bash
  # Abrir pastas packages/web/src/hooks
  $ cd packages/web/src/hooks
  # Criar o arquivo index.tsx dentro da pasta hooks
  # Caminho das pastas até o arquivo packages/web/src/hooks/index.tsx
  
  # Abrir o arquivo index.tsx e dentro colocar:

  import React from 'react'

  import { AuthProvider } from './auth'

  const AppProvider: React.FC = ({ children }) => (
    <AuthProvider>{children}</AuthProvider>
  )

  export default AppProvider
```

## Criar arquivo hooks/auth.tsx
```bash
  # Abrir pastas packages/web/src
  $ cd packages/web/src/hooks

  # Abrir o arquivo auth.tsx e dentro colocar:

  import React, { createContext, useCallback, useState, useContext } from 'react'
  import api from '@NOME_DO_PROJETO/axios-config'

  interface IUser {
    id: string
    name: string
    email: string
    avatar_url: string
  }

  interface IAuthState {
    token: string
    user: IUser
  }

  interface ISingInCredentials {
    email: string
    password: string
  }

  interface IAuthContextData {
    user: IUser
    signIn(credentials: ISingInCredentials): Promise<void>
    signOut(): void
  }

  const AuthContext = createContext<IAuthContextData>({} as IAuthContextData)

  const AuthProvider: React.FC = ({ children }) => {
    const [data, setData] = useState<IAuthState>(() => {
      const token = localStorage.getItem('@NOME_DO_APLICATIVO:token')
      const user = localStorage.getItem('@NOME_DO_APLICATIVO:user')

      if (token && user) {
        api.defaults.headers.authorization = `Bearer ${token}`

        return { token, user: JSON.parse(user) }
      }

      return {} as IAuthState
    })

    const signIn = useCallback(async ({ email, password }) => {
      const response = await api.post('sessions', {
        email,
        password
      })

      const { token, user } = response.data

      localStorage.setItem('@NOME_DO_APLICATIVO:token', token)
      localStorage.setItem('@NOME_DO_APLICATIVO:user', JSON.stringify(user))

      api.defaults.headers.authorization = `Bearer ${token}`

      setData({ token, user })
    }, [])

    const signOut = useCallback(async () => {
      localStorage.removeItem('@NOME_DO_APLICATIVO:token')
      localStorage.removeItem('@NOME_DO_APLICATIVO:user')

      setData({} as IAuthState)
    }, [])

    return (
      <AuthContext.Provider value={{ user: data.user, signIn, signOut }}>
        {children}
      </AuthContext.Provider>
    )
  }

  const useAuth = (): IAuthContextData => {
    const context = useContext(AuthContext)

    return context
  }

  export { AuthProvider, useAuth }
```

## Alterar todo o conteúdo de web/src/App.tsx
```bash
  # Abrir pastas packages/web/src
  $ cd packages/web/src

  # Abrir o arquivo App.tsx e trocar por:

  import React from 'react'
  import { BrowserRouter } from 'react-router-dom'

  import { GlobalStyle } from './styles/global'

  import AppProvider from './hooks'

  import Routes from './routes'

  const App: React.FC = () => (
    <BrowserRouter>
      <AppProvider>
        <Routes />
      </AppProvider>

      <GlobalStyle />
    </BrowserRouter>
  )

  export default App
```

## Criar pasta Dashboard
```bash
  # Abrir pastas packages/web/src/pages
  $ cd packages/web/src/pages
  # Criar pasta Dashboard
  $ mkdir Dashboard
```

## Criar arquivo Dashboard/index.tsx
```bash
  # Abrir pastas packages/web/src/pages/Dasboard
  $ cd packages/web/src/pages/Dasboard

  # Criar arquivo index.tsx e dentro colocar:

  import React from 'react'
  import { useAuth } from '../../hooks/auth'

  const Dashboard: React.FC = () => {
    const { signOut } = useAuth()

    return (
      <>
        <p>Bem-vindo ao Dashboard</p>
        <button type="button" onClick={signOut}>
          Sair
        </button>
      </>
    )
  }

  export default Dashboard
```

## Criar pasta pages/SignUp
```bash
  # Dentro de packages/web/src/pages
  $ cd packages/web/src/pages
  # Criar pasta SignUp
  $ mkdir SignUp
```

## Criar arquivo SignUp/index.tsx
```bash
  # Dentro de packages/web/src/pages/SignUp
  $ cd packages/web/src/pages/SignUp

  # Criar arquivo index.tsx e dentro colocar:

  import React, { useCallback, useRef } from 'react'
  import { Form } from '@unform/web'
  import { Container, Content } from './styles'
  import * as Yup from 'yup'

  import Button from '../../components/Button'
  import Input from '../../components/input'
  import { FormHandles } from '@unform/core'
  import { Link, useHistory } from 'react-router-dom'
  import { FiLock, FiMail, FiUser } from 'react-icons/fi'
  import getValidationErrors from '../../utils/getValidationErrors'
  import api from '@monoreact/axios-config'

  interface ISignUpFormData {
    name: string
    email: string
    password: string
  }

  const SignIn: React.FC = () => {
    const formRef = useRef<FormHandles>(null)

    const history = useHistory()

    const handleSubmit = useCallback(
      async (data: ISignUpFormData) => {
        try {
          formRef.current?.setErrors({})

          const schema = Yup.object().shape({
            name: Yup.string().required('Nome obrigatório'),
            email: Yup.string()
              .required('E-mail obrigatório')
              .email('E-mail inválido'),
            password: Yup.string().required('Senha obrigatória')
          })

          await schema.validate(data, {
            abortEarly: false
          })

          await api.post('/users', data)

          history.push('/')
        } catch (err) {
          if (err instanceof Yup.ValidationError) {
            const errors = getValidationErrors(err)

            formRef.current?.setErrors(errors)
          }
        }
      },
      [history]
    )

    return (
      <Container>
        <Content>
          <Form ref={formRef} onSubmit={handleSubmit}>
            <h1>Crie sua conta</h1>

            <Input icon={FiUser} name="name" placeholder="Nome" />
            <Input icon={FiMail} name="email" placeholder="E-mail" />
            <Input
              icon={FiLock}
              name="password"
              placeholder="Senha"
              type="password"
            />
            <Button type="submit">Cadastrar</Button>
          </Form>

          <Link to="/">Voltar para login</Link>
        </Content>
      </Container>
    )
  }

  export default SignIn
```

## Criar arquivo SignUp/styles.ts
```bash
  # Dentro de packages/web/src/pages/SignUp
  $ cd packages/web/src/pages/SignUp
  
  # Criar arquivo styles.ts e dentro colocar:

  import styled from 'styled-components'
  import { shade } from 'polished'

  export const Container = styled.div`
    height: 100vh; // Forçar a altura da tela ser a altura total do navegador

    display: flex;
    justify-content: center;
    align-items: stretch; // Força os elementos filhos esticarem para terem 100vh;
  `

  export const Content = styled.div`
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;

    width: 100%;
    max-width: 70rem;

    form {
      margin: 8rem 0;
      width: 34rem;
      text-align: center;

      h1 {
        margin-bottom: 2.4rem;
        color: var(--contrast-color);
      }
    }

    a {
      color: var(--contrast-color);
      display: block;
      margin-top: 2.4rem;
      text-decoration: none;
      transition: color 0.2s;

      &:hover {
        color: ${shade(0.2, '#fff')};
      }
    }
  `
```

## Alterar conteúdo de SignIn/index.tsx
```bash
  # Dentro de packages/web/src/pages/SignIn
  $ cd packages/web/src/pages/SignIn
  
  # Alterar o conteúdo do arquivo index.tsx por:

  import React, { useCallback, useRef } from 'react'
  import { Form } from '@unform/web'
  import { Container, Content } from './styles'
  import * as Yup from 'yup'

  import Button from '../../components/Button'
  import Input from '../../components/input'
  import { FormHandles } from '@unform/core'
  import { Link, useHistory } from 'react-router-dom'
  import { FiLock, FiMail } from 'react-icons/fi'
  import getValidationErrors from '../../utils/getValidationErrors'
  import { useAuth } from '../../hooks/auth'

  interface ISignInFormData {
    email: string
    password: string
  }

  const SignIn: React.FC = () => {
    const formRef = useRef<FormHandles>(null)

    const { signIn } = useAuth()

    const history = useHistory()

    const handleSubmit = useCallback(
      async (data: ISignInFormData) => {
        try {
          formRef.current?.setErrors({})

          const schema = Yup.object().shape({
            email: Yup.string()
              .required('E-mail obrigatório')
              .email('E-mail inválido'),
            password: Yup.string().required('Senha obrigatória')
          })

          await schema.validate(data, {
            abortEarly: false
          })

          await signIn({
            email: data.email,
            password: data.password
          })

          history.push('/dashboard')
        } catch (err) {
          if (err instanceof Yup.ValidationError) {
            const errors = getValidationErrors(err)

            formRef.current?.setErrors(errors)
          }
        }
      },
      [history, signIn]
    )

    return (
      <Container>
        <Content>
          <Form ref={formRef} onSubmit={handleSubmit}>
            <h1>Faça seu login</h1>

            <Input icon={FiMail} name="email" placeholder="E-mail" />
            <Input
              icon={FiLock}
              name="password"
              placeholder="Senha"
              type="password"
            />
            <Button type="submit">Entrar</Button>
          </Form>

          <Link to="/signup">Criar conta</Link>
        </Content>
      </Container>
    )
  }

  export default SignIn
```

## Alterar todo o conteúdo de routes/index.tsx
```bash
  # Dentro de packages/web/src/routes
  $ cd packages/web/src/routes

  # Alterar conteúdo do arquivo index.tsx por:

  import React from 'react'
  import { Switch } from 'react-router-dom'

  import Route from './Route'

  import SignIn from '../pages/SignIn'
  import SignUp from '../pages/SignUp'

  import Dashboard from '../pages/Dashboard'

  const Routes: React.FC = () => (
    <Switch>
      <Route path="/" exact component={SignIn} />
      <Route path="/signup" component={SignUp} />

      <Route path="/dashboard" component={Dashboard} isPrivate />
    </Switch>
  )

  export default Routes
```