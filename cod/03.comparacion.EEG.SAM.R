
# -------------------------------------------------------------------------
# Proyecto individual - Herramientas de Ciencia de Datos I
# Script 03: Comparación de datos EEG y respuestas SAM
#
# Objetivo: comparar las potencias espectrales de las bandas alfa y beta
# con las respuestas de valencia y activación de los participantes.
#
# Fuente de datos: GAMEEMO (Alakuş et al., 2020).
# -------------------------------------------------------------------------

# Librerías necesarias
library(tidyverse)
library(readxl)

# -------------------------------------------------------------------------
# Importación de las bases de datos EEG y SAM
# -------------------------------------------------------------------------

# Importamos las potencias espectrales calculadas en el script 02
datos.eeg <- read_csv(
  "res/potencias_eeg.csv",
  show_col_types = FALSE
)

# Importamos las respuestas SAM de los participantes
datos.sam <- read_excel(
  "data/datos.SAM/GAMEEMO_respuestas_SAM_revision.xlsx",
  sheet = "Datos_SAM"
)

# -------------------------------------------------------------------------
# Integración de los datos EEG y SAM
# -------------------------------------------------------------------------

# Incorporamos las respuestas SAM a las potencias espectrales
# mediante los identificadores del participante y el videojuego
datos.combinados <- datos.eeg |>
  left_join(
    datos.sam |>
      dplyr::select(
        participante,
        juego,
        nombre_videojuego,
        valencia_SAM,
        activacion_SAM
      ),
    by = c("participante", "juego")
  )

# -------------------------------------------------------------------------
# Selección y resumen de los electrodos frontales y centrofrontales
# -------------------------------------------------------------------------

# Seleccionamos los ocho electrodos de interés para el análisis
datos.frontales <- datos.combinados |>
  dplyr::filter(
    electrodo %in% c("AF3", "AF4", "F3", "F4",
                     "F7", "F8", "FC5", "FC6") 
  )

# Calculamos la mediana de las potencias alfa y beta
# de los ocho electrodos por participante y videojuego
resumen.frontal <- datos.frontales |>
  group_by(
    participante,
    juego,
    nombre_videojuego,
    valencia_SAM,
    activacion_SAM
  ) |>
  summarise(
    alfa_frontal = median(potencia_alfa), 
    beta_frontal = median(potencia_beta),
    cantidad_electrodos = n(),
    .groups = "drop"
  )

# -------------------------------------------------------------------------
# Comparación descriptiva entre los cuatro videojuegos
# -------------------------------------------------------------------------

# Calculamos las medianas grupales de las respuestas SAM
# y de las potencias espectrales para cada videojuego
comparacion.juegos <- resumen.frontal |> 
  group_by(juego, nombre_videojuego) |>
  summarise(
    mediana_valencia = median(valencia_SAM),
    mediana_activacion = median(activacion_SAM),
    mediana_alfa = median(alfa_frontal),
    mediana_beta = median(beta_frontal),
    participantes = n(),
    .groups = "drop"
  )

# -------------------------------------------------------------------------
# Comparación pareada entre Slender y Goat Simulator
# -------------------------------------------------------------------------
comparacion.pareada <- resumen.frontal |> 
  dplyr::filter(juego %in% c("G3", "G4")) |> 
  dplyr::select(
    participante,
    juego,
    valencia_SAM,
    activacion_SAM,
    alfa_frontal,
    beta_frontal
  ) |>
  pivot_wider(
    names_from = juego,
    values_from = c(
      valencia_SAM,
      activacion_SAM,
      alfa_frontal,
      beta_frontal
    )
  )


# Calculamos las diferencias individuales entre los videojuegos
# restando los valores de Slender a los de Goat Simulator (G4 - G3)
comparacion.pareada <- comparacion.pareada |>
  mutate(
    diferencia_valencia = valencia_SAM_G4 - valencia_SAM_G3,
    diferencia_activacion = activacion_SAM_G4 - activacion_SAM_G3,
    diferencia_alfa = alfa_frontal_G4 - alfa_frontal_G3,
    diferencia_beta = beta_frontal_G4 - beta_frontal_G3
  )

# Calculamos el porcentaje de participantes cuya diferencia
# absoluta de potencia entre ambos videojuegos es menor a 1
porcentaje.alfa <- mean(
  abs(comparacion.pareada$diferencia_alfa) < 1,
  na.rm = TRUE
) * 100

porcentaje.beta <- mean(
  abs(comparacion.pareada$diferencia_beta) < 1,
  na.rm = TRUE
) * 100


