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

library(tidyverse)
library(lubridate)
library(HMIS)

ReportStart <- "10012018"
ReportEnd <- "09302020"

Inventory <- read_csv("data/Inventory.csv")


smallInventory <- Inventory %>%
  filter(beds_available_between(., ReportStart, ReportEnd) &
           HouseholdType == 4) %>%
  select(ProjectID, BedInventory)

# this is just a single provider with actual low utilization




