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

ReportStart <- "10012019"
ReportEnd <- "09302020"

Enrollment <- read_csv("data/Enrollment.csv")
Project <- read_csv("data/Project.csv")
Inventory <- read_csv("data/Inventory.csv")
Funders <- read_csv("data/Funder.csv")

# Enter a 1 for AO, 3 for AC, 4 for CO, or "all" if the flag is complaining
# more generally about zero clients

household_type_in_question <- 3

# Paste in Project IDs
projects_in_question <- c(
  1003,
  1010,
  1110,
  1579,
  1666,
  167,
  1671,
  1676,
  1766,
  1785,
  1856,
  1857,
  1879,
  1880,
  1907,
  1921,
  2081,
  2082,
  2129,
  2161,
  2162,
  2167,
  2168,
  2170,
  2174,
  2178,
  2186,
  2190,
  2193,
  2195,
  2198,
  2200,
  2202,
  2203,
  2205,
  2209,
  2212,
  2214,
  2216,
  2217,
  2220,
  2221,
  2229,
  2231,
  2233,
  2234,
  2237,
  2239,
  2244,
  2246,
  2248,
  2250,
  2255,
  2256,
  2258,
  2260,
  2262,
  2264,
  2266,
  2268,
  2270,
  2271,
  2273,
  2277,
  2279,
  2280,
  2286,
  2289,
  2291,
  2293,
  2297,
  2298,
  2299,
  2310,
  2410,
  422,
  426,
  738,
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

just_didnt_serve_hhtype <- relevant_inventories %>%
  pivot_wider(names_from = HouseholdType,
              values_from = BedInventory) %>%
  rename("AC" = `3`, "AO" = `1`) %>%
  mutate(
    PercentAO = percent(AO / (AO + AC))
  )
  
