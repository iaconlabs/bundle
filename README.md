# Bundle.sh

A straightforward Bash script to consolidate source code files into a single, formatted text file. Ideal for quick audits, code reviews.  

Features

  - Git Integration: Automatically includes the author, date, and hash of the last commit for each file.
  - Metrics: Generates a report of Lines of Code (LoC) broken down by file extension.
  - Filtering: Supports exclusion via regex patterns and respects .gitignore rules.
  - Configurable: Define custom input directories and output filenames.

## Usage

```Bash
$ sh ./tools/bundle.sh [OPTIONS] [EXCLUSION_PATTERN]
```

## Common Options

  * -i: Input directory (default: .).

  * -o: Output filename (default: bundle.txt).

  * -s: Statistics only (does not generate the bundle file).

  * -g: Respect .gitignore rules.

  * -h: Show full help message.

## Examples

Bundle the entire project excluding tests:

```Bash
$ sh ./tools/bundle.sh "_test\.go"
```


View stats for a specific folder while respecting gitignore:

```Bash
$ sh ./tools/bundle.sh -i ./adapter -s -g
```


## Requirements

  - Bash

  - Git (optional, for metadata and ignore rules)

  - Awk (for statistics)


---

Un script sencillo en Bash para consolidar archivos de código fuente en un único archivo de texto formateado. Útil para auditorías rápidas, revisiones de código.  


Características

  - Detección de Git: Incluye autor, fecha y hash del último commit de cada archivo.

  - Métricas: Genera un reporte de líneas de código (LoC) por extensión.

  - Filtros: Soporta exclusión mediante expresiones regulares y respeto a reglas de .gitignore.

  - Configurable: Permite definir directorios de entrada y archivos de salida.

Uso

```Bash
$ sh ./tools/bundle.sh [OPCIONES] [PATRÓN_RECHAZO]
```

Opciones comunes

  * -i: Directorio de origen (por defecto: .).
  * -o: Nombre del archivo de salida (por defecto: bundle.txt).
  * -s: Solo muestra estadísticas, no genera el archivo.
  * -g: Ignora archivos listados en .gitignore.
  * -h: Muestra la ayuda completa.

Ejemplos

Consolidar todo el proyecto ignorando tests:

```Bash
$ sh ./tools/bundle.sh "_test\.go"
```

Ver solo estadísticas de una carpeta específica respetando el gitignore:

```Bash
$sh ./tools/bundle.sh -i ./adapter -s -g
```

Requisitos

  * Bash
  * Git (opcional, para metadatos e ignore)
  * Awk (para las estadísticas)
