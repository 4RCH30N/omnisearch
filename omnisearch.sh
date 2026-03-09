#!/bin/bash

mostrar_banner() {
    echo "========================================================================================"
    echo
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

mostrar_uso() {
    echo "Uso:"
    echo "  $0 --nome VALOR"
    echo "  $0 --md5 HASH"
    echo "  $0 --sha256 HASH"
    echo "  $0 --data AAAA-MM-DD"
    echo "  $0 --tamanho VALOR_EM_BYTES"
    echo "  $0 --tamanho -L VALOR_LEGIVEL"
    echo "  $0 --conteudo TEXTO"
    echo "  $0 --extensao EXT"

    echo
    echo "Exemplos:"
    echo "  $0 --nome passwd"
    echo "  $0 --md5 44d88612fea8a8f36de82e1278abb02f"
    echo "  $0 --sha256 HASH_AQUI"
    echo "  $0 --data 2026-03-09"
    echo "  $0 --tamanho 1024"
    echo "  $0 --tamanho -L 10M"
    echo "  $0 --conteudo FLAG{"
    echo "  $0 --extensao conf"
    echo
    echo "Observação: Alguns arquivos podem não aparecer devido a permissão. Lembrar de usar o sudo!"
}

converter_tamanho() {
    entrada="$1"
    unidade=$(echo "$entrada" | sed 's/[0-9.]//g' | tr '[:lower:]' '[:upper:]')
    numero=$(echo "$entrada" | sed 's/[^0-9.]//g')

    if [ -z "$numero" ]; then
        echo ""
        return
    fi

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

modo=""
valor=""
descricao_busca=""

if [ $# -lt 2 ]; then
    echo
    mostrar_banner
    echo
    mostrar_uso
    exit 1
fi

case "$1" in
    --nome)
        modo="nome"
        valor="$2"
        descricao_busca="Busca por nome: $valor"
        ;;

    --md5)
        modo="md5"
        valor=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        descricao_busca="Busca por MD5: $valor"
        ;;

    --sha256)
        modo="sha256"
        valor=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        descricao_busca="Busca por SHA256: $valor"
        ;;

    --data)
        modo="data"
        valor="$2"
        descricao_busca="Busca por data de modificação: $valor"
        ;;

    --tamanho)
        modo="tamanho"

        if [ "$2" = "-L" ]; then
            tamanho_legivel_informado="$3"

            if [ -z "$tamanho_legivel_informado" ]; then
                echo "Erro: informe o tamanho legível após -L."
                echo
                mostrar_uso
                exit 1
            fi

            valor=$(converter_tamanho "$tamanho_legivel_informado")

            if [ -z "$valor" ]; then
                echo "Erro: tamanho legível inválido."
                exit 1
            fi

            descricao_busca="Busca por tamanho: $tamanho_legivel_informado ($valor bytes)"
        else
            valor="$2"
            descricao_busca="Busca por tamanho: $valor bytes"
        fi
        ;;

    --conteudo)
        modo="conteudo"
        valor="$2"
        descricao_busca="Busca por conteúdo: $valor"
        ;;

    --extensao)
        modo="extensao"
        valor="$2"
        valor="${valor#.}"
        valor=$(echo "$valor" | tr '[:upper:]' '[:lower:]')
        descricao_busca="Busca por extensão: .$valor"
        ;;

    *)
        echo "Erro: modo de busca inválido."
        echo
        mostrar_uso
        exit 1
        ;;
esac

if [ -z "$valor" ]; then
    echo "Erro: valor de busca não informado."
    exit 1
fi

if [ "$modo" = "md5" ]; then
    if ! echo "$valor" | grep -Eq '^[a-f0-9]{32}$'; then
        echo "Erro: hash MD5 inválido."
        exit 1
    fi
fi

if [ "$modo" = "sha256" ]; then
    if ! echo "$valor" | grep -Eq '^[a-f0-9]{64}$'; then
        echo "Erro: hash SHA256 inválido."
        exit 1
    fi
fi

if [ "$modo" = "data" ]; then
    if ! date -d "$valor" >/dev/null 2>&1; then
        echo "Erro: data inválida. Use o formato AAAA-MM-DD."
        exit 1
    fi
fi

if [ "$modo" = "tamanho" ]; then
    if ! echo "$valor" | grep -Eq '^[0-9]+$'; then
        echo "Erro: tamanho inválido."
        exit 1
    fi
