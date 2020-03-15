#### Our first map - Median household income + bus stops with and without shade structures.

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


#------------------------------------------------------------------------------------------------------

##### Now we'll get the bus stop info from Capital Metro

#After you donwload the zip file containing the Capital Metro Shapefiles you will need to unzip it or extract the files. You will see shapefiles for *ADA*, *Routes*, *Service* *Area*, *Stops* *and* *Transit* *Hubs*.
#We are just focusing on *Stops*. I created folders to separate each group of files. Lets get the bus stops that have at least one shelter. 


#Read the shapefile
stops <- readOGR("C:/Users/greci/Documents/Northeastern/capmetro/ForRMarkdown/stops/Stops.shp")

#convert to data frame
stops <- data.frame(stops)


#get the stops that have at least one shelter
stops_withshelters <- subset(stops, SHELTERS!=0)

#save dataset as a csv
write.csv(stops_withshelters, 'stops_withshelters.csv')



#Get the bus stops with no shelters. Because the max number of shelters at one stop is 4 shelters, I removed each one at a time. If there had been more I would have done it more programmatically. There's mnay ways to do this part.  


#remove stops with 1 shelter
stops_noshelter <- subset(stops, SHELTERS!=1)

#remove stops with 2 shelters
stops_noshelter <- subset(stops_noshelter, SHELTERS!=2)

#remove stops with 3 shelters
stops_noshelter <- subset(stops_noshelter, SHELTERS!=3)

#remove stops with 4 shelters
stops_noshelter <- subset(stops_noshelter, SHELTERS!=4)


#save dataset as a csv
write.csv(stops_noshelter, "stops_noshelter.csv")



#----------------------------------------------------------------------------------------------

##### Lets start building our median income map

#Set the color palette for median income
pal <- colorNumeric(palette = "plasma",
                    domain= median_income$estimate)


#build map for income
map_median_income <- median_income %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width="100%") %>%
  addProviderTiles(provider="CartoDB.Positron") %>%
  addPolygons(popup =~str_extract(NAME, "^([^,]*)"),
              stroke=FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color= ~pal(estimate))%>%
  addLegend("bottomright",
            pal=pal,
            values= ~estimate,
            title= "Median Household </br> Income",
            labFormat = labelFormat(prefix= "$"),
            opacity = 1)

map_median_income


#-------------------------------------------------------------------------------------------------------------------

