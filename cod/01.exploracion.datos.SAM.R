library (tidyverse)
library (readxl)
library(ggdist)
library(ggbeeswarm)
datos_sam <- read_excel("data/datos.SAM/GAMEEMO_respuestas_SAM_revision.xlsx", sheet = "Datos_SAM") ##traemos los datos del excel del SAM
resumen_sam <- datos_sam %>% 
  group_by (juego) %>% 
  summarise (mediana.valencia = median(valencia_SAM), mediana.activacion = median(activacion_SAM), participantes = n())
##valencia es que tan agradable es el juego, mientras que activacion es que tan estimulante es el juego  

comparacion_sam <- datos_sam %>% 
  filter(juego == "G3" | juego == "G4") %>% 
  select(participante, juego, valencia_SAM)


comparacion_sam <- comparacion_sam %>% 
  pivot_wider (names_from =juego, values_from= valencia_SAM) %>% 
  mutate(diferencia_valencia = G4-G3) ##Para ver cuantos puntos de diferencia de agrado tienen ambos juegos por jugador

resumen.comparacion <- comparacion_sam %>%
  summarise( mayor.goat = sum(diferencia_valencia > 0), mayor.slender = sum(diferencia_valencia < 0), iguales = sum(diferencia_valencia == 0),
   mediana.diferencia = median(diferencia_valencia))


comparacion.activacion <- datos_sam %>%
  filter(juego == "G3" | juego == "G4") %>%
  select(participante, juego, activacion_SAM) %>%
  pivot_wider(
    names_from = juego,
    values_from = activacion_SAM
  ) %>%
  mutate(diferencia.activacion = G4 - G3) ##Para ver cuantos puntos de diferencia de intensidad tienen ambos juegos por jugador

resumen.activacion <- comparacion.activacion %>%
  summarise(
    mayor.goat = sum(diferencia.activacion > 0),
    mayor.slender = sum(diferencia.activacion < 0),
    iguales = sum(diferencia.activacion == 0),
    mediana.diferencia = median(diferencia.activacion) 
  )


## Gráfico 1: Distribución de la valencia emocional

ggplot(datos_sam, aes(x = juego, y = valencia_SAM)) +
  geom_boxplot(
    aes(fill = juego),
    width = 0.55,
    colour = "grey30",
    outlier.shape = NA
  ) +
  geom_jitter(
    width = 0.12,
    height = 0,
    size = 1.6,
    alpha = 0.4,
    colour = "grey25"
  ) +
  scale_fill_manual(
    values = c(
      G1 = "grey85",
      G2 = "grey85",
      G3 = "grey85",
      G4 = "#168F77"
    ),
    guide = "none"
  ) +
  scale_x_discrete(
    labels = c(
      G1 = "Train Sim World\n(G1)",
      G2 = "Unravel\n(G2)",
      G3 = "Slender\n(G3)",
      G4 = "Goat Simulator\n(G4)"
    )
  ) +
  scale_y_continuous(
    breaks = c(1, 3, 5, 7, 9),
    limits = c(1, 9)
  ) +
  labs(
    title = "Goat Simulator fue calificado como más agradable que Slender",
    subtitle = "Mediana de valencia: 7 frente a 3 puntos; 28 participantes por juego",
    x = NULL,
    y = "Valencia SAM (1 = desagradable; 9 = agradable)",
    caption = "Fuente: elaboración propia con GAMEEMO (Alakuş et al., 2020). Sin datos faltantes."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    plot.title.position = "plot",
    plot.subtitle = element_text(size = 11, colour = "grey35"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 10),
    plot.caption = element_text(size = 9, colour = "grey40", hjust = 0)
  )
ggsave(
  "res/01_valencia_videojuegos.png", ##Guardamos el primer grafico
  width = 9,
  height = 5.5,
  dpi = 300,
  bg = "white"
)
# Gráfico 2: Activación emocional durante los videojuegos

