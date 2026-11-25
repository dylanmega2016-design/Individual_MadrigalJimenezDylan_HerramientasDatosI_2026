# -------------------------------------------------------------------------
# Proyecto individual - Herramientas de Ciencia de Datos I
# Script 02: Exploración de datos electroencefalográficos (EEG) 
#
# Objetivo: calcular las potencias espectrales de las bandas
# alfa y beta mediante el método de Welch.
#
# Fuente de datos: GAMEEMO (Alakuş et al., 2020).
# Referencia metodológica: Welch (1967).
# -------------------------------------------------------------------------

# Librerías necesarias
library(tidyverse)
library(gsignal) # Estimación espectral mediante el método de Welch

# Buscamos todos los archivos CSV que contienen señales EEG preprocesadas.
rutas.eeg <- list.files(
  "data/datos jugadores EEG",
  pattern = "AllChannels.*\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)

# -------------------------------------------------------------------------
# Cálculo de las potencias espectrales mediante el método de Welch
# -------------------------------------------------------------------------
calcular.potencias <- function(datos, electrodo) { 
  # Extraemos la señal correspondiente al electrodo seleccionado
  senal <- datos[[electrodo]] 

  # Estimamos la densidad espectral de potencia mediante Welch,
  # utilizando ventanas de 2 segundos con un solapamiento del 50 %
  resultado.welch <- gsignal::pwelch( 
    senal,
    fs = 128,
    window = 256, # Aqui significa que por cada segmento toma 256 valores, como se recibe 128 por segundo, estamos segmentando por cada 2 segundos
    overlap = 0.5,
    nfft = 256
  )
  
  # Organizamos las frecuencias y sus densidades espectrales de potencia en una tabla
  espectro <- tibble( 
    frecuencia = resultado.welch$freq,
    densidad.potencia = as.numeric(resultado.welch$spec)
  )

  # Seleccionamos las frecuencias de la banda alfa (8-12 Hz)
  alfa <- espectro |> 
    dplyr::filter(frecuencia >= 8, frecuencia <= 12)
  
  # Seleccionamos las frecuencias de la banda beta (12-30 Hz)
  beta <- espectro |> 
    dplyr::filter(frecuencia >= 12, frecuencia <= 30)
  
  # Extraemos las densidades espectrales de potencia de cada banda
  valores.alfa <- alfa$densidad.potencia
  valores.beta <- beta$densidad.potencia
  
  # Integramos la densidad espectral de cada banda mediante la regla del trapecio
  potencia.alfa <- ( 
    sum(valores.alfa) -
      (first(valores.alfa) + last(valores.alfa)) / 2
  ) * 0.5
  
  potencia.beta <- (
    sum(valores.beta) -
      (first(valores.beta) + last(valores.beta)) / 2
  ) * 0.5
  
  tibble(  
    electrodo = electrodo,
    potencia_alfa = potencia.alfa,
    potencia_beta = potencia.beta
  )
}

# -------------------------------------------------------------------------
# Procesamiento de los archivos EEG y cálculo de potencias
# -------------------------------------------------------------------------

# Inicializamos una tabla vacía para almacenar las potencias calculadas
resultados.eeg <- tibble()

# Recorremos los 112 archivos EEG.
for (ruta.actual in rutas.eeg) {
  # Identificamos al participante y al videojuego a partir del archivo
  nombre.archivo <- basename(ruta.actual)
  participante.actual <- substr(nombre.archivo, 1, 3)
  juego.actual <- substr(nombre.archivo, 4, 5)
  
  # Importamos las señales EEG del archivo actual
  datos.actuales <- read_csv(
    ruta.actual,
    show_col_types = FALSE
  )
  
  # Eliminamos la última columna si está completamente vacía.
  if (all(is.na(datos.actuales[[ncol(datos.actuales)]]))) {
    datos.actuales <- datos.actuales |>
      dplyr::select(-last_col())
  }
  # Verificamos que tenga los 14 electrodos
  if (ncol(datos.actuales) != 14) { 
    stop(paste("Revisar columnas del archivo:", nombre.archivo))
  }
  if (anyNA(datos.actuales)) {
    stop(paste("Hay valores faltantes en:", nombre.archivo))
  }
  
  # Recorremos los 14 electrodos del archivo actual.
  for (electrodo.actual in names(datos.actuales)) {
    resultado.actual <- calcular.potencias( 
      datos.actuales,
      electrodo.actual
    )
    
    # Agregamos los identificadores del participante y del videojuego
    resultado.actual <- resultado.actual |>
      mutate(
        participante = participante.actual,
        juego = juego.actual,
        .before = 1
      )
    
    # Incorporamos los resultados del electrodo a la tabla general
    resultados.eeg <- bind_rows(
      resultados.eeg,
      resultado.actual
    )
  }
}
# Exportamos las potencias espectrales para el análisis posterior
write_csv(resultados.eeg, "res/potencias_eeg.csv") 



# -------------------------------------------------------------------------
# Visualización de las señales EEG preprocesadas
# Primer minuto y primeros dos segundos
# -------------------------------------------------------------------------

# Cada electrodo registra 128 valores por segundo.

frecuencia <- 128

# Elegimos los ocho electrodos de nuestro análisis

electrodos <- c(
  "AF3", "AF4", "F3", "F4",
  "F7", "F8", "FC5", "FC6"
)

# Extraemos únicamente el primer minuto

cantidad.muestras <- frecuencia * 60

datos.minuto <- datos.actuales[
  1:cantidad.muestras,
  electrodos,
  drop = FALSE
]

# Creamos una columna que indique el tiempo.
# La primera muestra corresponde a 0 segundos.

datos.minuto$tiempo <- (
  0:(cantidad.muestras - 1)
) / frecuencia

# Convertimos los datos a formato largo para graficar los electrodos por separado.
datos.senales <- datos.minuto |>
  tidyr::pivot_longer(
    cols = dplyr::all_of(electrodos),
    names_to = "electrodo",
    values_to = "amplitud"
  ) |>
  dplyr::mutate(
    electrodo = factor(
      electrodo,
      levels = electrodos
    )
  )

# Colores personalizados de cada electrodo

colores.eeg <- c(
  "AF3" = "#8198B9",
  "AF4" = "#806AA9",
  "F3"  = "#BD879E",
  "F4"  = "#C97F89",
  "F7"  = "#569D98",
  "F8"  = "#74A889",
  "FC5" = "#C39A69",
  "FC6" = "#8D99AB"
)

# Creamos el gráfico del primer minuto

grafico.eeg.preprocesado <- ggplot(
  datos.senales,
  aes(
    x = tiempo,
    y = amplitud,
    colour = electrodo
  )
) +
  
  geom_line(
    linewidth = 0.25,
    alpha = 0.9
  ) +
  
  # Cada electrodo tendrá su propio panel
  facet_wrap(
    ~ electrodo,
    ncol = 1,
    scales = "free_y"
  ) +
  
  scale_colour_manual(
    values = colores.eeg,
    guide = "none"
  ) +
  
  scale_x_continuous(
    breaks = seq(0, 60, 10)
  ) +
  
  labs(
    title = "Así se registran las señales EEG preprocesadas",
    subtitle = paste(
      "Primer minuto de una grabación de GAMEEMO.",
      "Cada electrodo registra 128 muestras por segundo."
    ),
    x = "Tiempo (segundos)",
    y = "Amplitud registrada",
    caption = paste(
      "Datos: GAMEEMO (Alakuş et al., 2020).",
      "Señales preprocesadas, antes del análisis Welch."
    )
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 17,
      colour = "#26354A"
    ),
    
    plot.subtitle = element_text(
      size = 10.5,
      colour = "#728097"
    ),
    
    strip.text = element_text(
      face = "bold",
      size = 11,
      colour = "#45566D"
    ),
    
    strip.background = element_rect(
      fill = "#F5F7FB",
      colour = NA
    ),
    
    panel.grid.major.x = element_line(
      colour = "#EBEFF5"
    ),
    
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    
    axis.text = element_text(
      colour = "#64748B"
    ),
    
    plot.caption = element_text(
      size = 9,
      colour = "#8490A2",
      hjust = 0
    ),
    
    panel.spacing = grid::unit(0.8, "lines")
  )

