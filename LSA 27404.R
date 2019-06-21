library(tidyverse)
library(lubridate)
library(readxl)

PSHdata <- read_xlsx("data/PSHEligibility.xlsx")

HHsWithoutDisability <- PSHdata %>% 
  group_by(HHID, Project, Entry) %>%
  summarise(HoHClientID = min(ClientIDHoH),
            DisabilityInHH = max(HasDisabililty)) %>%
  filter(DisabilityInHH == "No (HUD)") %>%
  ungroup()

#When did they enter?

byYear <- HHsWithoutDisability %>%
  mutate(yearOfEntry = year(Entry)) %>%
  group_by(yearOfEntry) %>%
  summarise(HHs = n())
