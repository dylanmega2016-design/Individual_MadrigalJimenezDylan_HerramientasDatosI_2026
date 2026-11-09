library(tidyverse)
library(readxl)
datos_eeg <- read_csv(
  "res/potencias_eeg.csv",
  show_col_types = FALSE
)
datos_sam <- read_excel(
  "data/GAMEEMO_respuestas_SAM_revision.xlsx",
  sheet = "Datos_SAM"
)
#Uniremos las dos informaciones
datos_combinados <- datos_eeg %>%
  left_join(
    datos_sam %>%
      dplyr::select(
        participante,
        juego,
        nombre_videojuego,
        valencia_SAM,
        activacion_SAM
      ),
    by = c("participante", "juego")
  )
datos_frontales <- datos_combinados %>%
  dplyr::filter(
    electrodo %in% c("AF3", "AF4", "F3", "F4",
                     "F7", "F8", "FC5", "FC6") #usaremos solos los electrodos frontales y centrofrontales que son encargados mas de las emociones y acciones al momento
  )
resumen_frontal <- datos_frontales %>%
  group_by(
    participante,
    juego,
    nombre_videojuego,
    valencia_SAM,
    activacion_SAM
  ) %>%
  summarise(
    alfa_frontal = median(potencia_alfa), #Agrupamos de esta forma para juntar la media de los 8 electrodos por juego
    beta_frontal = median(potencia_beta),
    cantidad_electrodos = n(),
    .groups = "drop"
  )

comparacion_juegos <- resumen_frontal %>% #Aqui conseguimos las medias grupales o generales
  group_by(juego, nombre_videojuego) %>%
  summarise(
    mediana_valencia = median(valencia_SAM),
    mediana_activacion = median(activacion_SAM),
    mediana_alfa = median(alfa_frontal),
    mediana_beta = median(beta_frontal),
    participantes = n(),
    .groups = "drop"
  )
comparacion_pareada <- resumen_frontal %>% #Seleccionamos los dos con contraste mas alto para comparar individualmente
  dplyr::filter(juego %in% c("G3", "G4")) %>% #tenemos que usar dplyr porque el paquete que se usó para el welch tambien tiene funciones con el mismo nombre
  dplyr::select(
    participante,
    juego,
    valencia_SAM,
    activacion_SAM,
    alfa_frontal,
    beta_frontal
  ) %>%
  pivot_wider(
    names_from = juego,
    values_from = c(
      valencia_SAM,
      activacion_SAM,
      alfa_frontal,
      beta_frontal
    )
  )
# Calculamos las diferencias entre Goat y Slender para cada participante.
comparacion_pareada <- comparacion_pareada %>%
  mutate(
    diferencia_valencia = valencia_SAM_G4 - valencia_SAM_G3,
    diferencia_activacion = activacion_SAM_G4 - activacion_SAM_G3,
    diferencia_alfa = alfa_frontal_G4 - alfa_frontal_G3,
    diferencia_beta = beta_frontal_G4 - beta_frontal_G3
  )
# Calculamos las medianas de las diferencias individuales.
resumen_diferencias <- comparacion_pareada %>%
  summarise(
    mediana_diferencia_valencia = median(diferencia_valencia),
    mediana_diferencia_activacion = median(diferencia_activacion),
    mediana_diferencia_alfa = median(diferencia_alfa),
    mediana_diferencia_beta = median(diferencia_beta)
  )
# Organizamos las diferencias alfa y beta para graficarlas.
datos_diferencias <- comparacion_pareada %>%
  dplyr::select(
    participante,
    diferencia_alfa,
    diferencia_beta
  ) %>%
  pivot_longer(
    cols = c(diferencia_alfa, diferencia_beta),
    names_to = "banda",
    values_to = "diferencia"
  )