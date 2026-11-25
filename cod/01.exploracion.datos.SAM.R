# -------------------------------------------------------------------------
# Proyecto individual - Herramientas de Ciencia de Datos I
# Script 01: Exploración de datos SAM
#
# Objetivo: analizar la valencia y activación emocional reportadas
# durante los cuatro videojuegos.
#
# Los participantes calificaron del 1 al 9 el agrado (valencia)
# y la intensidad emocional (activación) de cada videojuego.
#
# Fuente de datos: GAMEEMO (Alakuş et al., 2020).
# -------------------------------------------------------------------------


# Librerías necesarias
library(tidyverse)
library(readxl)

# Importamos las respuestas del cuestionario SAM
datos.sam <- read_excel(
  "data/datos.SAM/GAMEEMO_respuestas_SAM_revision.xlsx", 
  sheet = "Datos_SAM") 

# Resumen de valencia y activación por videojuego
resumen.sam <- datos.sam |> 
  group_by(juego) |> 
  summarise(
    mediana.valencia = median(valencia_SAM),
    mediana.activacion = median(activacion_SAM),
    participantes = n()
            )

# Comparación de valencia entre Slender (G3) y Goat Simulator (G4)
comparacion.sam <- datos.sam |> 
  filter(juego == "G3" | juego == "G4") |> 
  select(participante, juego, valencia_SAM)|> 
  pivot_wider (
    names_from = juego,
    values_from = valencia_SAM
    ) |> 
  mutate(diferencia.valencia = G4-G3) 

# Resumen de las diferencias de valencia entre ambos juegos
resumen.comparacion <- comparacion.sam |>
  summarise( 
    mayor.goat = sum(diferencia.valencia > 0), 
    mayor.slender = sum(diferencia.valencia < 0), 
    iguales = sum(diferencia.valencia == 0), 
    mediana.diferencia = median(diferencia.valencia))

# Comparación de activación entre Slender (G3) y Goat Simulator (G4)
comparacion.activacion <- datos.sam |>
  filter(juego == "G3" | juego == "G4") |>
  select(participante, juego, activacion_SAM) |>
  pivot_wider(
    names_from = juego,
    values_from = activacion_SAM
  ) |>
  mutate(diferencia.activacion = G4 - G3)

# Resumen de las diferencias de activación entre ambos juegos
resumen.activacion <- comparacion.activacion |>
  summarise(
    mayor.goat = sum(diferencia.activacion > 0),
    mayor.slender = sum(diferencia.activacion < 0),
    iguales = sum(diferencia.activacion == 0),
    mediana.diferencia = median(diferencia.activacion) 
  )

# -------------------------------------------------------------------------
# Preparación de datos para la visualización SAM
# -------------------------------------------------------------------------

# Transformamos los datos SAM a formato largo
datos.grafico <- datos.sam |>
  pivot_longer(
    cols = c(valencia_SAM, activacion_SAM),
    names_to = "dimension",
    values_to = "puntuacion"
  )

datos.bolitas <- datos.grafico |>
  filter(!is.na(puntuacion)) |>
  mutate(
    juego = factor(
      juego,
      levels = c("G4", "G3", "G2", "G1"),
      labels = c(
        "Goat Simulator",
        "Slender",
        "Unravel",
        "Train Sim World"
      )
    ),
    dimension = factor(
      dimension,
      levels = c("valencia_SAM", "activacion_SAM"),
      labels = c(
        "VALENCIA · AGRADO",
        "ACTIVACIÓN · INTENSIDAD"
      )
    )
  )

conteos.sam <- datos.bolitas |>
  count(
    dimension,
    juego,
    puntuacion,
    name = "participantes"
  ) 

medianas.sam <- datos.bolitas |>
  group_by(dimension, juego) |>
  summarise(
    mediana = median(puntuacion),
    .groups = "drop"
  ) |>
  mutate(
    etiqueta = if_else(
      mediana %% 1 == 0,
      as.character(as.integer(mediana)),
      sub("\\.", ",", as.character(mediana))
    )
  )

conteos.sam <- conteos.sam |>
  left_join(
    medianas.sam |>
      select(dimension, juego, mediana),
    by = c("dimension", "juego")
  ) |>
  mutate(
    es.mediana = near(puntuacion, mediana),
    color.bolita = if_else(
      es.mediana,
      paste0(as.character(juego), "_mediana"),
      as.character(juego)
    )
  )


medianas.decimales <- medianas.sam |>
  filter(mediana %% 1 != 0) |>
  mutate(
    color.bolita = paste0(
      as.character(juego),
      "_mediana"
    )
  )

# -------------------------------------------------------------------------
# Gráfico SAM: distribución de valencia y activación
# -------------------------------------------------------------------------

# Colores normales e intensos para las medianas
colores.bolitas <- c(
  # Colores pastel
  "Train Sim World" = "#B5C2D3",
  "Unravel" = "#C4B8D2",
  "Slender" = "#E48791",
  "Goat Simulator" = "#63B7A5",
  
  # Colores de las medianas
  "Train Sim World_mediana" = "#465C85",
  "Unravel_mediana" = "#66468F",
  "Slender_mediana" = "#AD3853",
  "Goat Simulator_mediana" = "#126C5B"
)


