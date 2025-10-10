```
wget -O JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

mkdir -p ~/.local/share/fonts

unzip JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono

fc-cache -fv

rm JetBrainsMono.zip
```