# Mostramos los porcentajes en la consola
print(round(porcentaje.alfa, 1))
print(round(porcentaje.beta, 1))

# Calculamos las medianas de las diferencias individuales.
resumen.diferencias <- comparacion.pareada |>
  summarise(
    mediana_diferencia_valencia = median(diferencia_valencia),
    mediana_diferencia_activacion = median(diferencia_activacion),
    mediana_diferencia_alfa = median(diferencia_alfa),
    mediana_diferencia_beta = median(diferencia_beta)
  )

# -------------------------------------------------------------------------
# Comparación gráfica de las potencias EEG por participante
# -------------------------------------------------------------------------
# Datos para el gráfico
datos.lineas.eeg <- comparacion.pareada |>
  select(
    participante,
    alfa_frontal_G3,
    alfa_frontal_G4,
    beta_frontal_G3,
    beta_frontal_G4
  ) |>
  mutate(
    participante = factor(
      participante,
      levels = paste0("S", sprintf("%02d", 1:28))
    )
  ) |>
  pivot_longer(
    cols = c(
      alfa_frontal_G3,
      alfa_frontal_G4,
      beta_frontal_G3,
      beta_frontal_G4
    ),
    names_to = "serie",
    values_to = "potencia"
  ) |>
  mutate(
    serie = factor(
      serie,
      levels = c(
        "alfa_frontal_G3",
        "alfa_frontal_G4",
        "beta_frontal_G3",
        "beta_frontal_G4"
      ),
      labels = c(
        "Alfa - Slender",
        "Alfa - Goat Simulator",
        "Beta - Slender",
        "Beta - Goat Simulator"
      )
    )
  )

# Creamos el gráfico
grafico.lineas.eeg <- ggplot(
  datos.lineas.eeg,
  aes(
    x = participante,
    y = potencia,
    group = serie,
    color = serie,
    linetype = serie
  )
) +
  geom_line(
    linewidth = 0.95,
    alpha = 0.9
  ) +
  geom_point(
    size = 2
  ) +
  scale_color_manual(
    values = c(
      "Alfa - Slender" = "#C76D7A",
      "Alfa - Goat Simulator" = "#4FA88B",
      "Beta - Slender" = "#8E5EA2",
      "Beta - Goat Simulator" = "#4C78A8"
    )
  ) +
  scale_linetype_manual(
    values = c(
      "Alfa - Slender" = "solid",
      "Alfa - Goat Simulator" = "solid",
      "Beta - Slender" = "dashed",
      "Beta - Goat Simulator" = "dashed"
    )
  ) +
  labs(
    title = NULL,
    subtitle = "Nota: Las líneas comparan la potencia frontal resumida de cada participante; no representan una evolución temporal.",
    x = "Participante",
    y = "Potencia",
    color = "Serie",
    linetype = "Serie",
    caption = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_blank(),
    plot.subtitle = element_text(
      size = 10.5,
      colour = "#728097",
      margin = margin(b = 10)
    ),
    axis.title.y = element_text(
      angle = 0,
      vjust = 0.5,
      colour = "#475569"
    ),
    axis.title.x = element_text(
      colour = "#475569"
    ),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      colour = "#64748B"
    ),
    axis.text.y = element_text(
      colour = "#64748B"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(
      colour = "#EDF0F5",
      linewidth = 0.4
    ),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    legend.text = element_text(colour = "#44506A"),
    plot.caption = element_blank(),
    plot.margin = margin(15, 18, 12, 15)
  )

# Guardamos el gráfico
ggsave(
  filename = "res/06_lineas_potencias_eeg.png",
  plot = grafico.lineas.eeg,
  width = 12.5,
  height = 6.8,
  dpi = 300,
  bg = "white"
)
# -------------------------------------------------------------------------
# Comparación gráfica de las potencias EEG entre Slender y Goat Simulator
# -------------------------------------------------------------------------

# Seleccionamos las potencias alfa y beta de ambos videojuegos
# y organizamos los datos en formato largo
datos.eeg.g34 <- resumen.frontal |>
  dplyr::filter(juego %in% c("G3", "G4")) |>
  mutate(
    juego = factor(
      juego,
      levels = c("G4", "G3"),
      labels = c("Goat Simulator", "Slender")
    )
  ) |>
  select(participante, juego, alfa_frontal, beta_frontal) |>
  pivot_longer(
    cols = c(alfa_frontal, beta_frontal),
    names_to = "banda",
    values_to = "potencia"
  ) |>
  mutate(
    banda = factor(
      banda,
      levels = c("alfa_frontal", "beta_frontal"),
      labels = c("BANDA ALFA", "BANDA BETA")
    )
  )

