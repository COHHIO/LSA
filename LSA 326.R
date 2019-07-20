#COHHIO_HMIS
#Copyright (C) 2019  Coalition on Homelessness and Housing in Ohio (COHHIO)

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published
#by the Free Software Foundation, either version 3 of the License, or
#any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#GNU Affero General Public License for more details at 
#<https://www.gnu.org/licenses/>.

library(tidyverse)

load("data/COHHIOHMIS.RData")

# trying to find where hohs are toddlers

needle <- Enrollment %>%
  filter(RelationshipToHoH == 1 & 
           AgeAtEntry < 6 & 
           served_between(Enrollment, "10012017", "09302018")) %>%
  select(EnrollmentID, PersonalID, HouseholdID, EntryDate, ExitDate, AgeAtEntry)

  
  