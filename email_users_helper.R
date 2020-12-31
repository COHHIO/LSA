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

# optionally, edit the issue vector to include the flag number and/or whatever 
# the issue is so that when you export the data, you know what these providers 
# have in common.

# then replace the Provider IDs of the providers_in_question vector to get a list of
# all users (default and not) who have access to those providers.

library(tidyverse)
library(readxl)

issue <- "Flag 967: served only 1 hh in LSA1 and that hh didn't move in"

# What group of providers has the issue -----------------------------------

providers_in_question <- c(
  1671, 1890, 1904, 1922, 2051
)

# Grabbing all users associated with these Provider IDs -------------------

# can't join in EDAGroupID because the IDs out of ART are wrong

users <- read_xlsx("data/RMisc2.xlsx",
                            sheet = 15,
                            range = cell_cols("B:E")) 

Project <- read_csv("data/Project.csv")

providers <- read_xlsx("data/RMisc2.xlsx",
                       sheet = 16,
                       range = cell_cols("B:D")) %>%
  filter(ProjectID %in% providers_in_question) %>%
  left_join(Project[c("ProjectID", "ProjectName", "ProjectType")], by = "ProjectID")

associated_users <- providers %>%
  left_join(users, by = c("EDAGroup" = "EDAGroupName")) %>%
  mutate(Issue = issue) %>%
  select(ProjectID, ProjectName, ProjectType, UserName, UserEmail, Issue) %>%
  filter(!is.na(UserName)) %>%
  unique()

write_csv(associated_users, "email_the_users.csv")
