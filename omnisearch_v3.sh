#!/bin/bash

# Função para mostrar o banner do projeto
# Ela pode ser usada tanto na tela quanto no relatório
mostrar_banner() {
    # echo imprime uma linha com vários sinais de "=" para formar a borda superior
    echo "========================================================================================"

    # echo sem texto imprime uma linha em branco
    echo

    # As próximas linhas imprimem o banner em ASCII art
    echo "       ██████╗ ███╗   ███╗███╗   ██╗██╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗ "
    echo "      ██╔═══██╗████╗ ████║████╗  ██║██║██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║ "
    echo "      ██║   ██║██╔████╔██║██╔██╗ ██║██║███████╗█████╗  ███████║██████╔╝██║     ███████║ "
    echo "      ██║   ██║██║╚██╔╝██║██║╚██╗██║██║╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║ "
    echo "      ╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║ "
    echo "       ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ "
    echo "                                   Developed by 4RCH30N                                 "
    echo
    echo "========================================================================================"
}

# Função para mostrar o uso correto do script
mostrar_uso() {
    # Mostra o texto "Uso:"
    echo "Uso:"

    # "$0" representa o nome usado para chamar o script
    echo "  $0 --nome VALOR"
    echo "  $0 --md5 HASH"
    echo "  $0 --sha256 HASH"
    echo "  $0 --data AAAA-MM-DD"
    echo "  $0 --tamanho VALOR_EM_BYTES"
    echo "  $0 --tamanho -L VALOR_LEGIVEL"
    echo "  $0 --conteudo TEXTO"
    echo "  $0 --conteudo TEXTO --arquivo PADRAO"

    # Linha em branco para separar a seção de uso da seção de exemplos
    echo

    # Mostra o texto "Exemplos:"
    echo "Exemplos:"
    echo "  $0 --nome passwd"
    echo "  $0 --md5 44d88612fea8a8f36de82e1278abb02f"
    echo "  $0 --sha256 HASH_AQUI"
    echo "  $0 --data 2026-03-09"
    echo "  $0 --tamanho 1024"
    echo "  $0 --tamanho -L 10M"
    echo "  $0 --conteudo FLAG{"
    echo "  $0 --conteudo FLAG{ --arquivo \"*.txt\""
    echo "  $0 --conteudo senha --arquivo \"config.txt\""
}

# Função para converter tamanho legível para bytes
# Exemplo:
# 10K -> 10240
# 5M  -> 5242880
# 1G  -> 1073741824
converter_tamanho() {
    # "$1" recebe o valor legível digitado pelo usuário
    entrada="$1"

    # Remove a parte numérica da unidade
    unidade=$(echo "$entrada" | sed 's/[0-9.]//g' | tr '[:lower:]' '[:upper:]')

    # Remove a parte textual e mantém apenas o número
    numero=$(echo "$entrada" | sed 's/[^0-9.]//g')

    # Se não existir número, retorna vazio
    if [ -z "$numero" ]; then
        echo ""
        return
    fi

    # Converte conforme a unidade informada
    case "$unidade" in
        K)
            awk "BEGIN {printf \"%.0f\", $numero * 1024}"
            ;;
        M)
            awk "BEGIN {printf \"%.0f\", $numero * 1024 * 1024}"
            ;;
        G)
            awk "BEGIN {printf \"%.0f\", $numero * 1024 * 1024 * 1024}"
            ;;
        T)
            awk "BEGIN {printf \"%.0f\", $numero * 1024 * 1024 * 1024 * 1024}"
            ;;
        "")
            awk "BEGIN {printf \"%.0f\", $numero}"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Variáveis que guardam o modo de busca e o valor procurado
# modo            -> guarda qual tipo de busca será feita
# valor           -> guarda o termo, hash, data, tamanho ou conteúdo procurado
# descricao_busca -> guarda um texto amigável para mostrar na tela
# filtro_arquivo  -> opcional, filtra quais nomes de arquivo entram na busca
modo=""
valor=""
descricao_busca=""
filtro_arquivo=""