fi

if [ "$modo" = "extensao" ]; then
    if ! echo "$valor" | grep -Eq '^[a-zA-Z0-9._+-]+$'; then
        echo "Erro: extensão inválida."
        exit 1
    fi
fi

tmpdir=$(mktemp -d)
brutos="$tmpdir/brutos.txt"
resultados="$tmpdir/resultados.txt"
saida_formatada="$tmpdir/saida_formatada.txt"
done_count="$tmpdir/done_count.txt"

echo 0 > "$done_count"

trap 'rm -rf "$tmpdir"' EXIT

mostrar_barra() {
    concluidos="$1"
    total="$2"

    if [ "$total" -eq 0 ]; then
        total=1
    fi

    porcentagem=$(( concluidos * 100 / total ))
    largura=30
    preenchidos=$(( concluidos * largura / total ))
    vazios=$(( largura - preenchidos ))

    barra_cheia=$(printf "%${preenchidos}s" "" | tr ' ' '#')
    barra_vazia=$(printf "%${vazios}s" "" | tr ' ' '-')

    printf "\rProgresso: [%s%s] %d%% (%d/%d blocos)" "$barra_cheia" "$barra_vazia" "$porcentagem" "$concluidos" "$total"
}

buscar_em_caminho() {
    base="$1"
    modo_local="$2"
    valor_local="$3"
    arquivo_saida="$4"
    arquivo_contador="$5"

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
                find / -maxdepth 1 -type f 2>/dev/null >> "$arquivo_saida"
                ;;
            extensao)
                find / -maxdepth 1 -type f -iname "*.$valor_local" 2>/dev/null >> "$arquivo_saida"
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
                find "$base" -type f 2>/dev/null >> "$arquivo_saida"
                ;;
            extensao)
                find "$base" -type f -iname "*.$valor_local" 2>/dev/null >> "$arquivo_saida"
                ;;
        esac
    fi

    (
        flock -x 200
        atual=$(cat "$arquivo_contador")
        atual=$((atual + 1))
        echo "$atual" > "$arquivo_contador"
    ) 200>"$arquivo_contador.lock"
}

mostrar_banner
echo
echo "Busca iniciada em todo o sistema"
echo "Modo selecionado: $modo"
echo "$descricao_busca"
echo

mapfile -t bases < <(find / -mindepth 1 -maxdepth 1 2>/dev/null)
bases=( "/" "${bases[@]}" )
total_blocos=${#bases[@]}

jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null)
[ -z "$jobs" ] && jobs=4
[ "$jobs" -le 0 ] && jobs=4

export -f buscar_em_caminho

printf '%s\n' "${bases[@]}" | xargs -I {} -P "$jobs" bash -c 'buscar_em_caminho "$@"' _ "{}" "$modo" "$valor" "$brutos" "$done_count" &

pid_busca=$!
ultimo_concluidos=-1

while kill -0 "$pid_busca" 2>/dev/null; do
    concluidos=$(cat "$done_count")
    if [ "$concluidos" -ne "$ultimo_concluidos" ]; then
        mostrar_barra "$concluidos" "$total_blocos"
        ultimo_concluidos="$concluidos"
    fi
    sleep 0.2
done

wait "$pid_busca" 2>/dev/null

concluidos=$(cat "$done_count")
if [ "$concluidos" -ne "$ultimo_concluidos" ]; then
    mostrar_barra "$concluidos" "$total_blocos"
fi
echo
echo

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

sort -u "$brutos" -o "$brutos"

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
                if grep -Iq . "$caminho" 2>/dev/null; then
                    if grep -Fq "$valor" "$caminho" 2>/dev/null; then
                        echo "$caminho" >> "$resultados"
                    fi
                fi
            fi
        fi
    done < "$brutos"
else
    cp "$brutos" "$resultados"
fi

touch "$resultados"
sort -u "$resultados" -o "$resultados"

total_resultados=$(wc -l < "$resultados")
contador=0

arquivos=0
diretorios=0
links=0
outros=0

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

echo "$resumo_saida"
echo

echo "$resumo_saida" >> "$saida_formatada"
echo >> "$saida_formatada"

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

read -p "Deseja exportar o relatório? (Y/N): " exportar
exportar=$(echo "$exportar" | tr '[:lower:]' '[:upper:]')

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
