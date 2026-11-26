# El cerebro vs las emociones

## Información del proyecto

- Autor: Dylan Madrigal Jiménez
- Carné: C5G687
- Universidad de Costa Rica
- Escuela de Matemática
- Curso: CA-0204 - Herramientas de Ciencia de Datos I
- II ciclo, 2026

## Descripción

Este proyecto analiza las respuestas emocionales y las señales electroencefalográficas (EEG) de 28 participantes durante cuatro videojuegos, utilizando el conjunto de datos GAMEEMO.

Se estudian las puntuaciones de valencia y activación emocional del cuestionario Self-Assessment Manikin (SAM) y las potencias espectrales de las bandas alfa y beta.

## Objetivo

Comparar los resultados entre las respuestas emocionales registradas mediante los cuestionarios SAM y las potencias espectrales alfa y beta obtenidas de las señales EEG durante cuatro videojuegos, con énfasis en las diferencias entre Slender: The Arrival y Goat Simulator.

## Fuente de los datos

Los datos utilizados provienen de GAMEEMO, desarrollado por Alakus et al. (2020).

- Artículo científico:
  https://doi.org/10.1016/j.bspc.2020.101951

- Conjunto de datos:
  https://doi.org/10.17632/b3pn4kwpmn.3

Se utilizan los registros EEG preprocesados de los 28 participantes durante los siguientes videojuegos:

| Código | Videojuego |
|--------|------------|
| G1 | Train Sim World |
| G2 | Unravel |
| G3 | Slender: The Arrival |
| G4 | Goat Simulator |

## Requisitos

Para reproducir el proyecto se requiere:

- R.
- RStudio (recomendado).
- Quarto.
- Una distribución de LaTeX, como TinyTeX.
- Git.

Los paquetes de R necesarios son:

- tidyverse
- readxl
- gsignal
- tinytable

Para instalarlos, ejecutar en la consola de R:

```r
install.packages(c("tidyverse", "readxl", "gsignal", "tinytable"))
```

En caso de no contar con una distribución de LaTeX, puede instalarse TinyTeX desde la terminal mediante:

```bash
quarto install tinytex
```

## Estructura del proyecto

```text
Proyecto individual/
├── cod/
│   ├── 01.exploracion.datos.SAM.R
│   ├── 02.exploracion.datos.EEG.R
│   └── 03.comparacion.EEG.SAM.R
├── config/
│   └── README.md
├── data/
│   ├── datos jugadores EEG/
│   └── datos.SAM/
│       └── GAMEEMO_respuestas_SAM_revision.xlsx
├── info/
│   ├── Individual_MadrigalJimenezDylan_HerramientasDatosI_2026.qmd
│   └── Individual_MadrigalJimenezDylan_HerramientasDatosI_2026.pdf
├── res/
│   ├── 01_resumen_sam_bolitas.png
│   ├── 02_eeg_preprocesado_1_minuto.png
│   ├── 03_eeg_preprocesado_2_segundos.png
│   ├── 04_espectro_welch_AF3.png
│   ├── 05_eeg_slender_vs_goat.png
│   ├── 06_lineas_potencias_eeg.png
│   ├── comparacion_juegos.csv
│   ├── comparacion_pareada.csv
│   ├── potencias_eeg.csv
│   ├── resumen_diferencias.csv
│   └── resumen_frontal.csv
├── .gitignore
├── Archivo de proyecto .Rproj
└── README.md
```

### Descripción de las carpetas

- `cod/`: scripts de procesamiento y análisis de datos.
- `config/`: documentación sobre la configuración y los parámetros del proyecto.
- `data/`: fuentes de datos EEG y respuestas emocionales SAM.
- `info/`: documento fuente de Quarto e informe final en formato PDF.
- `res/`: gráficos y tablas generados mediante los scripts de R.

## Preparación de los datos

Debido al tamaño de los registros EEG, estos no se incluyen directamente en el repositorio de GitHub.

Para reproducir el análisis:

1. Descargar el conjunto de datos GAMEEMO desde el enlace indicado en la sección de fuentes.
2. Extraer los archivos EEG preprocesados.
3. Crear la carpeta `data/datos jugadores EEG/`.
4. Colocar dentro de ella los archivos CSV preprocesados correspondientes a los 28 participantes y los cuatro videojuegos.

Los archivos deben conservar sus identificadores originales de participante y videojuego. Por ejemplo:

```text
S01G1AllChannels.csv
S01G2AllChannels.csv
S01G3AllChannels.csv
S01G4AllChannels.csv
```

Se requieren 112 archivos CSV preprocesados. El script realiza una búsqueda recursiva dentro de la carpeta de datos EEG.

Las respuestas emocionales SAM se encuentran disponibles en el repositorio mediante el archivo `GAMEEMO_respuestas_SAM_revision.xlsx`, ubicado dentro de `data/datos.SAM/`.

## Configuración del proyecto

El proyecto no requiere archivos de configuración externos. Los parámetros del procesamiento EEG y del análisis estadístico se encuentran definidos y documentados dentro de los respectivos scripts de la carpeta `cod/`.

La carpeta `config/` contiene un archivo README que documenta esta decisión.

## Reproducción del análisis