#Guardamos el gráfico del primer minuto
ggsave(
  filename = "res/02_eeg_preprocesado_1_minuto.png",
  plot = grafico.eeg.preprocesado,
  device = grDevices::png,
  width = 13,
  height = 10,
  dpi = 300,
  bg = "white"
)

# -------------------------------------------------------------------------
# Gráfico de las señales EEG durante los primeros dos segundos
# -------------------------------------------------------------------------

# Conservamos el mismo gráfico, pero acercamos la vista a los primeros dos segundos.

grafico.eeg.dos.segundos <- grafico.eeg.preprocesado +
  
  coord_cartesian(
    xlim = c(0, 2)
  ) +
  
  scale_x_continuous(
    breaks = seq(0, 2, 0.5)
  ) +
  
  labs(
    title = "Así se ve un segmento EEG de dos segundos",
    subtitle = paste(
      "Cada electrodo aporta 256 muestras.",
      "Esta es la duración de las ventanas que usamos en Welch."
    ),
    x = "Tiempo (segundos)"
  )

# Guardamos la ampliación
ggsave(
  filename = "res/03_eeg_preprocesado_2_segundos.png",
  plot = grafico.eeg.dos.segundos,
  device = grDevices::png,
  width = 13,
  height = 10,
  dpi = 300,
  bg = "white"
)