# Analisa a quantidade de argumentos passados
if [ $# -lt 2 ]; then
    echo
    mostrar_banner
    echo
    mostrar_uso
    exit 1
fi

# "case" analisa o primeiro argumento para decidir o modo de busca
case "$1" in
    --nome)
        # Define o modo como busca por nome
        modo="nome"

        # "$2" é o valor procurado
        valor="$2"

        # Monta uma descrição amigável da busca
        descricao_busca="Busca por nome: $valor"
        ;;

    --md5)
        # Define o modo como busca por hash MD5
        modo="md5"

        # Converte o hash informado para minúsculo
        valor=$(echo "$2" | tr '[:upper:]' '[:lower:]')

        # Monta a descrição amigável
        descricao_busca="Busca por MD5: $valor"
        ;;

    --sha256)
        # Define o modo como busca por hash SHA256
        modo="sha256"

        # Converte o hash informado para minúsculo
        valor=$(echo "$2" | tr '[:upper:]' '[:lower:]')

        # Monta a descrição amigável
        descricao_busca="Busca por SHA256: $valor"
        ;;

    --data)
        # Define o modo como busca por data
        modo="data"

        # Guarda a data informada pelo usuário
        valor="$2"

        # Monta a descrição amigável
        descricao_busca="Busca por data de modificação: $valor"
        ;;

    --tamanho)
        # Define o modo como busca por tamanho
        modo="tamanho"

        # Se o segundo argumento for -L, o tamanho foi informado em formato legível
        if [ "$2" = "-L" ]; then
            # "$3" recebe o valor legível informado
            tamanho_legivel_informado="$3"

            # Verifica se o usuário esqueceu de informar o valor após -L
            if [ -z "$tamanho_legivel_informado" ]; then
                echo "Erro: informe o tamanho legível após -L."
                echo
                mostrar_uso
                exit 1
            fi

            # Converte o tamanho legível para bytes
            valor=$(converter_tamanho "$tamanho_legivel_informado")

            # Se a conversão falhar, o valor ficará vazio
            if [ -z "$valor" ]; then
                echo "Erro: tamanho legível inválido."
                exit 1
            fi

            # Monta a descrição amigável
            descricao_busca="Busca por tamanho: $tamanho_legivel_informado ($valor bytes)"
        else
            # Se não usar -L, considera que o valor já está em bytes
            valor="$2"

            # Monta a descrição amigável
            descricao_busca="Busca por tamanho: $valor bytes"
        fi
        ;;

    --conteudo)
        # Define o modo como busca por conteúdo dentro do arquivo
        modo="conteudo"

        # "$2" é o texto que será procurado dentro dos arquivos
        valor="$2"

        # Se o usuário informar mais argumentos, tentamos ler o filtro opcional
        # Exemplo:
        # --conteudo "FLAG{" --arquivo "*.txt"
        if [ $# -ge 4 ]; then
            # Verifica se o terceiro argumento é --arquivo
            if [ "$3" = "--arquivo" ]; then
                # "$4" recebe o padrão de nome do arquivo
                filtro_arquivo="$4"
            else
                # Se houver argumentos extras inválidos, mostra erro
                echo "Erro: argumento adicional inválido para --conteudo."
                echo
                mostrar_uso
                exit 1
            fi
        fi

        # Verifica se o usuário usou --arquivo mas não informou o padrão
        if [ "$3" = "--arquivo" ] && [ -z "$4" ]; then
            echo "Erro: informe o padrão após --arquivo."
            exit 1
        fi

        # Monta a descrição amigável da busca
        if [ -n "$filtro_arquivo" ]; then
            descricao_busca="Busca por conteúdo: $valor | Filtro de arquivo: $filtro_arquivo"
        else
            descricao_busca="Busca por conteúdo: $valor"
        fi
        ;;

    *)
        # "*" significa qualquer valor não previsto
        echo "Erro: modo de busca inválido."
        echo
        mostrar_uso
        exit 1
        ;;
esac

# Verifica se o valor da busca ficou vazio
if [ -z "$valor" ]; then
    echo "Erro: valor de busca não informado."
    exit 1
fi

# Validação simples para MD5
if [ "$modo" = "md5" ]; then
    if ! echo "$valor" | grep -Eq '^[a-f0-9]{32}$'; then
        echo "Erro: hash MD5 inválido."
        exit 1
    fi
fi

# Validação simples para SHA256
if [ "$modo" = "sha256" ]; then
    if ! echo "$valor" | grep -Eq '^[a-f0-9]{64}$'; then
        echo "Erro: hash SHA256 inválido."
        exit 1
    fi
fi

# Validação simples para data
if [ "$modo" = "data" ]; then
    if ! date -d "$valor" >/dev/null 2>&1; then
        echo "Erro: data inválida. Use o formato AAAA-MM-DD."
        exit 1
    fi
fi

# Validação simples para tamanho em bytes
if [ "$modo" = "tamanho" ]; then
    if ! echo "$valor" | grep -Eq '^[0-9]+$'; then
        echo "Erro: tamanho inválido."
        exit 1
    fi
fi

# "mktemp -d" cria um diretório temporário único
tmpdir=$(mktemp -d)

# Arquivo temporário que guardará os resultados brutos da busca
brutos="$tmpdir/brutos.txt"

