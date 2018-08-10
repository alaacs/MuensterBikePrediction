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
      total != "technische Störung"
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

# Explore the variables ----
require(psych)
# hour_pp <- lapply(hour_sel, pairs.panels)
# hour_weather_pp <- lapply(hour_weather_sel, pairs.panels)

# * Hour of the day ----
facetLabels <- c("1" = "Winter", "2" = "Spring", "3" = "Summer", "4" = "Autumn")

hod01 <- ggplot(
  data = hour_weather_sel$id01, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 01: Neutor") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

hod02 <- ggplot(
  data = hour_weather_sel$id02, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 02: Wolbecker Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

hod03 <- ggplot(
  data = hour_weather_sel$id03, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 03: Hüfferstraße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

hod04 <- ggplot(
  data = hour_weather_sel$id04, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 04: Hammer Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

hod05 <- ggplot(
  data = hour_weather_sel$id05, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 05: Promenade") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

hod06 <- ggplot(
  data = hour_weather_sel$id06, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 06: Gartenstraße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

hod07 <- ggplot(
  data = hour_weather_sel$id07, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 07: Warendorfer Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

hod09 <- ggplot(
  data = hour_weather_sel$id09, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = hod, 
      fill = as.factor(season), 
      group = hod
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 09: Weseler Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

grid.arrange(
  hod01,
  hod02,
  hod03, 
  hod04,
  hod05,
  hod06,
  hod07,
  hod09,
  ncol=2, 
  top = textGrob(
    "Total No. of bikes vs. Hour of the day per Season",
    gp=gpar(fontsize=20,font=3))
)

# * Day of the week ----
require(ggplot2)
require(gridExtra)
require(grid)
facetLabels <- c("1" = "Winter", "2" = "Spring", "3" = "Summer", "4" = "Autumn")

dow01 <- ggplot(
  data = hour_weather_sel$id01, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 01: Neutor") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

dow02 <- ggplot(
  data = hour_weather_sel$id02, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 02: Wolbecker Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

dow03 <- ggplot(
  data = hour_weather_sel$id03, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 03: Hüfferstraße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

dow04 <- ggplot(
  data = hour_weather_sel$id04, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 04: Hammer Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

dow05 <- ggplot(
  data = hour_weather_sel$id05, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 05: Promenade") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

dow06 <- ggplot(
  data = hour_weather_sel$id06, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 06: Gartenstraße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

dow07 <- ggplot(
  data = hour_weather_sel$id07, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 07: Warendorfer Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

dow09 <- ggplot(
  data = hour_weather_sel$id09, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = dow, 
      fill = as.factor(season), 
      group = dow
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 09: Weseler Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_discrete(limits = c("Sun","Mon","Tue","Wed","Thu","Fri","Sat")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 90)
  )

grid.arrange(
  dow01,
  dow02,
  dow03, 
  dow04,
  dow05,
  dow06,
  dow07,
  dow09,
  ncol=2, 
  top = textGrob(
    "Total No. of bikes vs. Day of the week per Season",
    gp=gpar(fontsize=20,font=3))
)

# * Weekday ----
require(ggplot2)
require(gridExtra)
require(grid)
facetLabels <- c("1" = "Winter", "2" = "Spring", "3" = "Summer", "4" = "Autumn")

weekday01 <- ggplot(
  data = hour_weather_sel$id01, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 01: Neutor") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

weekday02 <- ggplot(
  data = hour_weather_sel$id02, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 02: Wolbecker Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

weekday03 <- ggplot(
  data = hour_weather_sel$id03, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 03: Hüfferstraße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

weekday04 <- ggplot(
  data = hour_weather_sel$id04, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 04: Hammer Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

weekday05 <- ggplot(
  data = hour_weather_sel$id05, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 05: Promenade") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

weekday06 <- ggplot(
  data = hour_weather_sel$id06, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 06: Gartenstraße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

weekday07 <- ggplot(
  data = hour_weather_sel$id07, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 07: Warendorfer Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

weekday09 <- ggplot(
  data = hour_weather_sel$id09, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = weekday, 
      fill = as.factor(season), 
      group = weekday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  facet_wrap(
    ~season, 
    nrow = 1, 
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 09: Weseler Straße") +
  scale_fill_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  scale_x_continuous(breaks = c(0,1), labels = c("WE","WD")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

grid.arrange(
  weekday01,
  weekday02,
  weekday03, 
  weekday04,
  weekday05,
  weekday06,
  weekday07,
  weekday09,
  ncol=2, 
  top = textGrob(
    "Total No. of bikes vs. Weekday or Weekend per Season",
    gp=gpar(fontsize=20,font=3))
)

# * Holiday ----
require(ggplot2)
require(gridExtra)
require(grid)

holiday01 <- ggplot(
  data = hour_weather_sel$id01, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 01: Neutor") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

holiday02 <- ggplot(
  data = hour_weather_sel$id02, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 02: Wolbecker Straße") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

holiday03 <- ggplot(
  data = hour_weather_sel$id03, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 03: Hüfferstraße") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

holiday04 <- ggplot(
  data = hour_weather_sel$id04, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 04: Hammer Straße") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

holiday05 <- ggplot(
  data = hour_weather_sel$id05, 
  aes(y = as.numeric(total.x))
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 05: Promenade") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

holiday06 <- ggplot(
  data = hour_weather_sel$id06, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 06: Gartenstraße") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

holiday07 <- ggplot(
  data = hour_weather_sel$id07, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 07: Warendorfer Straße") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

holiday09 <- ggplot(
  data = hour_weather_sel$id09, 
  aes(y = total.x)
) +
  geom_boxplot(
    aes(
      x = holiday, 
      fill = as.factor(holiday), 
      group = holiday
    ), 
    show.legend = FALSE, 
    outlier.shape = 20
  ) +
  ggtitle("Station 09: Weseler Straße") +
  scale_fill_manual(values = c("#45c7a3", "#825aae")) +
  scale_x_continuous(breaks = c(0,1), labels = c("Regular day","Holiday")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30"),
    axis.text.x = element_text(size = 8, angle = 0)
  )

grid.arrange(
  holiday01,
  holiday02,
  holiday03, 
  holiday04,
  holiday05,
  holiday06,
  holiday07,
  holiday09,
  ncol=2, 
  top = textGrob(
    "Total No. of bikes vs. Regular day or Holiday",
    gp=gpar(fontsize=20,font=3))
)

# * Temperature ----
require(ggplot2)
require(gridExtra)
require(grid)

facetLabels <- c("1" = "Winter", "2" = "Spring", "3" = "Summer", "4" = "Autumn")

temp01 <- ggplot(
  data = hour_weather_sel$id01, 
  aes(y = total.x)
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 01: Neutor") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

temp02 <- ggplot(
  data = hour_weather_sel$id02, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 02: Wolbecker Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

temp03 <- ggplot(
  data = hour_weather_sel$id03, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 03: Hüfferstraße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

temp04 <- ggplot(
  data = hour_weather_sel$id04, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 04: Hammer Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

temp05 <- ggplot(
  data = hour_weather_sel$id05, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 05: Promenade") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

temp06 <- ggplot(
  data = hour_weather_sel$id06, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 06: Gartenstraße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

temp07 <- ggplot(
  data = hour_weather_sel$id07, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 07: Warendorfer Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

temp09 <- ggplot(
  data = hour_weather_sel$id09, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = temp.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 09: Weseler Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

grid.arrange(
  temp01,
  temp02,
  temp03, 
  temp04,
  temp05,
  temp06,
  temp07,
  temp09,
  ncol=2, 
  top = textGrob(
    "Total No. of bikes vs. Temperature (°C) per Season",
    gp=gpar(fontsize=20,font=3))
)

# * Wind ----
require(ggplot2)
require(gridExtra)
require(grid)

facetLabels <- c("1" = "Winter", "2" = "Spring", "3" = "Summer", "4" = "Autumn")

wind01 <- ggplot(
  data = hour_weather_sel$id01, 
  aes(y = total.x)
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 01: Neutor") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

wind02 <- ggplot(
  data = hour_weather_sel$id02, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 02: Wolbecker Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

wind03 <- ggplot(
  data = hour_weather_sel$id03, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 03: Hüfferstraße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

wind04 <- ggplot(
  data = hour_weather_sel$id04, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 04: Hammer Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

wind05 <- ggplot(
  data = hour_weather_sel$id05, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 05: Promenade") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

wind06 <- ggplot(
  data = hour_weather_sel$id06, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 06: Gartenstraße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

wind07 <- ggplot(
  data = hour_weather_sel$id07, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 07: Warendorfer Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

wind09 <- ggplot(
  data = hour_weather_sel$id09, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = wind.x,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 09: Weseler Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

grid.arrange(
  wind01,
  wind02,
  wind03, 
  wind04,
  wind05,
  wind06,
  wind07,
  wind09,
  ncol=2, 
  top = textGrob(
    "Total No. of bikes vs. Wind speed (km/h) per Season",
    gp=gpar(fontsize=20,font=3))
)

# * Precipitation ----
require(ggplot2)
require(gridExtra)
require(grid)

facetLabels <- c("1" = "Winter", "2" = "Spring", "3" = "Summer", "4" = "Autumn")

pph01 <- ggplot(
  data = hour_weather_sel$id01, 
  aes(y = total.x)
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 01: Neutor") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

pph02 <- ggplot(
  data = hour_weather_sel$id02, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 02: Wolbecker Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

pph03 <- ggplot(
  data = hour_weather_sel$id03, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 03: Hüfferstraße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

pph04 <- ggplot(
  data = hour_weather_sel$id04, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 04: Hammer Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

pph05 <- ggplot(
  data = hour_weather_sel$id05, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 05: Promenade") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

pph06 <- ggplot(
  data = hour_weather_sel$id06, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 06: Gartenstraße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

pph07 <- ggplot(
  data = hour_weather_sel$id07, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 07: Warendorfer Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

pph09 <- ggplot(
  data = hour_weather_sel$id09, 
  aes(y = as.numeric(total.x))
) +
  geom_point(
    aes(
      x = pph,
      color = as.factor(season), 
      alpha = 0.5
    ), 
    show.legend = FALSE
  ) +
  facet_wrap(
    ~season,
    nrow = 1,
    labeller = labeller(season = facetLabels)
  ) +
  ggtitle("Station 09: Weseler Straße") +
  scale_color_manual(values = c("#88d0e5", "#f01bf0", "#11b41c", "#ffc04c")) +
  theme(
    axis.title = element_blank(),
    plot.title = element_text(size = 9, color = "grey30")
  )

grid.arrange(
  pph01,
  pph02,
  pph03, 
  pph04,
  pph05,
  pph06,
  pph07,
  pph09,
  ncol=2, 
  top = textGrob(
    "Total No. of bikes vs. Precipitation (mm) per Season",
    gp=gpar(fontsize=20,font=3))
)