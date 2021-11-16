################################################################################
#
# Example R script for accessing ODK Central data using ruODK package
#
################################################################################

## Load libraries --------------------------------------------------------------
if (!require(remotes)) install.packages("remotes")
if (!require(ruODK)) remotes::install_github("ropensci/ruODK")
if (!require(dplyr)) install.packages("dplyr")
if (!require(zscorer)) install.packages("zscorer")
if (!require(nutricheckr)) remotes::install_github("nutriverse/nutrichecker")


## Setup connection with ODK Central and the anthropometry form ----------------
ru_setup(
  svc = "https://odk.eha.io/v1/projects/1/forms/anthropometry.svc",
  un = "YOUR_USERNAME_HERE",     ## replace with your EHA ODK username
  pw = "YOUR_PASSWORD_HERE",     ## replace with your EHA ODK password
  tz = "GMT",
  odkc_version = "1.3"
)


## Retrieve anthropometric data using ruODK ------------------------------------
anthro <- odata_submission_get()


## Calculate anthropometric z-scores -------------------------------------------
anthro_zscores <- anthro %>%
  mutate(age_days = anthropometry_age * (365.25 / 12)) %>%
  addWGSR( 
    sex = "anthropometry_sex", 
    firstPart = "anthropometry_weight",
    secondPart = "age_days",
    index = "wfa"
  ) %>%
  addWGSR(
    sex = "anthropometry_sex",
    firstPart = "anthropometry_height",
    secondPart = "age_days",
    index = "hfa"
  ) %>%
  addWGSR(
    sex = "anthropometry_sex",
    firstPart = "anthropometry_weight",
    secondPart = "anthropometry_height",
    index = "wfh"
  )


## Flag z-scores using WHO criteria --------------------------------------------
anthro_flags <- anthro_zscores %>%
  flag_who(haz = "hfaz", waz = "wfaz", whz = "wfhz")


## Get a list of rows of data with flags ---------------------------------------
anthro_for_checking <- anthro_flags %>%
  filter(flag != 0)