# Arquivo temporário que guardará os resultados finais
resultados="$tmpdir/resultados.txt"

# Arquivo temporário da saída já formatada
saida_formatada="$tmpdir/saida_formatada.txt"

# Arquivo temporário para contar quantos blocos já terminaram
done_count="$tmpdir/done_count.txt"

# Inicializa o contador de blocos concluídos com 0
echo 0 > "$done_count"

# "trap" apaga o diretório temporário ao sair do script
trap 'rm -rf "$tmpdir"' EXIT

# Função para mostrar a barra de progresso
mostrar_barra() {
    # "$1" recebe quantos blocos já terminaram
    concluidos="$1"

    # "$2" recebe o total de blocos
    total="$2"

    # Evita divisão por zero
    if [ "$total" -eq 0 ]; then
        total=1
    fi

    # Calcula a porcentagem concluída
    porcentagem=$(( concluidos * 100 / total ))

    # Define o tamanho visual da barra
    largura=30

    # Calcula quantos caracteres da barra ficarão preenchidos
    preenchidos=$(( concluidos * largura / total ))

    # Calcula quantos caracteres ficarão vazios
    vazios=$(( largura - preenchidos ))

    # Cria a parte preenchida
    barra_cheia=$(printf "%${preenchidos}s" "" | tr ' ' '#')

    # Cria a parte vazia
    barra_vazia=$(printf "%${vazios}s" "" | tr ' ' '-')

    # "\r" volta ao começo da mesma linha
    printf "\rProgresso: [%s%s] %d%% (%d/%d blocos)" "$barra_cheia" "$barra_vazia" "$porcentagem" "$concluidos" "$total"
}

# Função que faz a busca dentro de um caminho específico
buscar_em_caminho() {
    # "$1" recebe a base onde a busca vai acontecer
    base="$1"

    # "$2" recebe o modo de busca
    modo_local="$2"

    # "$3" recebe o valor procurado
    valor_local="$3"

    # "$4" recebe o arquivo onde os resultados serão gravados
    arquivo_saida="$4"

    # "$5" recebe o arquivo contador de blocos concluídos
    arquivo_contador="$5"

    # "$6" recebe o filtro opcional de nome de arquivo
    filtro_local="$6"

    # Se a base for "/", tratamos separadamente para limitar ao nível 1
    if [ "$base" = "/" ]; then
        case "$modo_local" in
            nome)
                find / -maxdepth 1 -iname "*$valor_local*" 2>/dev/null >> "$arquivo_saida"
                ;;
            data)
                proximo_dia=$(date -d "$valor_local +1 day" +%F 2>/dev/null)
                find / -maxdepth 1 -type f -newermt "$valor_local" ! -newermt "$proximo_dia" 2>/dev/null >> "$arquivo_saida"
                ;;
            tamanho)
                find / -maxdepth 1 -type f -size "${valor_local}c" 2>/dev/null >> "$arquivo_saida"
                ;;
            md5|sha256)
                find / -maxdepth 1 -type f 2>/dev/null >> "$arquivo_saida"
                ;;
            conteudo)
                # Para busca por conteúdo, primeiro coletamos arquivos candidatos
                # Se houver filtro por nome, usamos esse padrão
                if [ -n "$filtro_local" ]; then
                    find / -maxdepth 1 -type f -iname "$filtro_local" 2>/dev/null >> "$arquivo_saida"
                else
                    find / -maxdepth 1 -type f 2>/dev/null >> "$arquivo_saida"
                fi
                ;;
        esac
    else
        case "$modo_local" in
            nome)
                find "$base" -iname "*$valor_local*" 2>/dev/null >> "$arquivo_saida"
                ;;
            data)
                proximo_dia=$(date -d "$valor_local +1 day" +%F 2>/dev/null)
                find "$base" -type f -newermt "$valor_local" ! -newermt "$proximo_dia" 2>/dev/null >> "$arquivo_saida"
                ;;
            tamanho)
                find "$base" -type f -size "${valor_local}c" 2>/dev/null >> "$arquivo_saida"
                ;;
            md5|sha256)
                find "$base" -type f 2>/dev/null >> "$arquivo_saida"
                ;;
            conteudo)
                # Para busca por conteúdo, primeiro coletamos arquivos candidatos
                # Se houver filtro por nome, usamos esse padrão
                if [ -n "$filtro_local" ]; then
                    find "$base" -type f -iname "$filtro_local" 2>/dev/null >> "$arquivo_saida"
                else
                    find "$base" -type f 2>/dev/null >> "$arquivo_saida"
                fi
                ;;
        esac
    fi

    # Esse bloco usa "flock" para evitar disputa entre processos paralelos
    (
        flock -x 200
        atual=$(cat "$arquivo_contador")
        atual=$((atual + 1))
        echo "$atual" > "$arquivo_contador"
    ) 200>"$arquivo_contador.lock"
}

