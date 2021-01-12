# COHHIO_HMIS
# Copyright (C) 2021  Coalition on Homelessness and Housing in Ohio (COHHIO)
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

# Op Start Date should be when the first client is served. This only catches
# when an Op Start Date and a First Entry crosses an LSA boundary.

library(tidyverse)
library(lubridate)

# Enrollment <- read_csv("data/Enrollment.csv")
# Exit <- read_csv("data/Exit.csv")
# Project <- read_csv("data/Project.csv")

current_clients <- Enrollment %>%
  filter(is.na(ExitDate)) %>%
  group_by(ProjectID, ProjectType) %>%
  summarise(current = n())

Op_Starts <- Project %>% 
  filter(ProjectType %in% c(1, 2, 3, 8, 9, 13)) %>%
  select(ProjectID, ProjectName, OperatingStartDate, ProjectType)

First_Entry <- Op_Starts %>%
  left_join(Enrollment[c("ProjectID", "HouseholdID", "EntryDate", "MoveInDateAdjust")], by = "ProjectID") %>%
  filter(ProjectType %in% c(1, 2, 3, 8, 9, 13)) %>%
  group_by(ProjectID, ProjectType) %>%
  summarise(FirstEntry = min(ymd(EntryDate)),
            FirstMoveIn = min(ymd(MoveInDateAdjust)))

should_not_be_in_lsa1 <- First_Entry %>%
  left_join(Op_Starts, by = c("ProjectID", "ProjectType")) %>%
  filter(FirstEntry >= mdy("10012019") & 
           OperatingStartDate < mdy("10012019"))

should_not_be_in_lsa2 <- First_Entry %>%
  left_join(Op_Starts, by = c("ProjectID", "ProjectType")) %>%
  filter(FirstEntry >= mdy("10012020") & 
           OperatingStartDate < mdy("10012020"))

Op_Ends <- Project %>% 
  filter(ProjectType %in% c(1, 2, 3, 8, 9, 13)) %>%
  select(ProjectID, ProjectName, OperatingEndDate, ProjectType)

Last_Exit <- Op_Ends %>%
  left_join(Enrollment[c("ProjectID", "HouseholdID", "ExitDate")], by = "ProjectID") %>%
  filter(ProjectType %in% c(1, 2, 3, 8, 9, 13) & !is.na(ExitDate)) %>%
  group_by(ProjectID, ProjectType, OperatingEndDate) %>%
  summarise(LastExit = max(ymd(ExitDate))) %>%
  left_join(current_clients, by = c("ProjectID", "ProjectType"))




