```
sudo apt install zsh
```

```
chsh -s $(which zsh)
```

Abaixo precisa retornar zsh, para isso de logoff and login no usuario para atualizar
```
echo $SHELL
```

```
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
```

```
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

Boa hora para instalar a ide, e rodar
```
cursor ~/.zshrc
```

e adicione no fim do arquivo .zshrc:
```
eval "$(starship init zsh)"
```

feche e salve o arquivo e rode no terminal
```
source ~/.zshrc
```

Personalizar o terminal, rode para alterar o arquivo
```
cursor ~/.config/starship.toml
```
