library(tidyverse)

load("data/COHHIOHMIS.RData")

# trying to find where hohs are toddlers

needle <- Enrollment %>%
  filter(RelationshipToHoH == 1 & 
           AgeAtEntry < 6 & 
           served_between(Enrollment, "10012017", "09302018")) %>%
  select(EnrollmentID, PersonalID, HouseholdID, EntryDate, ExitDate, AgeAtEntry)

  
  