# Mostra o cabeçalho inicial na tela
mostrar_banner
echo
echo "Busca iniciada em todo o sistema"
echo "Modo selecionado: $modo"
echo "$descricao_busca"
echo

# Lista tudo que existe no primeiro nível da raiz "/"
mapfile -t bases < <(find / -mindepth 1 -maxdepth 1 2>/dev/null)

# Adiciona a raiz "/" manualmente ao array
bases=( "/" "${bases[@]}" )

# Conta quantos blocos de busca existirão
total_blocos=${#bases[@]}

# Tenta descobrir quantos núcleos de CPU existem
jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null)

# Se não conseguir descobrir, usa 4 como padrão
[ -z "$jobs" ] && jobs=4

# Se vier 0, corrige para 4
[ "$jobs" -le 0 ] && jobs=4

# Exporta a função para os subprocessos
export -f buscar_em_caminho

# Envia cada base para o xargs em paralelo
printf '%s\n' "${bases[@]}" | xargs -I {} -P "$jobs" bash -c 'buscar_em_caminho "$@"' _ "{}" "$modo" "$valor" "$brutos" "$done_count" "$filtro_arquivo" &

# Guarda o PID do processo em background
pid_busca=$!

# Variável para evitar redesenho repetido da mesma barra
ultimo_concluidos=-1

# Enquanto a busca estiver acontecendo, atualiza a barra
while kill -0 "$pid_busca" 2>/dev/null; do
    concluidos=$(cat "$done_count")
    if [ "$concluidos" -ne "$ultimo_concluidos" ]; then
        mostrar_barra "$concluidos" "$total_blocos"
        ultimo_concluidos="$concluidos"
    fi
    sleep 0.2
done

# Espera o processo terminar completamente
wait "$pid_busca" 2>/dev/null

# Atualiza a barra só se houver mudança real
concluidos=$(cat "$done_count")
if [ "$concluidos" -ne "$ultimo_concluidos" ]; then
    mostrar_barra "$concluidos" "$total_blocos"
fi
echo
echo

# Verifica se o arquivo bruto existe e tem conteúdo
if [ ! -s "$brutos" ]; then
    echo "Busca Concluída"
    echo
    echo "------------------------------------------------------------"
    echo "Resumo da busca"
    echo "------------------------------------------------------------"
    echo "Arquivos comuns          : 0"
    echo "Diretórios               : 0"
    echo "Links simbólicos         : 0"
    echo "Outros tipos             : 0"
    echo "Total de resultados encontrados: 0"
    echo "------------------------------------------------------------"
    exit 1
fi

# Ordena e remove duplicados dos candidatos encontrados
sort -u "$brutos" -o "$brutos"

