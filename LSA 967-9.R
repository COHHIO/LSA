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

# Zero clients served in active beds

library(tidyverse)
library(lubridate)
library(readxl)
library(janitor)
library(HMIS)
library(scales)

load("data/COHHIOHMIS.RData")

ReportStart <- "10012019"
ReportEnd <- "09302020"

# Enter a 1 for AO, 3 for AC, 4 for CO, or "all" if the flag is complaining
# more generally about zero clients

household_type_in_question <- 3

# Paste in Project IDs
projects_in_question <- c(
  1110,
  1579,
  167,
  1671,
  1766,
  1785,
  1880,
  1907,
  2101,
  2129,
  2168,
  2170,
  2214,
  2229,
  2260,
  2271,
  422,
  426,
  752,
  917,
  988

)

relevant_hhtype_inventories <- Project %>%
  filter(ProjectID %in% projects_in_question) %>%
  left_join(Inventory, by = "ProjectID") %>%
  filter((HouseholdType == household_type_in_question |
            household_type_in_question == "all") &
           beds_available_between(., ReportStart, ReportEnd)) %>%
  select(ProjectID, ProjectName, BedInventory, HouseholdType, OperatingStartDate)

relevant_inventories <- Project %>%
  filter(ProjectID %in% projects_in_question) %>%
  left_join(Inventory, by = "ProjectID") %>%
  filter(beds_available_between(., ReportStart, ReportEnd)) %>%
  select(ProjectID, ProjectName, BedInventory, HouseholdType)

created_in_response_to_covid <- relevant_hhtype_inventories %>%
  filter(ymd(OperatingStartDate) >= mdy("04012020"))

beds <- relevant_inventories %>%
  pivot_wider(names_from = HouseholdType,
              values_from = BedInventory) %>%
  rename("AC" = `3`, "AO" = `1`)

clients_served <- Enrollment %>%
  filter(ProjectID %in% c(projects_in_question) &
           stayed_between(., ReportStart, ReportEnd)) %>%
  mutate(HH_or_Single = if_else(str_detect(HouseholdID, "s_"), "singles", "households")) %>%
  group_by(ProjectID, HH_or_Single) %>%
  summarise(Served = n()) %>%
  ungroup() %>%
  pivot_wider(names_from = HH_or_Single,
              values_from = Served)

all_together <- beds %>%
  left_join(clients_served, by = "ProjectID")