grafico.activacion <- ggplot(
  datos_sam,
  aes(x = juego, y = activacion_SAM, fill = juego)
) +
  geom_boxplot(
    width = 0.55,
    colour = "grey30",
    outlier.shape = NA
  ) +
  geom_jitter(
    width = 0.12,
    height = 0,
    size = 1.6,
    alpha = 0.4,
    colour = "grey25"
  ) +
  scale_fill_manual(
    values = c(
      G1 = "grey85",
      G2 = "grey85",
      G3 = "#A45A5A",
      G4 = "#168F77"
    ),
    guide = "none"
  ) +
  scale_x_discrete(
    labels = c(
      G1 = "Train Sim World\n(G1)",
      G2 = "Unravel\n(G2)",
      G3 = "Slender\n(G3)",
      G4 = "Goat Simulator\n(G4)"
    )
  ) +
  scale_y_continuous(
    breaks = c(1, 3, 5, 7, 9),
    limits = c(1, 9)
  ) +
  labs(
    title = "El terror y la diversión registraron mayor activación emocional",
    subtitle = "Medianas: Slender 6,5 y Goat Simulator 6; 28 participantes por juego",
    x = NULL,
    y = "Activación SAM (1 = baja; 9 = alta)",
    caption = "Fuente: elaboración propia con GAMEEMO (Alakuş et al., 2020)."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    plot.title.position = "plot",
    plot.subtitle = element_text(size = 11, colour = "grey35"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 10),
    plot.caption = element_text(size = 9, colour = "grey40", hjust = 0)
  )

ggsave(
  filename = "res/02_activacion_videojuegos.png", ##Guardamos el segundo gráfico 
  plot = grafico.activacion,
  width = 9,
  height = 5.5,
  dpi = 300,
  bg = "white"
)

datos_grafico <- datos_sam %>%
  pivot_longer(
    cols = c(valencia_SAM, activacion_SAM),
    names_to = "dimension",
    values_to = "puntuacion"
  )

head(datos_grafico)
## Comparamos valencia y activación

grafico.sam <- ggplot(
  datos_grafico,
  aes(x = juego, y = puntuacion, fill = juego)
) +
  geom_boxplot(
    width = 0.55,
    outlier.shape = NA
  ) +
    geom_jitter(
      width = 0.12,
      height = 0,
      alpha = 0.35,
      size = 1.5
    )+
  facet_wrap(
    ~ dimension,
    nrow = 1,
    labeller = as_labeller(c(
      valencia_SAM = "Valencia (agrado)",
      activacion_SAM = "Activación (intensidad)"
    ))
  ) +
  scale_fill_manual(
    values = c(
      G1 = "grey80",
      G2 = "grey80",
      G3 = "#B65B5B",
      G4 = "#168F77"
    ),
    guide = "none"
  ) +
  scale_y_continuous(
    breaks = c(1, 3, 5, 7, 9),
    limits = c(1, 9)
  ) +
  labs(
    title = "Slender y Goat difieren más en agrado que en activación",
    subtitle = "Medianas de valencia: 3 y 7; de activación: 6,5 y 6",
    x = "Videojuego",
    y = "Puntuación SAM (1 a 9)",
    caption = "Fuente: elaboración propia con GAMEEMO (Alakuş et al., 2020)."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.caption = element_text(hjust = 0)
  )
ggsave(
  "res/03_resumen_sam.png",
  plot = grafico.sam,
  width = 9,
  height = 4.5,
  dpi = 300,
  bg = "white"
)

#Primer grafico de resultados

## Gráfico SAM: distribución de valencia y activación


## Gráfico SAM: mapa de burbujas pastel
## Las burbujas correspondientes a las medianas
## se destacan con colores más intensos.

library(tidyverse)

