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
library(here)
library(readxl)
library(janitor)

inventory <- read_csv(here("data/Inventory.csv"))

flags_2018_bos <- read_xlsx(
  "data/errors_warnings_2018_bos.xlsx",
  sheet = 4,
  skip = 4,
  col_types = "text"
)

flags_2019_bos <- read_xlsx(
  "data/errors_warnings_2019_bos.xlsx",
  sheet = 4,
  skip = 4,
  col_types = "text"
)

flags_bos <-
  rbind(flags_2018_bos,
        flags_2019_bos) %>%
  clean_names() %>%
  unique() %>%
  filter(!is.na(id_number))

errors <- flags_bos %>%
  filter(id_number == 786) %>%
  mutate(InventoryID = as.double(value_14)) %>%
  left_join(inventory, by = "InventoryID") %>%
  select(InventoryID, ProjectID, InventoryStartDate)

# if the ProjectID is blank that's because it's either a DV project or it's no
# longer active and thus isn't being included in the daily HUD CSV Export.
# used RW to just look up the remaining InventoryIDs and make the corrections.
