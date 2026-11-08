library (tidyverse)
library (readxl)
datos_sam <- read_excel("data/GAMEEMO_respuestas_SAM_revision.xlsx", sheet = "Datos_SAM") ##traemos los datos del excel del SAM
resumen_sam <- datos_sam %>% 
  group_by (juego) %>% 
  summarise (mediana.valencia = median(valencia_SAM), mediana.activacion = median(activacion_SAM), participantes = n())
##valencia es que tan agradable es el juego, mientras que activacion es que tan estimulante es el juego  
resumen_sam