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

resumen.activacion