colores.mediana <- c(
  "Train Sim World" = "#465C85",
  "Unravel" = "#66468F",
  "Slender" = "#AD3853",
  "Goat Simulator" = "#126C5B"
)

lineas.referencia <- data.frame(
  puntuacion = 1:9
)
grafico.sam.bolitas <- ggplot() +
  
  geom_vline(
    data = lineas.referencia,
    aes(xintercept = puntuacion),
    colour = "#EDF0F5",
    linewidth = 0.45
  ) +
  
  geom_point(
    data = conteos.sam,
    aes(
      x = puntuacion,
      y = juego,
      size = participantes,
      fill = color.bolita
    ),
    shape = 21,
    colour = "#FFFFFF",
    stroke = 0.55,
    alpha = 0.94
  ) +
  
  geom_point(
    data = medianas.decimales,
    aes(
      x = mediana,
      y = juego,
      fill = color.bolita
    ),
    inherit.aes = FALSE,
    shape = 21,
    size = 3.5,
    colour = "#FFFFFF",
    stroke = 0.65,
    alpha = 1,
    show.legend = FALSE
  ) +
  
  geom_label(
    data = medianas.sam,
    aes(
      x = 10.30,
      y = juego,
      label = paste0("Md  ", etiqueta),
      colour = juego
    ),
    inherit.aes = FALSE,
    fill = "#F5F7FB",
    linewidth = 0,
    label.padding = grid::unit(0.26, "lines"),
    label.r = grid::unit(0.22, "lines"),
    fontface = "bold",
    size = 3.6,
    show.legend = FALSE
  ) +
  
  facet_wrap(
    ~ dimension,
    ncol = 1
  ) +
  
  scale_x_continuous(
    breaks = 1:9,
    limits = c(0.5, 11.15),
    expand = c(0, 0)
  ) +
  
  scale_size_area(
    max_size = 13.5,
    breaks = c(1, 3, 5, 7),
    name = "Participantes"
  ) +
  
  scale_fill_manual(
    values = colores.bolitas,
    guide = "none"
  ) +
  
  scale_colour_manual(
    values = colores.mediana,
    guide = "none"
  ) +
  
  labs(
    title = "Slender y Goat: distinto agrado, intensidad parecida",
    subtitle = paste(
      "La posición indica la puntuación SAM;",
      "el tamaño de cada burbuja indica cuántas personas la eligieron.",
      "El tono intenso señala la mediana."
    ),
    x = "Puntuación SAM (1 a 9)",
    y = NULL,
    caption = paste(
      "Datos: GAMEEMO (Alakuş et al., 2020).",
      "28 participantes por videojuego."
    )
  ) +
  
  theme_minimal(base_size = 13) +
  
  theme(
    plot.background = element_rect(
      fill = "#FFFFFF",
      colour = NA
    ),
    
    panel.background = element_rect(
      fill = "#FFFFFF",
      colour = NA
    ),
    
    plot.title = element_text(
      face = "bold",
      size = 17,
      colour = "#26354A",
      margin = margin(b = 7)
    ),
    
    plot.title.position = "plot",
    
    plot.subtitle = element_text(
      size = 10.5,
      colour = "#728097",
      margin = margin(b = 18)
    ),
    
    strip.text = element_text(
      face = "bold",
      size = 12,
      colour = "#45566D",
      margin = margin(t = 12, b = 12)
    ),
    
    strip.background = element_rect(
      fill = "#F5F7FB",
      colour = NA
    ),
    
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    panel.spacing = grid::unit(1.8, "lines"),
    
    axis.text.y = element_text(
      size = 11,
      colour = "#475569",
      margin = margin(r = 12)
    ),
    
    axis.text.x = element_text(
      size = 11,
      colour = "#64748B"
    ),
    
    axis.title.x = element_text(
      size = 11,
      colour = "#64748B",
      margin = margin(t = 12)
    ),
    
    legend.position = "bottom",
    legend.direction = "horizontal",
    
    legend.title = element_text(
      size = 10,
      colour = "#475569"
    ),
    
    legend.text = element_text(
      size = 10,
      colour = "#64748B"
    ),
    
    legend.key.height = grid::unit(0.6, "cm"),
    
    plot.caption = element_text(
      size = 9,
      colour = "#8490A2",
      hjust = 0,
      margin = margin(t = 15)
    ),
    
    plot.margin = margin(
      t = 18,
      r = 22,
      b = 15,
      l = 15
    )
  ) +
  
  guides(
    size = guide_legend(
      nrow = 1,
      override.aes = list(
        fill = "#A6B3C5",
        colour = "#FFFFFF",
        alpha = 0.94
      )
    )
  )

# Guardamos el gráfico para el informe Quarto
ggsave(
  filename = "res/01_resumen_sam_bolitas.png",
  plot = grafico.sam.bolitas,
  width = 12.5,
  height = 8.5,
  dpi = 300,
  bg = "white"
)