
## STATISTICA PER IL TURISMO: MODELLI E APPLICAZIONI ##
# Beatrice Malvezzi, mat. 907500

# Working directory e pacchetti ------------------------------------------------

setwd("C:/Users/hp/Desktop/STATISTICA PER IL TURISMO/progetto")
list.files()
library(ggplot2)
library(tidyr)
library(tidyverse)
library(xts)
library(scales)
library(forecast)
library(MASS)
library(tseries)

# colori colorblind safe
myred <- rgb(214,96,77, maxColorValue = 255)
myblue <- rgb(67,147,195, maxColorValue = 255)

# Lettura dati -----------------------------------------------------------------

permanenze <- data.frame(read.csv("permanenze.csv",header=TRUE,
                              fileEncoding = 'UTF-8-BOM'))
# selezione del Portogallo
permanenze <- permanenze[,c(1,14)]
str(permanenze)
head(permanenze)
# la variabile "Mese" è di tipo carattere ma è una data
# si utilizza quindi la funzione as.POSIXct per convertirla in modo tale che R la
# legga come data
permanenze[,1] <- seq(as.POSIXct("2010-01-01"), by = "month", length.out = nrow(permanenze))
str(permanenze)
head(permanenze)

# Si crea una variabile che contiene il numero di notti passate nelle strutture 
# alberghiere in Portogallo espressa in milioni, per evitare di avere valori 
# lunghi come etichette degli assi nei grafici
permanenze$Portugal <- permanenze[,2]/1000000


# Grafici ----------------------------------------------------------------------

# si utilizza la funzione ts per dire a R che i dati sono delle serie storiche
permanenze.ts <- ts(permanenze[,2], frequency = 12, start = 2010) 
str(permanenze.ts)
plot(permanenze.ts, type="o", pch=19, main="Permanenze nelle strutture alberghiere",
     xlab = "Mese", ylab="Notti (migliaia)")
# si ricorda che il numero di notti ha come scala il milione

# in alternativa si può usare la funzione ggplot:
ggplot(permanenze, aes(x=Mese, y=Portugal)) +
  geom_point(size=1) + 
  geom_line(linewidth=0.6) +
  scale_x_datetime(labels = date_format("%Y-%m"), breaks = date_breaks("year")) + 
  theme_bw() + theme(axis.text.x = element_text(angle = 45, vjust=0.5)) +
  ggtitle("Permanenze nelle strutture alberghiere") +
  xlab("Mese") + ylab("Numero notti (milioni)")
# ci sono dei picchi corrispondenti ai mesi di agosto di ogni anno
# questo indica la presenza di stagionalità


# Si rappresenta la serie per evidenziare la stagionalità
# seasonal plot
ggseasonplot(permanenze.ts) + theme_bw() +
  ggtitle("Permanenze dal 2010 al 2024 in Portogallo")
# i picchi maggiori sono nei mesi di luglio e agosto
# si osservano due linee diverse dalle altre, rappresentano gli anni 2020 e 2021

# polar plot
ggseasonplot(permanenze.ts, polar=TRUE) + theme_bw() + 
  ggtitle("Permanenze dal 2010 al 2024 in Portogallo") + 
  theme(panel.grid = element_line(color = "#bdbdbd")) 
# rappresentazione molto simile
# anche qui è visibile la differenza data dagli anni 2020 e 2021


# Indici descrittivi -----------------------------------------------------------

summary(permanenze[,2])

# varianza
var(permanenze[,2])
# valore abbastanza elevato per effetto covid

# Autocovarianza e autocorrelazione
acf(permanenze[,2], type="covariance", main="Autocovarianza")
acf(permanenze[,2], type="correlation", main="Autocorrelazione", ci = 0)


# Decomposizione della serie ---------------------------------------------------
# si sceglie il modello moltiplicativo perché le variazioni stagionali variano
# nel tempo
permanenze.decomp <- decompose(permanenze.ts, type='multiplicative')
permanenze.decomp
str(permanenze.decomp)
plot(permanenze.decomp)
autoplot(permanenze.decomp, main = "Decomposizione della serie storica",
         xlab = "Mese")


# Stazionarietà ----------------------------------------------------------------

# si utilizza la serie da gennaio 2010 a dicembre 2019 --> 120 osservazioni
permanenze1 <- permanenze[1:120,]  

ggplot(permanenze1, aes(x=Mese, y=Portugal)) +
  geom_point(size=1) + 
  geom_line(linewidth=0.6) +  
  geom_hline(yintercept=mean(permanenze$Portugal), color=myred) +
  scale_x_datetime(labels = date_format("%Y-%m"), breaks = date_breaks("year")) + 
  theme_bw() + theme(axis.text.x = element_text(angle = 45, vjust=0.5)) +
  ggtitle("Permanenze nelle strutture alberghiere (2010-2019)") +
  xlab("Mese") + ylab("Numero notti (milioni)")

