# Create a look up table to gather general info on the data ----
lookUp <- data.frame(
  c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  c(
    "Neutor", 
    "Wolbecker Strasse", 
    "Huefferstrasse",
    "Hammer Strasse",
    "Promenade",
    "Gartenstrasse", 
    "Waredorfer Strasse",
    "Hafenstrasse",
    "Weseler Strasse"
  ),
  c(
    51.966837,
    51.959266,
    51.961261,
    51.955046,
    51.960712,
    51.971624,
    51.961757,
    NA,
    51.950107
  ),
  c(
    7.616133,
    7.6341553,
    7.608971,
    7.626401,
    7.633314,
    7.635826,
    7.637633,
    NA,
    7.617267
  ),
  c(
    NA,
    34,
    NA,
    NA,
    110,
    NA,
    NA,
    NA,
    NA
  )
)

colnames(lookUp) <- c("id","name","lat","long","missing_data")

# Load day files from system ----
## Load the ".csv" files downloaded from https://www.stadt-muenster.de/verkehrsplanung/verkehr-in-zahlen/radverkehrszaehlungen.html
## Create a list with the files 
day <- list(
  id01_day <- read.csv("data/zaehlstelle_neutor_2017_tagesauswertung.csv"),
  id02_day <- read.csv("data/zaehlstelle_wolbecker_2017_tagesauswertung.csv"),
  id03_day <- read.csv("data/zaehlstelle_huefferstrasse_2017_tagesauswertung.csv"),
  id04_day <- read.csv("data/zaehlstelle_hammer-strasse_2017_tagesauswertung.csv"),
  id05_day <- read.csv("data/zaehlstelle_promenade_2017_tagesauswertung.csv"),
  id06_day <- read.csv("data/zaehlstelle_gartenstrasse_2017_tagesauswertung.csv"),
  id07_day <- read.csv("data/zaehlstelle_warendorfer_2017_tagesauswertung.csv"),
  id09_day <- read.csv("data/zaehlstelle_weseler_2017_tagesauswertung.csv")
)

## Set data frame names within the list
names(day) <- c("id01", "id02", "id03", "id04", "id05", "id06", "id07", "id09")

## Set column names for all files 
dayNames <- c(
  "date",
  "total",
  "centerDir",
  "oppDir",
  "temp",
  "mintemp",
  "maxtemp",
  "wind",
  "rain",
  "snow",
  "weather"
)

day <- lapply(day, setNames, nm = dayNames)

## Remove unnecessary variables created
rm(id01_day, id02_day, id03_day, id04_day, id05_day, id06_day, id07_day, id09_day)

# Load hour files from system ----
## Create a list with the files 
hour <- list(
  id01_hour <- read.csv("data/zaehlstelle_neutor_2017_stundenauswertung.csv"),
  id02_hour <- read.csv("data/zaehlstelle_wolbecker_2017_stundenauswertung.csv"),
  id03_hour <- read.csv("data/zaehlstelle_huefferstrasse_2017_stundenauswertung.csv"),
  id04_hour <- read.csv("data/zaehlstelle_hammer-strasse_2017_stundenauswertung.csv"),
  id05_hour <- read.csv("data/zaehlstelle_promenade_2017_stundenauswertung.csv"),
  id06_hour <- read.csv("data/zaehlstelle_gartenstrasse_2017_stundenauswertung.csv"),
  id07_hour <- read.csv("data/zaehlstelle_warendorfer_2017_stundenauswertung.csv"),
  id09_hour <- read.csv("data/zaehlstelle_weseler_2017_stundenauswertung.csv")
)

## Set data frame names within the list
names(hour) <- c("id01", "id02", "id03", "id04", "id05", "id06", "id07", "id09")

## Set column names for all files 
hourNames <- c(
  "date",
  "total",
  "centerDir",
  "oppDir",
  "temp",
  "wind",
  "weather"
)

hour <- lapply(hour, setNames, nm = hourNames)

## Remove unnecessary variables created
rm(id01_hour, id02_hour, id03_hour, id04_hour, id05_hour, id06_hour, id07_hour, id09_hour)

# Delete missing data for bike count ----
hour <- lapply(
  hour, 
  function(x){
    subset(
      x, 
      total != "technische StÃ¶rung"
    )
  }
)

# Change date column to strptime ----
day <- lapply(
  day,
  function(x) {
    x$date <- strptime(x$date, format = "%m/%d/%Y %H:%M")
    return(x)
  }
)

hour <- lapply(
  hour, 
  function(x) {
    x$date <- strptime(x$date, format = "%m/%d/%Y %H:%M")
    return(x)
  }
)

# Create variables for hour dataset ----
# * Calculate day of the week ----
require(lubridate)
hour <- lapply(
  hour, 
  function(x) {
    x$dow <- wday(x$date)
    return(x)
  }
)

# * Extract hour of the day ----
require(lubridate)
hour <- lapply(
  hour, 
  function(x) {
    x$hod <- hour(x$date)
    return(x)
  }
)

