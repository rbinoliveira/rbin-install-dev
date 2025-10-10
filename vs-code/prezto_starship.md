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

adicione o conteúdo abaixo, salve e feche
```
#format = """
#[╭─user───❯](bold blue) $username
#[┣─system─❯](bold yellow) $hostname
#[┣─project❯](bold red) $directory$rust$git_branch$git_state$git_status$package$golang$terraform$docker_context$python$docker_context$nodejs
#[╰─cmd────❯](bold green)
#"""
[username]
style_user = "green bold"
style_root = "red bold"
format = "[$user]($style) "
disabled = false
show_always = true

[hostname]
disabled = true

# Replace the "❯" symbol in the prompt with "➜"
[character]                            # The name of the module we are configuring is "character"
success_symbol = "[➜](bold green)"     # The "success_symbol" segment is being set to "➜" with the color "bold green"
error_symbol = "[✗](bold red)"

#  
# configure directory
[directory]
read_only = " "
truncation_length = 10
truncate_to_repo = true # truncates directory to root folder if in github repo
style = "bold italic blue"

[cmd_duration]
min_time = 4
show_milliseconds = false
disabled = false
style = "bold italic red"

[aws]
symbol = "  "

[conda]
symbol = " "

[dart]
symbol = " "

#[directory]
#read_only = " "

[docker_context]
symbol = " "
format = "via [$symbol$context]($style) "
style = "blue bold"
only_with_files = true
detect_files = ["docker-compose.yml", "docker-compose.yaml", "Dockerfile"]
detect_folders = []
disabled = false

[elixir]
symbol = " "

[elm]
symbol = " "

[git_branch]
symbol = " "

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
stashed = "[${count}*](green)" 
modified = "[${count}+](yellow)" 
deleted =  "[${count}-](red)" 
conflicted =  "[${count}~](red)" 
ahead = "⇡${count}"
behind = "⇣${count}"
untracked = "[${count}?](blue)" 
staged = "[${count}+](green)" 

[git_state]
style =	"bold red"
format = "[$state( $progress_current/$progress_total) ]($style)"
rebase = "rebase"
merge = "merge"	
revert = "revert"	
cherry_pick = "cherry"
bisect = "bisect"	
am = "am"	
am_or_rebase = "am/rebase"

[golang]
symbol = " "

[hg_branch]
symbol = " "

[java]
symbol = " "

[julia]
symbol = " "

[haskell]
symbol = "λ "

[memory_usage]
symbol = " "

[nim]
symbol = " "

[nix_shell]
symbol = " "

[package]
symbol = " "

[perl]
symbol = " "

[php]
symbol = " "

[python]
symbol = "🐍 "
#pyenv_version_name = true
format = 'via [${symbol}python (${version} )(\($virtualenv\) )]($style)'
style = "bold yellow"
pyenv_prefix = "venv "
python_binary = ["./venv/bin/python", "python", "python3", "python2"]
detect_extensions = ["py"]
version_format = "v${raw}"

[ruby]
symbol = " "

[rust]
symbol = " "

[scala]
symbol = " "

[shlvl]
symbol = " "

[swift]
symbol = "ﯣ "

[custom.ts]
command = "echo TS"
format = "via [ TS](bold blue) "
detect_files = ["tsconfig.json","tsconfig.base.json"]
detect_folders = ["node_modules"]

[dotnet]
disabled = true

[nodejs]
disabled = true
```
