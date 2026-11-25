# El cerebro vs las emociones

## Información del proyecto

- Autor: Dylan Madrigal Jiménez
- Carné: C5G687
- Universidad de Costa Rica
- Escuela de Matemática
- Curso: CA-0204 - Herramientas de Ciencia de Datos I
- II ciclo, 2026

## Descripción

Este proyecto analiza las respuestas emocionales y las
señales electroencefalográficas (EEG) de 28 participantes
durante cuatro videojuegos, utilizando el conjunto de
datos GAMEEMO.

Se estudian las puntuaciones de valencia y activación
emocional del cuestionario Self-Assessment Manikin (SAM)
y las potencias espectrales de las bandas alfa y beta.

## Objetivo

Comparar los resultados entre las respuestas emocionales
registradas mediante los cuestionarios SAM y las
potencias espectrales alfa y beta obtenidas de las
señales EEG durante cuatro videojuegos, con énfasis
en las diferencias entre Slender: The Arrival y
Goat Simulator.

## Fuente de los datos

Los datos utilizados provienen de GAMEEMO, desarrollado
por Alakus et al. (2020).

- Artículo científico:
  https://doi.org/10.1016/j.bspc.2020.101951

- Conjunto de datos:
  https://doi.org/10.17632/b3pn4kwpmn.3

Se utilizan los registros EEG preprocesados de los
28 participantes durante los siguientes videojuegos:

| Código | Videojuego |
|--------|------------|
| G1 | Train Sim World |
| G2 | Unravel |
| G3 | Slender: The Arrival |
| G4 | Goat Simulator |

## Requisitos

Para reproducir el proyecto se requiere:

- R
- RStudio (recomendado)
- Quarto
- Una distribución de LaTeX, como TinyTeX
- Git

Los paquetes de R necesarios son:

- tidyverse
- readxl
- gsignal

Para instalarlos, ejecutar en la consola de R:

```r
install.packages(c("tidyverse", "readxl", "gsignal"))
```

## Estructura del proyecto

```text
Proyecto individual/
├── cod/
│   ├── 01.exploracion.datos.SAM.R
│   ├── 02.exploracion.datos.EEG.R
│   └── 03.comparacion.EEG.SAM.R
├── config/
├── data/
│   ├── datos jugadores EEG/
│   └── datos.SAM/
│       └── GAMEEMO_respuestas_SAM_revision.xlsx
├── info/
│   ├── Informe individual.qmd
│   └── Informe individual.pdf
├── res/
├── .gitignore
└── README.md
```

- `cod/`: scripts de procesamiento y análisis.
- `config/`: carpeta reservada para configuraciones.
- `data/`: fuentes de datos EEG y SAM.
- `info/`: documento Quarto e informe final.
- `res/`: gráficos y tablas generados mediante R.

## Preparación de los datos

Debido al tamaño de los registros EEG, estos no se
incluyen directamente en el repositorio de GitHub.

Para reproducir el análisis:

1. Descargar el conjunto de datos GAMEEMO.
2. Extraer los archivos EEG preprocesados.
3. Crear la carpeta `data/datos jugadores EEG/`.
4. Colocar dentro de ella los archivos CSV
   correspondientes a los 28 participantes y los
   cuatro videojuegos.

Los archivos deben conservar sus identificadores
originales de participante y videojuego, por ejemplo:

```text
S01G1AllChannels.csv
S01G2AllChannels.csv
S01G3AllChannels.csv
S01G4AllChannels.csv
```

Se requieren 112 archivos CSV preprocesados.
El script realiza una búsqueda recursiva dentro
de la carpeta de datos EEG.

Las respuestas SAM se encuentran en el archivo
`GAMEEMO_respuestas_SAM_revision.xlsx`, dentro de
`data/datos.SAM/`.

## Reproducción del análisis

Abrir el archivo .Rproj del repositorio mediante
RStudio y trabajar desde la raíz del proyecto.

Ejecutar los scripts en el siguiente orden:

```r
source("cod/01.exploracion.datos.SAM.R")
source("cod/02.exploracion.datos.EEG.R")
source("cod/03.comparacion.EEG.SAM.R")
```

### Script 01 - Exploración de datos SAM

Importa las respuestas emocionales, calcula las
medianas de valencia y activación y genera el gráfico
comparativo de los cuatro videojuegos.

### Script 02 - Procesamiento de señales EEG

Importa los registros EEG preprocesados y estima
la densidad espectral de potencia mediante el método
de Welch.

Utiliza los siguientes parámetros:

- Frecuencia de muestreo: 128 Hz.
- Longitud de los segmentos: 256 muestras.
- Ventana Hamming.
- Solapamiento: 50 %.
- Transformada rápida de Fourier: 256 puntos.
- Banda alfa: 8-12 Hz.
- Banda beta: 12-30 Hz.

Las potencias espectrales se obtienen mediante la
regla del trapecio.

### Script 03 - Comparación EEG y SAM

Integra las potencias espectrales con las respuestas
emocionales del cuestionario SAM.

Selecciona ocho electrodos frontales y frontocentrales,
calcula medianas individuales y grupales y realiza una
comparación pareada entre Slender y Goat Simulator.

## Archivos generados

Los resultados se almacenan en la carpeta `res/`.

### Tablas CSV

- `potencias_eeg.csv`
- `resumen_frontal.csv`
- `comparacion_juegos.csv`
- `comparacion_pareada.csv`
- `resumen_diferencias.csv`

### Gráficos

- `01_resumen_sam_bolitas.png`
- `02_eeg_preprocesado_1_minuto.png`
- `03_eeg_preprocesado_2_segundos.png`
- `04_espectro_welch_AF3.png`
- `05_eeg_slender_vs_goat.png`
- `06_lineas_potencias_eeg.png`

## Generación del informe

Una vez ejecutados los tres scripts, abrir el documento
Quarto ubicado en la carpeta `info/` y seleccionar
Render para generar el informe en formato PDF.

También puede generarse desde la terminal:

```bash
quarto render info/Individual_MadrigalJimenezDylan_HerramientasDatosI_2026.qmd --to pdf
```

## Alcance de la investigación

El análisis es exploratorio y descriptivo. Los
resultados no permiten establecer relaciones causales,
confirmar asociaciones estadísticas ni demostrar
equivalencia entre los procesos cognitivos de los
participantes durante ambos videojuegos.

## Control de versiones

El proyecto utiliza Git y GitHub para registrar
los cambios realizados durante su desarrollo.

Los archivos temporales de RStudio y los registros
EEG de gran tamaño se excluyen mediante `.gitignore`.