Abrir el archivo `.Rproj` mediante RStudio y trabajar desde la raíz del proyecto.

Una vez instalados los paquetes y preparados los datos, ejecutar los scripts en el siguiente orden desde la consola de R:

```r
source("cod/01.exploracion.datos.SAM.R")
source("cod/02.exploracion.datos.EEG.R")
source("cod/03.comparacion.EEG.SAM.R")
```

El orden de ejecución es importante, ya que el tercer script utiliza los resultados del procesamiento de las señales EEG.

### Script 01 - Exploración de datos SAM

Importa las respuestas emocionales de los participantes, revisa la estructura de los datos, calcula las medianas de valencia y activación y genera un gráfico comparativo de los cuatro videojuegos.

### Script 02 - Procesamiento de señales EEG

Importa los registros EEG preprocesados y estima la densidad espectral de potencia mediante el método de Welch.

Los parámetros utilizados son:

| Parámetro | Valor |
|-----------|-------|
| Frecuencia de muestreo | 128 Hz |
| Longitud de los segmentos | 256 muestras |
| Duración de los segmentos | 2 segundos |
| Tipo de ventana | Hamming |
| Solapamiento | 50 % |
| Transformada rápida de Fourier | 256 puntos |
| Banda alfa | 8-12 Hz |
| Banda beta | 12-30 Hz |

Las potencias espectrales de ambas bandas se obtienen mediante la regla del trapecio.

El script genera una tabla con las potencias espectrales por participante, videojuego y electrodo, así como gráficos ilustrativos del procesamiento EEG.

### Script 03 - Comparación EEG y SAM

Integra las potencias espectrales con las respuestas emocionales del cuestionario SAM.

Selecciona los siguientes ocho electrodos frontales y frontocentrales:

- AF3 y AF4.
- F3 y F4.
- F7 y F8.
- FC5 y FC6.

Calcula las medianas de potencia por participante y videojuego, las medianas grupales y las diferencias individuales entre Slender y Goat Simulator.

También genera los gráficos de comparación grupal e individual de las potencias espectrales.

## Archivos generados

Los resultados del procesamiento y análisis se almacenan en la carpeta `res/`.

### Tablas CSV

| Archivo | Contenido |
|---------|-----------|
| `potencias_eeg.csv` | Potencias alfa y beta por participante, videojuego y electrodo. |
| `resumen_frontal.csv` | Resumen de las potencias espectrales frontales por participante y videojuego. |
| `comparacion_juegos.csv` | Medianas grupales de valencia, activación y potencias espectrales. |
| `comparacion_pareada.csv` | Comparación individual entre Slender y Goat Simulator. |
| `resumen_diferencias.csv` | Medianas de las diferencias individuales entre ambos videojuegos. |

### Gráficos

| Archivo | Contenido |
|---------|-----------|
| `01_resumen_sam_bolitas.png` | Distribución de las respuestas de valencia y activación emocional. |
| `02_eeg_preprocesado_1_minuto.png` | Señales EEG preprocesadas durante un minuto. |
| `03_eeg_preprocesado_2_segundos.png` | Segmento EEG de dos segundos. |
| `04_espectro_welch_AF3.png` | Densidad espectral de potencia mediante el método de Welch. |
| `05_eeg_slender_vs_goat.png` | Comparación grupal de las potencias alfa y beta. |
| `06_lineas_potencias_eeg.png` | Comparación individual de las potencias espectrales. |

## Generación del informe

Una vez ejecutados los tres scripts, abrir el documento Quarto ubicado en la carpeta `info/` y seleccionar Render para generar el informe en formato PDF.

También puede generarse desde la terminal, utilizando el siguiente comando desde la raíz del proyecto:

```bash
quarto render info/Individual_MadrigalJimenezDylan_HerramientasDatosI_2026.qmd --to pdf
```

El informe contiene la introducción, el objetivo, la metodología, los resultados, la interpretación final, las limitaciones, las referencias bibliográficas y los anexos metodológicos.

## Principales resultados

Slender y Goat Simulator presentaron diferencias marcadas en las puntuaciones de valencia, pero medianas relativamente cercanas en activación emocional y potencia espectral.

| Variable | Slender | Goat Simulator |
|----------|---------|----------------|
| Valencia | 3 | 7 |
| Activación | 6,5 | 6 |
| Potencia alfa | 7,68 | 8,11 |
| Potencia beta | 20,2 | 19,4 |

Desde una perspectiva descriptiva, el comportamiento grupal de las potencias espectrales presenta una cercanía semejante a la observada en la activación emocional, pese a las diferencias en el agrado declarado.

## Alcance y limitaciones

El análisis es exploratorio y descriptivo. La investigación se limita a 28 participantes, ocho electrodos y dos bandas espectrales.

Los resultados no permiten establecer relaciones causales, confirmar asociaciones estadísticas ni demostrar equivalencia entre los procesos cognitivos de los participantes durante ambos videojuegos.

## Control de versiones

El proyecto utiliza Git y GitHub para registrar los cambios realizados durante su desarrollo.

Los archivos temporales de RStudio y los registros EEG de gran tamaño se excluyen mediante el archivo `.gitignore`.