# -------------------------------------------------------------------------
# Visualización de la densidad espectral de potencia mediante Welch
# -------------------------------------------------------------------------
# Estimamos la densidad espectral de potencia del electrodo AF3
resultado.welch <- gsignal::pwelch(
  datos.actuales$AF3,
  fs = 128,
  window = 256,
  overlap = 0.5,
  nfft = 256
)

# Organizamos las frecuencias y sus densidades espectrales
datos.psd <- tibble(
  frecuencia = resultado.welch$freq,
  densidad = as.numeric(resultado.welch$spec)
)

# Conservamos solamente las frecuencias de 8 a 30 Hz
datos.bandas <- datos.psd |>
  dplyr::filter(frecuencia >= 8, frecuencia <= 30)

# Separamos los datos de cada banda
datos.alfa <- datos.bandas |>
  dplyr::filter(frecuencia <= 12)

datos.beta <- datos.bandas |>
  dplyr::filter(frecuencia >= 12)

# Construimos el gráfico de densidad espectral de potencia
grafico.psd <- ggplot(
  datos.bandas,
  aes(x = frecuencia, y = densidad)
) +
  
  # Área bajo la curva de la banda alfa
  geom_area(
    data = datos.alfa,
    fill = "#B5C2D3",
    alpha = 0.7
  ) +
  
  # Área bajo la curva de la banda beta
  geom_area(
    data = datos.beta,
    fill = "#63B7A5",
    alpha = 0.5
  ) +
  
  # Líneas verticales para visualizar los trapecios
  geom_segment(
    aes(
      xend = frecuencia,
      y = 0,
      yend = densidad
    ),
    colour = "#A6B3C5",
    linewidth = 0.35,
    alpha = 0.8
  ) +
  
  # Curva que conecta los valores de Welch
  geom_line(
    colour = "#465C85",
    linewidth = 1
  ) +
  
  # Puntos de las frecuencias
  geom_point(
    colour = "#465C85",
    size = 2.2
  ) +
  
  # Línea que separa alfa y beta
  geom_vline(
    xintercept = 12,
    linetype = "dashed",
    colour = "#64748B",
    linewidth = 0.7
  ) +
  
  # Nombres de las bandas
  annotate(
    "text",
    x = 10,
    y = Inf,
    label = "ALFA",
    vjust = 1.5,
    fontface = "bold",
    size = 4.3,
    colour = "#465C85"
  ) +
  
  annotate(
    "text",
    x = 21,
    y = Inf,
    label = "BETA",
    vjust = 1.5,
    fontface = "bold",
    size = 4.3,
    colour = "#126C5B"
  ) +
  
  # Mostramos únicamente de 8 a 30 Hz
  scale_x_continuous(
    limits = c(8, 30),
    breaks = seq(8, 30, 2),
    expand = c(0, 0)
  ) +
  
  # Títulos
  labs(
    title = "De las frecuencias a las potencias alfa y beta",
    subtitle = paste(
      "Densidad espectral de potencia estimada",
      "mediante Welch · Electrodo AF3"
    ),
    x = "Frecuencia (Hz)",
    y = "Densidad espectral de potencia (PSD)",
    caption = paste(
      "Datos: GAMEEMO (Alakuş et al., 2020).",
      "Una estimación cada 0,5 Hz.",
      "\nLas áreas coloreadas se calculan",
      "mediante la regla del trapecio."
    )
  ) +
  
  # Estilo pastel
  theme_minimal(base_size = 13) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 17,
      colour = "#26354A"
    ),
    
    plot.subtitle = element_text(
      size = 11,
      colour = "#728097",
      margin = margin(b = 15)
    ),
    
    panel.grid.minor = element_blank(),
    
    panel.grid.major = element_line(
      colour = "#EDF0F5",
      linewidth = 0.4
    ),
    
    axis.text = element_text(
      colour = "#64748B"
    ),
    
    axis.title = element_text(
      colour = "#475569"
    ),
    
    plot.caption = element_text(
      size = 9,
      colour = "#8490A2",
      hjust = 0,
      margin = margin(t = 12)
    ),
    
    plot.margin = margin(18, 18, 15, 15)
  )

# Guardamos el gráfico
ggsave(
  filename = "res/04_espectro_welch_AF3.png",
  plot = grafico.psd,
  device = grDevices::png,
  width = 12,
  height = 6,
  dpi = 300,
  bg = "white"
)