# Se o modo for busca por hash ou conteúdo, faz filtro adicional
if [ "$modo" = "md5" ] || [ "$modo" = "sha256" ] || [ "$modo" = "conteudo" ]; then
    while IFS= read -r caminho
    do
        if [ -f "$caminho" ]; then
            if [ "$modo" = "md5" ]; then
                hash_calculado=$(md5sum "$caminho" 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
                if [ "$hash_calculado" = "$valor" ]; then
                    echo "$caminho" >> "$resultados"
                fi
            fi

            if [ "$modo" = "sha256" ]; then
                hash_calculado=$(sha256sum "$caminho" 2>/dev/null | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
                if [ "$hash_calculado" = "$valor" ]; then
                    echo "$caminho" >> "$resultados"
                fi
            fi

            if [ "$modo" = "conteudo" ]; then
                # "grep -Iq ." testa se o arquivo parece texto
                # "-I" ignora binários
                # "-q" não mostra saída
                if grep -Iq . "$caminho" 2>/dev/null; then
                    # "grep -Fq" procura o texto literal informado
                    # "-F" trata o valor como texto comum, não regex
                    # "-q" não mostra saída, só retorna sucesso ou erro
                    if grep -Fq "$valor" "$caminho" 2>/dev/null; then
                        echo "$caminho" >> "$resultados"
                    fi
                fi
            fi
        fi
    done < "$brutos"
else
    # Se não for busca por hash nem conteúdo, os resultados finais são os próprios candidatos
    cp "$brutos" "$resultados"
fi

# Se não houver resultados finais, cria arquivo vazio para manter o fluxo
touch "$resultados"

# Remove duplicados do resultado final
sort -u "$resultados" -o "$resultados"

# Conta quantas linhas existem no arquivo de resultados
total_resultados=$(wc -l < "$resultados")

# Cria um contador para numerar os resultados na saída
contador=0

# Cria contadores para o resumo final
arquivos=0
diretorios=0
links=0
outros=0

# Primeiro percorre os resultados para contar os tipos
while IFS= read -r caminho
do
    [ -z "$caminho" ] && continue

    if [ -L "$caminho" ]; then
        links=$((links + 1))
    elif [ -f "$caminho" ]; then
        arquivos=$((arquivos + 1))
    elif [ -d "$caminho" ]; then
        diretorios=$((diretorios + 1))
    else
        outros=$((outros + 1))
    fi
done < "$resultados"

# Monta o resumo final da busca
resumo_saida=$(
    cat <<EOF
Busca Concluída

------------------------------------------------------------
Resumo da busca
------------------------------------------------------------
Arquivos comuns          : $arquivos
Diretórios               : $diretorios
Links simbólicos         : $links
Outros tipos             : $outros
Total de resultados encontrados: $total_resultados

EOF
)

# Mostra o resumo na tela
echo "$resumo_saida"
echo

# Guarda o resumo no arquivo temporário formatado
echo "$resumo_saida" >> "$saida_formatada"
echo >> "$saida_formatada"

# Agora lista os resultados detalhados
while IFS= read -r caminho
do
    [ -z "$caminho" ] && continue

    contador=$((contador + 1))
    nome_item=$(basename "$caminho")
    tipo=$(file -b "$caminho" 2>/dev/null)
    tipo_mime=$(file --mime-type -b "$caminho" 2>/dev/null)
    tamanho_bytes=$(stat -c %s "$caminho" 2>/dev/null)
    tamanho_legivel=$(du -sh "$caminho" 2>/dev/null | cut -f1)
    [ -z "$tamanho_legivel" ] && tamanho_legivel="indisponível"
    permissoes=$(stat -c %A "$caminho" 2>/dev/null)
    dono=$(stat -c %U "$caminho" 2>/dev/null)
    grupo=$(stat -c %G "$caminho" 2>/dev/null)
    modificado=$(stat -c %y "$caminho" 2>/dev/null)
    inode=$(stat -c %i "$caminho" 2>/dev/null)
    n_links=$(stat -c %h "$caminho" 2>/dev/null)

    if [ -L "$caminho" ]; then
        link_simbolico="sim"
        aponta_para=$(readlink "$caminho")
    else
        link_simbolico="não"
        aponta_para="não aplicável"
    fi

    if [ -f "$caminho" ]; then
        sha256=$(sha256sum "$caminho" 2>/dev/null | awk '{print $1}')
        md5=$(md5sum "$caminho" 2>/dev/null | awk '{print $1}')
        [ -z "$sha256" ] && sha256="indisponível"
        [ -z "$md5" ] && md5="indisponível"
    else
        sha256="não aplicável"
        md5="não aplicável"
    fi

    bloco_saida=$(
        cat <<EOF
------------------------------------------------------------
Resultado #$contador de $total_resultados
------------------------------------------------------------
Caminho completo : $caminho
Nome             : $nome_item
Tipo             : $tipo
Tipo MIME        : $tipo_mime
Tamanho (bytes)  : $tamanho_bytes
Tamanho legível  : $tamanho_legivel
Permissões       : $permissoes
Dono             : $dono
Grupo            : $grupo
Modificado em    : $modificado
Inode            : $inode
Nº de links      : $n_links
Link simbólico   : $link_simbolico
Aponta para      : $aponta_para
SHA256           : $sha256
MD5              : $md5

EOF
    )

    echo "$bloco_saida"
    echo "$bloco_saida" >> "$saida_formatada"

done < "$resultados"

# Pergunta ao usuário somente no final se deseja exportar o relatório
read -p "Deseja exportar o relatório? (Y/N): " exportar

# Converte a resposta para maiúscula
exportar=$(echo "$exportar" | tr '[:lower:]' '[:upper:]')

# Se o usuário escolheu "Y", salva o relatório
if [ "$exportar" = "Y" ]; then
    relatorio="$PWD/relatorio_omnisearch_$(date +%Y%m%d_%H%M%S).txt"

    {
        mostrar_banner
        echo
        echo "Relatório de Busca"
        echo
        echo "Modo selecionado: $modo"
        echo "$descricao_busca"
        echo
    } > "$relatorio"

    cat "$saida_formatada" >> "$relatorio"
    echo "Relatório salvo em: $relatorio"
else
    echo "Relatório não exportado."
fi