# 1. Preparamos los datos del cuestionario SAM
datos.bolitas <- datos_grafico %>%
  dplyr::filter(!is.na(puntuacion)) %>%
  dplyr::mutate(
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

# 2. Contamos cuántos participantes eligieron cada puntuación
conteos.sam <- datos.bolitas %>%
  dplyr::count(
    dimension,
    juego,
    puntuacion,
    name = "participantes"
  ) %>%
  dplyr::filter(participantes > 0)

# 3. Calculamos las medianas de cada videojuego
medianas.sam <- datos.bolitas %>%
  dplyr::group_by(dimension, juego) %>%
  dplyr::summarise(
    mediana = median(puntuacion),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    etiqueta = dplyr::if_else(
      mediana %% 1 == 0,
      as.character(as.integer(mediana)),
      sub("\\.", ",", as.character(mediana))
    )
  )

# 4. Identificamos las burbujas que coinciden con la mediana
# Conservamos el conteo de participantes y su tamaño.
conteos.sam <- conteos.sam %>%
  dplyr::left_join(
    medianas.sam %>%
      dplyr::select(dimension, juego, mediana),
    by = c("dimension", "juego")
  ) %>%
  dplyr::mutate(
    es.mediana = dplyr::near(puntuacion, mediana),
    color.bolita = dplyr::if_else(
      es.mediana,
      paste0(as.character(juego), "_mediana"),
      as.character(juego)
    )
  )

# 5. Identificamos las medianas decimales, como 6,5.
# Estas no coinciden con una respuesta individual,
# por lo que necesitan una bolita adicional.
medianas.decimales <- medianas.sam %>%
  dplyr::filter(mediana %% 1 != 0) %>%
  dplyr::mutate(
    color.bolita = paste0(
      as.character(juego),
      "_mediana"
    )
  )

# 6. Colores pastel originales y tonos intensos
colores.bolitas <- c(
  "Train Sim World" = "#B5C2D3",
  "Unravel" = "#C4B8D2",
  "Slender" = "#E48791",
  "Goat Simulator" = "#63B7A5",
  
  "Train Sim World_mediana" = "#7085A8",
  "Unravel_mediana" = "#9174B4",
  "Slender_mediana" = "#C54E62",
  "Goat Simulator_mediana" = "#208B79"
)

# Colores para las etiquetas de las medianas
colores.mediana <- c(
  "Train Sim World" = "#7085A8",
  "Unravel" = "#9174B4",
  "Slender" = "#C54E62",
  "Goat Simulator" = "#208B79"
)

# 7. Líneas de referencia de la escala SAM
lineas.referencia <- tibble::tibble(
  puntuacion = 1:9
)

# 8. Construimos el gráfico
grafico.sam.bolitas <- ggplot() +
  
  # Líneas verticales tenues
  geom_vline(
    data = lineas.referencia,
    aes(xintercept = puntuacion),
    colour = "#EDF0F5",
    linewidth = 0.45
  ) +
  
  # Burbujas originales, con su tamaño según el conteo.
  # Las que corresponden a medianas tienen un tono intenso.
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
    stroke = 0.7,
    alpha = 0.90
  ) +
  
  # Bolita adicional solamente para medianas decimales.
  # Por ejemplo, la de Slender en activación se ubica
  # exactamente en 6,5, entre las columnas 6 y 7.
  geom_point(
    data = medianas.decimales,
    aes(
      x = mediana,
      y = juego,
      fill = color.bolita
    ),
    inherit.aes = FALSE,
    shape = 21,
    size = 5,
    colour = "#FFFFFF",
    stroke = 1,
    alpha = 1,
    show.legend = FALSE
  ) +
  
  # Etiquetas de las medianas a la derecha
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
  
  # Paneles de valencia y activación
  facet_wrap(
    ~ dimension,
    ncol = 1
  ) +
  
  # Escala de puntuación SAM
  scale_x_continuous(
    breaks = 1:9,
    limits = c(0.5, 11.15),
    expand = c(0, 0)
  ) +
  
  # Mantenemos la escala de tamaños del gráfico anterior
  scale_size_area(
    max_size = 19,
    breaks = c(1, 3, 5, 7),
    name = "Participantes"
  ) +
  
  # Colores de las burbujas
  scale_fill_manual(
    values = colores.bolitas,
    guide = "none"
  ) +
  
  # Colores de las etiquetas
  scale_colour_manual(
    values = colores.mediana,
    guide = "none"
  ) +
  
  # Títulos
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
  
  # Diseño pastel original
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
    
    panel.spacing = grid::unit(1.6, "lines"),
    
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
        alpha = 0.90
      )
    )
  )

# 9. Mostrar el gráfico
print(grafico.sam.bolitas)

# 10. Guardarlo para Quarto
ggsave(
  filename = "res/03_resumen_sam_bolitas.png",
  plot = grafico.sam.bolitas,
  width = 11,
  height = 8,
  dpi = 300,
  bg = "white"
)

