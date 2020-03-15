#### Our first map - Median household income + bus stops with and without shade structures.

##### Load in your libraries

#load libraries
library(tidyverse)
library(sf)
library(leaflet)
library(viridis)
require(rgdal)
require(sp)
library(stringr)
library(tidycensus)




#First, we will gather the U.S. Census data from the Annual American Survey using the R library tidycensus. Make sure you've requested your API key. You can add it below your libraries as census_api_key("YOUR KEY", install=TRUE)


#Before diving in, lets see what our variable options are. 


#see variable options
see_var <- load_variables(2018, "acs5", cache=TRUE) 



#Get the median income data from the U.S. Census at the tract level for Austin. Variable B19013_001 is the one we want. 

#Median household income
median_income <- get_acs(geography = "tract",
                        variables="B19013_001",
                        state="TX",
                        county="Travis County",
                        geometry=TRUE)