##### Now get the colors for our bus stops ready. 
Stops with shelter/s will be in green and stops with no shelter/s will be in black
Read in our bust stop csvs. **We will use these same variables when adding bus stop info to all of our maps.** 
```{r, warning=FALSE, message=FALSE}
#Load in bus data for stops with a shelter(s)
stops_withshelter<- read_csv("stops_withshelters.csv")


#Select color for stops with a shelter/s, I chose a light green
pal_stop2 <- colorFactor(
  palette = "#52de97",
  domain = stops_withshelter$STOP_NAME
)

#Load csv containing bus stops with no shelter(s)
stops_noshelter <- read_csv("stops_noshelter.csv")

#Choose color for stops with no shelter(s), i chose black
pal_stop3 <- colorFactor(
  palette = "#000000",
  domain = stops_noshelter$STOP_NAME
)


#-----------------------------------------------------------------------------------------------

##### Lets add our bus stop data to our median income map
#build the map
map_median_income_stops <- median_income %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width="100%", height=820) %>%
  addProviderTiles(provider="CartoDB.Positron") %>%
  addPolygons(popup =~str_extract(NAME, "^([^,]*)"),
              stroke=FALSE,
              smoothFactor = 0,
              fillOpacity = 0.6,
              color= ~pal(estimate))%>%
  addLegend("bottomright",
            pal=pal,
            values= ~estimate,
            title= "Median Household Income <br> in Travis County",
            labFormat = labelFormat(prefix= "$ "),
            opacity = 1) %>%
  addCircleMarkers(data=stops_withshelter,
                   popup= ~STOP_NAME,
                   stroke= F,
                   radius=2,
                   fillColor=~pal_stop2(STOP_NAME),
                   fillOpacity=1.3) %>%
  addCircleMarkers(data=stops_noshelter,
                   popup= ~STOP_NAME,
                   stroke= F,
                   radius=2,
                   fillColor=~pal_stop3(STOP_NAME),
                   fillOpacity=1.3) 

map_median_income_stops

#----------------------------------------------------------------------------------------------------------



#### On to our second map! - People 60yrs+ who use public transit to get to work + bus stops with and without shade structures
#Age is a risk factor for heat exhaustion, those 60 year or older are particularly vulnerable. Luckily for us, the Annual American Survey collects info on age and modes of transportation to work. 

#We will use these variables:   
#*B08101_031	Estimate!!Total!!Public transportation (excluding taxicab)!!60 to 64 years	MEANS OF TRANSPORTATION TO WORK BY AGE*
#*B08101_032	Estimate!!Total!!Public transportation (excluding taxicab)!!65 years and over	MEANS OF TRANSPORTATION TO WORK BY AGE*



##### Lets get the number of elderly folks who use public transportation to get to work
#B08101_031 60-64yrs old
age60_64 <- get_acs(geography = "tract",
                        variables="B08101_031",
                        state="TX",
                        county="Travis County",
                        geometry=TRUE)

#B08101_032 65 and older
age65_plus <- get_acs(geography = "tract",
                    variables="B08101_032",
                    state="TX",
                    county="Travis County",
                    geometry=TRUE)   



#Lets combine the datasets. I tried st_join but kept getting this message "although coordinates are longitude/latitude, st_intersects assumes that they are planar" so I just added a new column to the age60_64 dataframe named "new" to add the estimate columns from both dataframes 

#create new column named "new" containing the addition of estimates from both datasets
age60_64$new <- age60_64$estimate + age65_plus$estimate


#------------------------------------------------------------------------------------------------------

##### Lets make our age map

#map out the 60+ years dataframe, using the "new" column
#Set the color palette for median age
pal <- colorNumeric(palette = "plasma",
                    domain= age60_64$new)


#build map for 60+ years
map_age <- age60_64 %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width="100%") %>%
  addProviderTiles(provider="CartoDB.Positron") %>%
  addPolygons(popup =~str_extract(NAME, "^([^,]*)"),
              stroke=FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color= ~pal(new))%>%
  addLegend("bottomright",
            pal=pal,
            values= ~new,
            title= "People 60 Years or Older Who </br> Take Public Tranportation to Work </br>
            (excluding taxicab)",
            labFormat = labelFormat(suffix= " people"),
            opacity = 1)

map_age


#------------------------------------------------------------------------------------------------------


##### Adding our bus stop info to our age map

#add the stops with no shelters and stops with shelters to map of 60+ yrs

map_age_stops <- age60_64 %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width="100%", height=820) %>%
  addProviderTiles(provider="CartoDB.Positron") %>%
  addPolygons(popup =~str_extract(NAME, "^([^,]*)"),
              stroke=FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color= ~pal(new))%>%
  addLegend("bottomright",
            pal=pal,
            values= ~new,
            title= "People 60 Years or Older Who </br> Take Public Tranportation to Work </br>
            (excluding taxicab)",
            labFormat = labelFormat(suffix= " people"),
            opacity = 1) %>%
  addCircleMarkers(data=stops_withshelter,
                   popup= ~STOP_NAME,
                   stroke= F,
                   radius=2,
                   fillColor=~pal_stop2(STOP_NAME),
                   fillOpacity=1) %>%
  addCircleMarkers(data=stops_noshelter,
                   popup= ~STOP_NAME,
                   stroke= F,
                   radius=2,
                   fillColor=~pal_stop3(STOP_NAME),
                   fillOpacity=1) 

map_age_stops

#------------------------------------------------------------------------------------------------------------


#### Now to our last map! - Tree canopy + Neighborhood Plannin Areas + bus stops with and without shade structures
##### Load our neighborhood files
#I saved the neighborhood shapefiles in a folder *"neighborhood_plans_austin"*.

#read in the neighborhood shapefiles
neighborhoods <- read_sf("neighborhood_plans_austin")



##### Next we need data on Tree Canopy Coverage  

#This part took some digging since there is no public dataset resembling a tree inventory for Austin. Google "austin neighborhood canopy tour 2006 data". Click on [ ] to download the PDF. Scroll to page 8 to find the table containing percetages of canopy cover by neighborhood. I created google sheets and dowloaded it into a csv. You can access it here. As you can see some of the neighborhood names are repeated in my csv. I had to do this in order for the number or rows to match those of the neighborhood file. 

#read in the csv file
trees <- read_csv("TREE_CANOPY.csv")



#Combine the tree canopy csv with the neighborhood planning areas file
#I believe this is necessary for the format of the map
neighborhoods <- neighborhoods %>%
  st_transform(4326) 


#join the datasets, they are joined by the column they have in common, "planning_a" 
joined <- neighborhoods %>%
  inner_join(trees)


#------------------------------------------------------------------------------------------------------

##### Lets make our tree canopy map

#the color palette for percentage
pal <- colorNumeric(palette = "plasma",
                    domain= joined$percentage_canopy_cover)

#create popup label
joined_clean <- joined %>%
  mutate(popup_label = paste(paste0( planning_a, '</b>'),
                             paste0(percentage_canopy_cover, '%'), 
                             sep = '<br/>'))   
  
#build map with canopy coverage
map_canopy <- joined_clean %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width="100%") %>%
  addProviderTiles(provider="CartoDB.Positron") %>%
  addPolygons(stroke=FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color= ~pal(percentage_canopy_cover),
              popup = ~popup_label)%>%
  addLegend("bottomright",
            pal=pal,
            values= ~percentage_canopy_cover,
            title= "Percentage of Canopy Cover",
            labFormat = labelFormat(suffix= " %"),
            opacity = 1) 

map_canopy



##### Adding our bus stop info to our tree canopy map
#build map with canopy coverage
map_canopy_stops <- joined_clean %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width="100%") %>%
  addProviderTiles(provider="CartoDB.Positron") %>%
  addPolygons(stroke=FALSE,
              smoothFactor = 0,
              fillOpacity = 0.7,
              color= ~pal(percentage_canopy_cover),
              popup = ~popup_label)%>%
  addLegend("bottomright",
            pal=pal,
            values= ~percentage_canopy_cover,
            title= "Percentage of Canopy Cover",
            labFormat = labelFormat(suffix= " %"),
            opacity = 1) %>%
  addCircleMarkers(data=stops_withshelter,
                   popup= ~STOP_NAME,
                   stroke= F,
                   radius=2,
                   fillColor=~pal_stop2(STOP_NAME),
                   fillOpacity=1) %>%
  addCircleMarkers(data=stops_noshelter,
                   popup= ~STOP_NAME,
                   stroke= F,
                   radius=2,
                   fillColor=~pal_stop3(STOP_NAME),
                   fillOpacity=1) 

map_canopy_stops



##### And we're done! 

#Thank you for powering through. If you have any questions I can be reached at *white.gr@husky.neu.edu*. I'm still at a beginner level, but can try my best to clear any confusion. 

