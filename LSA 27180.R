library(tidyverse)
library(lubridate)

load("data/COHHIOHMIS.RData")

ReportStart <- "10012017"
ReportEnd <- "09302018"
ReportingPeriod <- interval(mdy(ReportStart), mdy(ReportEnd))

# Creating Beds table -----------------------------------------------------

SmallProject <- Project %>%
  select(ProjectID,
         ProjectName,
         ProjectType) %>%
  filter(ProjectType %in% c(1, 2, 3, 8, 9, 13) &
           operating_between(Project, ReportStart, ReportEnd) &
           is.na(Project$GrantType))

SmallInventory <- Inventory %>%
  select(
    ProjectID,
    HouseholdType,
    UnitInventory,
    BedInventory,
    InventoryStartDate,
    InventoryEndDate,
    HMISParticipatingBeds
  )  %>%
  filter((
    ymd(InventoryStartDate) <= mdy(ReportEnd) &
      (
        ymd(InventoryEndDate) >= mdy(ReportStart) |
          is.na(InventoryEndDate)
      )
  ) &
    !is.na(HMISParticipatingBeds) &
    Inventory$CoCCode == "OH-507")

Beds <- inner_join(SmallProject, SmallInventory, by = "ProjectID")
# Creating Utilizers table ------------------------------------------------

SmallEnrollment <- Enrollment %>% 
  select(PersonalID,
         EnrollmentID,
         ProjectID,
         EntryDate,
         ExitDate,
         HouseholdID,
         RelationshipToHoH,
         MoveInDate)

Utilizers <- semi_join(SmallEnrollment, Beds, by = "ProjectID") 

Utilizers <- left_join(Utilizers, SmallProject, by = "ProjectID") %>%
  select(
    PersonalID,
    EnrollmentID,
    ProjectID,
    ProjectName,
    ProjectType,
    HouseholdID,
    RelationshipToHoH,
    EntryDate,
    MoveInDate,
    ExitDate
  )
# Cleaning up the house ---------------------------------------------------

rm(Affiliation, Client, Disabilities, EmploymentEducation, EnrollmentCoC, Exit, 
   Export, Funder, Geography, HealthAndDV, IncomeBenefits, Organization, 
   ProjectCoC, Scores, Services, SmallEnrollment, SmallInventory, SmallProject, 
   Users, Offers, VeteranCE)
# Client Utilization of Beds ----------------------------------------------

# filtering out any PSH or RRH records without a proper Move-In Date plus the 
# fake training providers
ClientUtilizers <- Utilizers %>%
  mutate(EntryAdjust = case_when(
    ProjectType %in% c(1, 2, 8) ~ EntryDate,
    ProjectType %in% c(3, 9, 13) ~ MoveInDate),
    ExitAdjust = if_else(is.na(ExitDate), today(), ymd(ExitDate)),
    StayWindow = interval(ymd(EntryAdjust), ymd(ExitAdjust))
  ) %>%
  filter(
    int_overlaps(StayWindow, ReportingPeriod) &
      (
        (
          ProjectType %in% c(3, 9, 13) &
            !is.na(EntryAdjust) &
            ymd(MoveInDate) >= ymd(EntryDate) &
            ymd(MoveInDate) < ymd(ExitAdjust)
        ) |
          ProjectType %in% c(1, 2, 8)
      ) &
      !ProjectID %in% c(1775, 1695, 1849, 1032, 1030, 1031, 1317))

# actual lsa figurings ----------------------------------------------------

projectx <- ClientUtilizers %>% filter(ProjectID == 1017)

projectx <- projectx %>% 
  mutate(daysinproject = difftime(ExitAdjust, EntryAdjust, units = "days"))

projectx %>% group_by(ProjectID) %>% summarise(avg = mean(daysinproject))

projectxSingles <- projectx %>% filter(grepl("s_", HouseholdID))

projectxSingles %>% group_by(ProjectID) %>% summarise(avg = mean(daysinproject))

projectxHHs <- projectx %>% filter(grepl("h_", HouseholdID))

projectxHHs %>% group_by(ProjectID) %>% summarise(avg = mean(daysinproject))

rm(projectx, projectxSingles, projectxHHs)
