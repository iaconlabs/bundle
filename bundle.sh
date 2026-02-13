#!/bin/bash

# ==============================================================================
# Script: bundle.sh (v0.1.1)
# Descripción: Consolida código fuente con rutas de entrada/salida configurables.
# ==============================================================================

# Valores por defecto
OUTPUT_FILE="bundle.txt"
INPUT_DIR="."
STATS_TMP=".stats_tmp"
ONLY_STATS=false
USE_GITIGNORE=false
REGEX_EXCLUSION="^$"

show_help() {
    echo "Uso: $0 [OPCIONES] [PATRÓN_REGEX_EXCLUSIÓN]"
    echo ""
    echo "Opciones:"
    echo "  -o FILE           Archivo de destino (por defecto: bundle.txt)."
    echo "  -i DIR            Directorio de origen a procesar (por defecto: .)."
    echo "  -s, --stats-only  Muestra solo las estadísticas sin crear el archivo."
    echo "  -g, --gitignore   Ignora archivos según las reglas de .gitignore."
    echo "  -h, --help        Muestra este mensaje de ayuda."
    echo ""
    echo "Ejemplo:"
    echo "  $0 -i ./src -o proyecto.txt \"_test\""
    exit 0
}

# --- Procesamiento de Argumentos (getopts no se usa para permitir flags largos y posicionales) ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help ;;
        -s|--stats-only) ONLY_STATS=true; shift ;;
        -g|--gitignore) USE_GITIGNORE=true; shift ;;
        -o) OUTPUT_FILE="$2"; shift 2 ;;
        -i) INPUT_DIR="$2"; shift 2 ;;
        -*) echo "❌ Error: Opción no reconocida '$1'"; exit 1 ;;
        *) REGEX_EXCLUSION="$1"; shift ;; # El patrón regex suele ser el último argumento
    esac
done

# Validar que el directorio de entrada existe
if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ Error: El directorio de entrada '$INPUT_DIR' no existe."
    exit 1
fi

# Detectar si estamos en un repositorio Git (buscando desde el INPUT_DIR)
IS_GIT=$(git -C "$INPUT_DIR" rev-parse --is-inside-work-tree 2>/dev/null)

# --- Preparación de Salida ---
if [ "$ONLY_STATS" = false ]; then
    echo "📦 Iniciando bundle en: $OUTPUT_FILE"
    FECHA_HORA=$(date "+%Y-%m-%d %H:%M:%S")
    {
        echo "================================================================================"
        echo " GENERADO POR: bundle.sh"
        echo " ORIGEN: $INPUT_DIR"
        echo " FECHA Y HORA: $FECHA_HORA"
        echo "================================================================================"
        echo -e "\n"
    } > "$OUTPUT_FILE"
else
    echo "📊 Generando reporte estadístico del directorio: $INPUT_DIR"
fi

[ "$USE_GITIGNORE" = true ] && [ "$IS_GIT" = "true" ] && echo "🛡️  Respetando reglas de .gitignore"
echo "🔍 Patrón de exclusión: $REGEX_EXCLUSION"
> "$STATS_TMP"

bundle_files() {
    # Buscamos archivos dentro de INPUT_DIR
    find "$INPUT_DIR" -type f \( -name "*.go" -o -name "go.mod" -o -name "Makefile" -o -name "*.yml" \) 2>/dev/null | \
    grep -vE "(\.git|vendor|bin|${OUTPUT_FILE})" | \
    grep -vE "${REGEX_EXCLUSION}" | while read -r file; do
        
        if [[ -f "$file" ]]; then
            # Validación de Gitignore (usando el contexto del repo de INPUT_DIR)
            if [ "$USE_GITIGNORE" = true ] && [ "$IS_GIT" = "true" ]; then
                if git -C "$INPUT_DIR" check-ignore -q "${file#$INPUT_DIR/}" 2>/dev/null || git -C "$(dirname "$file")" check-ignore -q "$(basename "$file")" 2>/dev/null; then
                    continue 
                fi
            fi

            # Estadísticas
            ext="${file##*.}"
            [[ "$file" == *"Makefile"* ]] && ext="Makefile"
            loc=$(wc -l < "$file")
            echo "$ext $loc" >> "$STATS_TMP"

            # Escritura
            if [ "$ONLY_STATS" = false ]; then
                echo "  -> Agregando: $file"
                GIT_INFO=""
                if [ "$IS_GIT" = "true" ]; then
                    # Obtener log relativo al archivo
                    GIT_LOG=$(git -C "$(dirname "$file")" log -1 --format="%an | %ar | %h" -- "$(basename "$file")" 2>/dev/null)
                    GIT_INFO="LAST MOD: ${GIT_LOG:-Untracked file}"
                fi
                {
                    echo "--------------------------------------------------------------------------------"
                    echo "FILE: $file"
                    echo "$GIT_INFO"
                    echo "--------------------------------------------------------------------------------"
                    cat "$file"
                    echo -e "\n\n"
                } >> "$OUTPUT_FILE"
            fi
        fi
    done
}

bundle_files

# --- Reporte Final ---
if [ -s "$STATS_TMP" ]; then
    echo -e "\n📊 --- REPORTE DE MÉTRICAS ---"
    echo -e "EXTENSIÓN\tARCHIVOS\tLÍNEAS (LoC)"
    echo -e "---------\t--------\t-----------"
    awk '{files[$1]++; lines[$1]+=$2} END {for (i in files) printf "%-10s\t%-8d\t%-11d\n", i, files[i], lines[i]}' "$STATS_TMP" | sort -rn -k3
    echo -e "---------\t--------\t-----------"
    printf "%-10s\t%-8s\t%-11s\n" "TOTAL" "$(awk 'END {print NR}' "$STATS_TMP")" "$(awk '{s+=$2} END {print s}' "$STATS_TMP")"
    
    rm -f "$STATS_TMP"
    [ "$ONLY_STATS" = false ] && echo -e "\n✅ Bundle completado. Archivo: $OUTPUT_FILE ($(du -h "$OUTPUT_FILE" | cut -f1))"
else
    echo "⚠️  No se encontraron archivos procesables."
    rm -f "$STATS_TMP"
    [ -f "$OUTPUT_FILE" ] && [ "$ONLY_STATS" = false ] && rm "$OUTPUT_FILE"
    exit 1
fi
