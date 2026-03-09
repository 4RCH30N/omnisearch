# OmniSearch

<p align="center">
  <img alt="Bash" src="https://img.shields.io/badge/Bash-Script-121011?logo=gnu-bash">
  <img alt="Linux" src="https://img.shields.io/badge/Platform-Linux-blue">
  <img alt="Status" src="https://img.shields.io/badge/Status-Active-success">
</p>

OmniSearch é um script em **Bash** desenvolvido para realizar buscas em sistemas Linux com base em diferentes critérios, como **nome**, **hash**, **data**, **tamanho** e **conteúdo interno de arquivos**.

O projeto foi pensado para facilitar análises rápidas no sistema, oferecendo:

- busca em todo o sistema
- execução paralela
- barra de progresso
- resumo final dos resultados
- exibição detalhada de metadados
- exportação opcional de relatório em `.txt`

---

## Funcionalidades

O OmniSearch permite buscar arquivos e diretórios com os seguintes critérios:

- **Nome**
- **MD5**
- **SHA256**
- **Data de modificação**
- **Tamanho em bytes**
- **Tamanho em formato legível** (`K`, `M`, `G`, `T`)
- **Conteúdo literal dentro de arquivos**
- **Filtro opcional por nome/padrão de arquivo** na busca por conteúdo

Além disso, o script exibe informações detalhadas como:

- caminho completo
- nome do item
- tipo e MIME type
- tamanho em bytes e tamanho legível
- permissões
- dono e grupo
- data de modificação
- inode
- número de links
- hashes MD5 e SHA256, quando aplicável

---

## Requisitos

O script utiliza ferramentas comuns presentes na maioria das distribuições Linux:

- `bash`
- `find`
- `grep`
- `awk`
- `sed`
- `tr`
- `date`
- `stat`
- `du`
- `file`
- `md5sum`
- `sha256sum`
- `xargs`
- `flock`
- `mktemp`

---

## Instalação

Clone o repositório:

```bash
git clone https://github.com/SEU_USUARIO/omnisearch.git
cd omnisearch
