library (tidyverse)
library (readxl)
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

# Gráfico de la valencia emocional de los cuatro videojuegos

# Gráfico 1: Distribución de la valencia emocional

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