#  Calculamos resumen por videojuego y banda

resumen.eeg.g34 <- datos.eeg.g34 |>
  group_by(juego, banda) |>
  summarise(
    q1 = quantile(potencia, 0.25),
    mediana = median(potencia),
    q3 = quantile(potencia, 0.75),
    .groups = "drop"
  )

# Calculamos la posición de las etiquetas de mediana
posiciones.texto <- datos.eeg.g34 |>
  group_by(banda) |>
  summarise(
    max_x = max(potencia, na.rm = TRUE)
  )

resumen.eeg.g34 <- resumen.eeg.g34 |>
  left_join(posiciones.texto, by = "banda") |>
  mutate(
    x_texto = max_x + 1.8,
    etiqueta_mediana = paste0("Md ", round(mediana, 1))
  )

#  Definimos colores

colores.fuertes <- c(
  "Goat Simulator" = "#4E8E7C",
  "Slender" = "#B65263"
)

#  Construimos el gráfico

grafico.eeg.g34 <- ggplot(
  datos.eeg.g34,
  aes(x = potencia, y = juego)
) +
  
  # Franja suave del 50 % central
  geom_segment(
    data = resumen.eeg.g34,
    aes(
      x = q1,
      xend = q3,
      y = juego,
      yend = juego,
      color = juego
    ),
    linewidth = 10,
    alpha = 0.18,
    lineend = "round",
    inherit.aes = FALSE,
    show.legend = FALSE
  ) +
  
  # Puntos individuales
  geom_point(
    aes(color = juego),
    size = 2.4,
    alpha = 0.65,
    position = position_jitter(width = 0, height = 0.10, seed = 123),
    show.legend = FALSE
  ) +
  
  # Rombo de la mediana
  geom_point(
    data = resumen.eeg.g34,
    aes(x = mediana, y = juego, fill = juego),
    shape = 23,
    size = 3.5,
    color = "white",
    stroke = 0.4,
    inherit.aes = FALSE,
    show.legend = FALSE
  ) +
  
  # Texto de mediana a la derecha
  geom_text(
    data = resumen.eeg.g34,
    aes(
      x = x_texto,
      y = juego,
      label = etiqueta_mediana,
      color = juego
    ),
    hjust = 0,
    size = 3.5,
    fontface = "bold",
    inherit.aes = FALSE,
    show.legend = FALSE
  ) +
  
  facet_wrap(
    ~ banda,
    ncol = 1,
    scales = "free_x"
  ) +
  
  scale_color_manual(values = colores.fuertes) +
  scale_fill_manual(values = colores.fuertes) +
  
  labs(
    title = NULL,
    subtitle = "Nota: Cada punto representa una sesión individual; la franja suave contiene el 50 % central y el rombo señala la mediana.",
    x = "Potencia espectral",
    y = NULL,
    caption = NULL
  ) +
  
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_blank(),
    plot.subtitle = element_text(
      size = 11,
      colour = "#728097",
      margin = margin(b = 10)
    ),
    strip.text = element_text(
      face = "bold",
      size = 12,
      colour = "#44506A"
    ),
    strip.background = element_rect(
      fill = "#F3F5FA",
      colour = NA
    ),
    axis.title.x = element_text(
      colour = "#44506A"
    ),
    axis.text.x = element_text(
      colour = "#5B657A"
    ),
    axis.text.y = element_text(
      colour = "#44506A"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(
      colour = "#E7EAF1"
    ),
    plot.caption = element_blank(),
    plot.margin = margin(10, 80, 10, 15)
  ) +
  
  coord_cartesian(clip = "off")

# Guardamos el gráfico
ggsave(
  filename = "res/05_eeg_slender_vs_goat.png",
  plot = grafico.eeg.g34,
  width = 12,
  height = 7.5,
  dpi = 300,
  bg = "white"
)

# -------------------------------------------------------------------------
# Exportación de los resultados del análisis
# -------------------------------------------------------------------------

# Guardamos las tablas generadas durante el análisis estadístico
write_csv(resumen.frontal, "res/resumen_frontal.csv")

write_csv(comparacion.juegos, "res/comparacion_juegos.csv")

write_csv(comparacion.pareada, "res/comparacion_pareada.csv")

write_csv(resumen.diferencias, "res/resumen_diferencias.csv")