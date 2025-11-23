#Docker 
```
sudo apt update
sudo apt upgrade -y
```

```
sudo apt remove docker docker-engine docker.io containerd runc -y
```

```
sudo apt install -y ca-certificates curl gnupg lsb-release
```

```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
sudo apt update
```

```
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

deve functionar:
```
sudo docker run hello-world
```

Rode o comando abaixo e depois deslogue e logue e veja de consegue rodar docker ps sem sudo
```
sudo usermod -aG docker $USER
```

#Node e yarn

```
sudo apt update && sudo apt upgrade -y
```

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
```

```
nvm install 22
nvm alias default 22
node -v
npm -v
```

```
corepack enable && \
corepack prepare yarn@1 --activate && \
yarn -v
```

