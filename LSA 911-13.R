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

Enrollment <-
  read_csv("data/Enrollment.csv",
           col_types =
             "nnnDcnnnlnDnnnDDDnnnncccnnDnnnncnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnTTnTn")

Project <- 
  read_csv("data/Project.csv",
           col_types = "nnccDDnnnnnnnnTTcTn") 

th_2018 <- Enrollment %>%
  select(PersonalID, HouseholdID, EntryDate, ProjectID) %>%
  left_join(Project[c("ProjectID", "ProjectName", "ProjectType")],
            by = "ProjectID") %>%
  mutate(YearEntered = year(ymd(EntryDate))) %>%
  filter(ProjectType == 2 & YearEntered == 2018)

th_2019 <- Enrollment %>%
  select(PersonalID, HouseholdID, EntryDate, ProjectID) %>%
  left_join(Project[c("ProjectID", "ProjectName", "ProjectType")],
            by = "ProjectID") %>%
  mutate(YearEntered = year(ymd(EntryDate))) %>%
  filter(ProjectType == 2 & YearEntered == 2019)

th_both_years <- rbind(th_2018, th_2019) %>%
  group_by(YearEntered, ProjectID, ProjectName) %>%
  summarise(Count = n()) %>%
  pivot_wider(
    names_from = YearEntered, 
    values_from = Count
  ) %>%
  mutate(Difference = `2019` - `2018`)

# My response:
# The main difference I'm seeing in the data is the addition of our YHDP Crisis 
# TH project which served a lot of people in 2019 as compared to 2018. Those are
# Youth beds, but many of the households served were AC.