# Si rende la serie stazionaria in  varianza usando la trasformazione Box-Cox
boxcox(lm(permanenze1[,2] ~ 1))
# questa funzione ci fa capire quale trasformazione bisogna applicare affinchè
# la serie diventi stazionaria in varianza
# lambda pari a 0
lambda <- 0
#permanenze1$lambda <- (permanenze[,2]^lambda - 1) / lambda
permanenze1$logserie <- log(permanenze1[,2])

# Si rende la serie stazionaria in  media usando le differenze stagionali 
# e di ordine 1 
permanenze1$diffStagione <- c(rep(NA,12), diff(permanenze1$logserie, lag=12))

# Si implementa la differenziazione di ordine 1
permanenze1$diffStagione1 <- c(NA, diff(permanenze1$diffStagione, lag=1))
permanenze1

ggplot(permanenze1[, c(1,5)], aes(x=Mese, y=diffStagione1)) +
  geom_point(size=1) +
  geom_line(linewidth=0.6) +  
  geom_hline(yintercept=mean(permanenze1[-c(1:13), 5]), color=myred) +
  scale_x_datetime(labels = date_format("%y"), breaks = date_breaks("year")) + 
  theme_bw() + theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  ggtitle("Permanenze") +
  xlab("Mese") + ylab("Notti") 


# Stima del modello ------------------------------------------------------------
# scelta dell'ordine del modello 

# Parte a media mobile
acf(permanenze1[-c(1:13), 5], lag.max = 50, main = "Autocorrelazione")
# q = 1,  Q = 1

# Parte autoregressiva
pacf(permanenze1[-c(1:13), 5], lag.max = 50, main = "Autocorrelazione parziale")
# p = 2,  P = 2

# Stima del modello 
mod <- arima(permanenze1$diffStagione1, c(2, 0, 1))
residuals <- residuals(mod)
fitted <- permanenze1$diffStagione1 - residuals

# Verifica se il modello è adeguato 
ts.plot(permanenze1$diffStagione1, main = "Permanenze", ylab = "Notti", xlab = "Mese")
points(fitted, type = "l", col = 2, lty = 2)
# la linea rossa tratteggiata rappresenta i valori fittati 
# si nota che non coincide con la linea nera che rappresenta i veri valori della serie
# quindi il modello scelto non è adeguato  

# Analisi dei residui
checkresiduals(mod)
# i residui hanno media zero, distribuzione approssimativamente normale, ma 
# vi è una correlazione tra gli errori  

# Si chiede ad R di stimare un modello ARIMA selezionando i valori dei parametri
# p, d, q, P, D, Q in automatico
permanenzets <- ts(permanenze1[, 2], start = c(2010,1), end = c(2019, 12), 
                  frequency = 12)
mod <- auto.arima(permanenzets, stationary = FALSE, stepwise = FALSE, 
                  approximation = FALSE, seasonal = TRUE, ic = "aicc",
                  trace = TRUE, lambda = 0.5)
# Best model: ARIMA(0,1,1)(2,1,1)[12]

ts.plot(permanenzets, main = "Permanenze", ylab = "Notti (milioni)", xlab = "Mese")
points(mod$fitted, type = "l", col = 2, lty = 2)
autoplot(permanenzets) + autolayer(fitted(mod)) + 
  ylab("Notti") + ggtitle("Permanenze") + xlab("Mese") + 
  theme_bw() + theme(legend.position='none') 
# vi è un buon adattamento al modello a parte per piccole deviazioni
# il modello sta effettivamente funzionando bene

# Si osserva se le assunzioni del modello sono verificate:
checkresiduals(mod)


# Previsione per i mesi gennaio-settembre 2020 ---------------------------------
prev <- forecast(mod, h = 9, level = c(80, 95))
prev
 
# Rappresentazione della serie prevista
plot(prev, main = "Previsioni ARIMA(0,1,1)(2,1,1)[12]", xlab = "Mese", 
     ylab = "Notti (milioni)")
autoplot(prev) + xlim(2020, NA) + theme_bw() + 
  ggtitle("Previsioni ARIMA(0,1,1)(2,1,1)[12]") +
  ylab("Notti") + xlab("mese")

# la previsione raggiunge un valore di circa 12 milioni di notti 
# il valore massimo effettivo nello stesso periodo era di circa 6 milioni

# Ampiezza degli intervalli di previsione
ampiezza80 <- prev$upper[,1] - prev$lower[,1]
ampiezza80
ampiezza95 <- prev$upper[,2] - prev$lower[,2]
ampiezza95

# l'ampiezza degli intervalli di previsione aumenta nel tempo a causa
# dell'incertezza che si aggiunge alle previsioni dei periodi precedenti
