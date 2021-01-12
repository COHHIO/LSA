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

coc <- read_xlsx(
  "data/errors_warnings_2019_bos.xlsx",
  sheet = 2,
  range = "A1",
  col_names = "CoC"
) %>%
  pull(CoC)

flags_2018 <- read_xlsx(
  "data/errors_warnings_2018_bos.xlsx",
  sheet = 4,
  skip = 4,
  col_types = "text"
)

flags_2019 <- read_xlsx(
  "data/errors_warnings_2019_bos.xlsx",
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

# The ProjectIDs in the flag file seem off somehow. Trying another way:

mahoning_projects <-
  c(696:697, 1327:1328, 1330:1331, 1392, 1638:1641, 1704, 1738, 2103, 2105,
    2110, 2322:2336, 2338:2360, 2362:2385)

enrollments <- read_csv("data/Enrollment.csv")
enrollmentcoc <- read_csv("data/EnrollmentCoC.csv")

missing_in_export <- enrollmentcoc %>%
  filter(is.na(CoCCode) & 
           ProjectID != 1695 &
           DataCollectionStage == 1 &
           (coc == "OH-507 Ohio Balance of State CoC" &
             !ProjectID %in% c(mahoning_projects)) |
           (coc == "OH-504 Youngstown/Mahoning County CoC" &
              ProjectID %in% c(mahoning_projects))) %>%
  select(PersonalID, EnrollmentID, ProjectID) %>%
  left_join(enrollments[c("EnrollmentID", "EntryDate")], by = "EnrollmentID") %>%
  filter(ymd(EntryDate) < ymd("20201001"))

write_csv(missing_in_export, "outputs/missingCoClocation.csv")

missing_rel_to_hoh <- Enrollment %>%
  filter(RelationshipToHoH == 99 &
           ProjectType %in% c(1, 2, 3, 8, 9, 13) &
           served_between(., ReportStart, ReportEnd))

write_csv(missing_rel_to_hoh, "outputs/missingreltohoh.csv")


