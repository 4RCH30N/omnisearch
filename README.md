# OmniSearch

<p align="center">
  <img alt="Bash" src="https://img.shields.io/badge/Bash-Script-121011?logo=gnu-bash">
  <img alt="Linux" src="https://img.shields.io/badge/Platform-Linux-blue">
  <img alt="Status" src="https://img.shields.io/badge/Status-Active-success">
</p>

OmniSearch é um script em **Bash** desenvolvido para realizar buscas em sistemas Linux com base em diferentes critérios, como **nome**, **hash**, **data**, **tamanho**, **conteúdo** e **extensão de arquivo**.

O projeto foi criado para facilitar análises rápidas no sistema e investigações em ambientes Linux.

---

# Funcionalidades

O OmniSearch permite buscar arquivos e diretórios utilizando os seguintes critérios:

- busca por **nome**
- busca por **hash MD5**
- busca por **hash SHA256**
- busca por **data de modificação**
- busca por **tamanho em bytes**
- busca por **tamanho legível** (`K`, `M`, `G`, `T`)
- busca por **conteúdo dentro de arquivos**
- busca por **extensão de arquivo**

Além disso o script possui:

- execução paralela
- barra de progresso
- resumo final dos resultados
- exibição detalhada de metadados
- exportação opcional de relatório

---

# Requisitos

O script utiliza utilitários comuns em sistemas Linux:

- bash
- find
- grep
- awk
- sed
- tr
- date
- stat
- du
- file
- md5sum
- sha256sum
- xargs
- flock
- mktemp

Na maioria das distribuições Linux essas ferramentas já vêm instaladas.

---

# Instalação

Clone o repositório:

```bash
git clone https://github.com/4RCH30N/omnisearch.git
cd omnisearch