# * Determine if it is a weekend ----
weekend <- c(1,7) # 1:Sunday, 7: Saturday
hour <- lapply(
  hour,
  function(x) {
    x$weekday <- ifelse(
      x$dow %in% weekend,
      0, 
      1)
    return(x)
  }
)

# * Determine if it is a holiday ----
## Holidays taken from: https://www.officeholidays.com/countries/germany/2017.php
holiday2017 <- strptime(
  c(
    "2017-01-01", "2017-01-06", "2017-04-14",
    "2017-04-17", "2017-05-01", "2017-05-14",
    "2017-05-25", "2017-06-05", "2017-06-15",
    "2017-08-15", "2017-10-03", "2017-10-31",
    "2017-11-01", "2017-11-22", "2017-12-25", "2017-12-26"
  ),
  format = "%Y-%m-%d"
)

hour <- lapply(
  hour,
  function(x) {
    x$holiday <- ifelse(
      strftime(x$date, format = "%Y-%m-%d") %in% strftime(holiday2017, format = "%Y-%m-%d"),
      1, 
      0)
    return(x)
  }
)

# * Determine the season ----
spri_st <- strptime("2017-03-21", format = "%Y-%m-%d")
spri_end <- strptime("2017-06-20", format = "%Y-%m-%d")
summ_st <- strptime("2017-06-21", format = "%Y-%m-%d")
summ_end <- strptime("2017-09-20", format = "%Y-%m-%d")
autu_st <- strptime("2017-09-21", format = "%Y-%m-%d")
autu_end <- strptime("2017-12-20", format = "%Y-%m-%d")

## Winter: 1, Spring:2, Summer:3, Autumn:4
hour <- lapply(
  hour,
  function(x) {
    x$season <- ifelse(
      (strftime(x$date, format = "%Y-%m-%d")) >= spri_st & (strftime(x$date, format = "%Y-%m-%d")) <= spri_end,
      2,
      ifelse(
        (strftime(x$date, format = "%Y-%m-%d")) >= summ_st & (strftime(x$date, format = "%Y-%m-%d")) <= summ_end,
        3,
        ifelse(
          (strftime(x$date, format = "%Y-%m-%d")) >= autu_st & (strftime(x$date, format = "%Y-%m-%d")) <= autu_end,
          4,
          1
        )
      )
    )
    return(x)
  }
)

# Remove data without weather variables ----
hour_weather <- lapply(
  hour, 
  function(x) {
    subset(
      x, 
      !is.na(wind)
    )
  }
)

# * Determine precipitation ----
## Create a dummy variable from the weather column including rain and snow
prec <- c("Regen", "Schnee", "Schneeregen")

hour_weather <- lapply(
  hour_weather, 
  function(x) {
    x$precipitation_dummy <- ifelse(x$weather %in% prec, 1, 0)
    return(x)
  }
)

## Sum precipitation dummy variable data per day
hour_prec <- lapply(
  hour_weather,
  function(x) {
    aggregate(x$precipitation_dummy,by = list(yday(x$date)),FUN = sum)
  }
)

hourprecNames <- c(
  "jday",
  "prec.hours"
)

hour_prec <- lapply(hour_prec, setNames, nm = hourprecNames)

## Get one single variable for precipitation on the daily data
day <- lapply(
  day, 
  function (x) {
    x$prec <- ifelse(is.na(x$snow), x$rain, x$snow)
    return(x)
  }
)

## Calculate Julian day for hourly and daily data
day <- lapply(
  day, 
  function (x) {
    x$jday <- yday(x$date)
    return(x)
  }
)

hour_weather <- lapply(
  hour_weather, 
  function (x) {
    x$jday <- yday(x$date)
    return(x)
  }
)

## Join the hour precipitation (hour_prec) data with the daily data

day <- mapply(
  function(x, y) {
    merge(x, y, by = "jday")
  },
  day,
  hour_prec,
  SIMPLIFY = FALSE
)

## Calculate precipitation per hour (pph)
day <- lapply(
  day,
  function(x){
    x$pph <- ifelse(x$prec.hours == 0, 0, x$prec/x$prec.hours)
    return(x)
  }
)

## Join day and hour data to introduce preciptiation variable
hour_weather <- mapply(
  function(x, y) {
    merge(x, y, by = "jday")
  },
  hour_weather,
  day,
  SIMPLIFY = FALSE
)

# Select only variables for analysis ----
hour_var <- c("total", "dow", "hod", "weekday", "holiday", "season")
hour_sel <- lapply(
  hour,
  function(x){
    x[hour_var]
  }
)

hour_weather_var <- c("total.x", "dow", "hod", "weekday", "holiday", "season", "temp.x", "wind.x", "pph")
hour_weather_sel <- lapply(
  hour_weather,
  function(x){
    x[hour_weather_var]
  }
)

# Write .csv for selected data ----
# sapply(
#   names(hour_sel), 
#   function(x) {
#     write.csv(hour_sel[x], file = paste("processed/", x, ".csv", sep = ""))
#   }
# )
# 
# sapply(
#   names(hour_weather_sel), 
#   function(x) {
#     write.csv(hour_weather_sel[x], file = paste("processed/", x, "w", ".csv", sep = ""))
#   }
# )