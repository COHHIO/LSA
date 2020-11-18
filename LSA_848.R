# COHHIO_HMIS
# Copyright (C) 2019  Coalition on Homelessness and Housing in Ohio (COHHIO)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details at
# <https://www.gnu.org/licenses/>.

# Missing CoC Location data

library(tidyverse)
library(lubridate)
library(readxl)
library(janitor)
library(HMIS)

ReportStart <- "10012018"
ReportEnd <- "09302020"

flags_2018 <- read_xlsx(
  "data/errors_warnings_1_2018.xlsx",
  sheet = 4,
  skip = 4,
  col_types = "text"
)

flags_2019 <- read_xlsx(
  "data/errors_warnings_1_2019.xlsx",
  sheet = 4,
  skip = 4,
  col_types = "text"
)

flags_all <- rbind(flags_2018, flags_2019) %>% 
  clean_names() %>% unique() %>%
  filter(!is.na(id_number))

flag848 <- flags_all %>%
  filter(id_number == 848) %>%
  mutate(value_16 = as.numeric(value_16)) %>%
  select("ProjectID" = value_14, "ProjectName" = value_18, "Enrollments" = value_16)

write_csv(flag848, "outputs/missingCoClocation.csv")
