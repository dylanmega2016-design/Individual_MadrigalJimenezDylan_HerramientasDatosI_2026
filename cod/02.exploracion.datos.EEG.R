library(tidyverse)
library(gsignal) ##se va a utilizar para calculcar con el metodo welch
# Buscamos todos los archivos CSV que contienen señales EEG.
rutas_eeg <- list.files(
  "data/datos jugadores EEG",
  pattern = "AllChannels.*\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)

calcular_potencias <- function(datos, electrodo) { ##funcion para calcular las potencias de alfa y beta
  senal <- datos[[electrodo]] ##De los datos sacamos los valores de ese electrodo en especifico

  resultado_welch <- gsignal::pwelch( ##Metodo welch: un metodo que segmentiza la informacion por tiempos para poder calcular sus potencias en cada segmento
    senal,
    fs = 128,
    window = 256, ##Aqui significa que por cada segmento toma 256 valores, como se recibe 128 por segundo, estamos segmentando por cada 2 segundos
    overlap = 0.5,
    nfft = 256
  )
  
  espectro <- tibble( ##sacamos las frecuencias que es justamente con lo que encontraremos los alfas y betas
    frecuencia = resultado_welch$freq,
    densidad_potencia = as.numeric(resultado_welch$spec)
  )

  alfa <- espectro %>% ##la banda alfa se encuentra entre 8 y 12 Hdz
    dplyr::filter(frecuencia >= 8, frecuencia <= 12)
  
  beta <- espectro %>% ##la banda beta se encuentra entre 12 y 30 Hdz
    dplyr::filter(frecuencia >= 12, frecuencia <= 30)
  
  valores_alfa <- alfa$densidad_potencia
  valores_beta <- beta$densidad_potencia

  potencia_alfa <- ( ##formula para calcular la potencia de alfa, también se puede integrar bajo la curva con el eje x siendo los Hdz y el eje y siendo la densidad 
    sum(valores_alfa) -
      (first(valores_alfa) + last(valores_alfa)) / 2
  ) * 0.5
  
  potencia_beta <- (
    sum(valores_beta) -
      (first(valores_beta) + last(valores_beta)) / 2
  ) * 0.5
  
  tibble( ##tabla con resultados 
    electrodo = electrodo,
    potencia_alfa = potencia_alfa,
    potencia_beta = potencia_beta
  )
}

##Lo anterior es para un solo electrodo, debemos generalizarlo para los 14 disponibles
resultados_eeg <- tibble()

# Recorremos los 112 archivos EEG.
for (ruta_actual in rutas_eeg) {
  nombre_archivo <- basename(ruta_actual)
  participante_actual <- substr(nombre_archivo, 1, 3)
  juego_actual <- substr(nombre_archivo, 4, 5)
  datos_actuales <- read_csv(
    ruta_actual,
    show_col_types = FALSE
  )
  
  # Eliminamos la última columna si está completamente vacía.
  if (all(is.na(datos_actuales[[ncol(datos_actuales)]]))) {
    datos_actuales <- datos_actuales %>%
      dplyr::select(-last_col())
  }
  if (ncol(datos_actuales) != 14) { #por si no son los 14 electrodos
    stop(paste("Revisar columnas del archivo:", nombre_archivo))
  }
  if (anyNA(datos_actuales)) {
    stop(paste("Hay valores faltantes en:", nombre_archivo))
  }
  
  # Recorremos los 14 electrodos del archivo actual.
  for (electrodo_actual in names(datos_actuales)) {
    resultado_actual <- calcular_potencias( 
      datos_actuales,
      electrodo_actual
    )
    resultado_actual <- resultado_actual %>%
      mutate(
        participante = participante_actual,
        juego = juego_actual,
        .before = 1
      )
    
    resultados_eeg <- bind_rows(
      resultados_eeg,
      resultado_actual
    )
  }
}
write_csv(resultados_eeg, "res/potencias_eeg.csv") ##Guardamos la tabla ya procesada