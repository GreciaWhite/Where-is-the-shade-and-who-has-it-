# Where is the shade and who has it?
As climate change brings more frequent heat waves we need to take stock of our resources and ensure we are supporting vulnerable populations. “Austin is also seeing an increase in the number of 100-degree days. In the 30-year period between 1981 and 2010, the average number of 100-degree days was 18. From 1990 to 2019, the average was 28 days.” - KUT, NPR Station

Here we will create 3 maps using U.S. Census, Capital Metro and City of Austin data to explore the topic of shade as it relates to public transit in the city of Austin, Texas.

We will create interactive maps with R using U.S. Census data by tract level from the Annual American Survey to measure median income and ages of those 60 years and older who use public transportation to get to work in Austin, Texas. We also use Capital Metro data to map out the bus stops that have a shade structure and those without any shade structure. We also use City of Austin Tree Canopy Map to map percentages of tree canopy cover across neighborhoods in Austin. 

<br>

## The three interactive maps we will build and the datasets we will use for each one


#### 1. Median household income + bus stops with and without shade structures

* U.S. Census data at the tract level for Austin, Texas. You will need to [request an API Key](https://api.census.gov/data/key_signup.html). It took me about 15 minutes to get mine. 

* [Capital Metro Shapefiles January 2020](https://data.texas.gov/Transportation/Capital-Metro-Shapefiles-JANUARY-2020/63b7-hxaj) 

<br>

#### 2. People 60 years or older who use public transit to get to work + bus stops with and without shade structures

* U.S. Census data at the tract level for Austin, Texas. 
    + People 60-64 years old who get to work by public transportation - Variable B08101_031	  
    + People 65 years and over who get to work by public transportation - variable B08101_032     

  
  
* Capital Metro Shapefiles January 2020
      
<br>

#### 3. Tree canopy + Neighborhood Planning Areas + bus stops with and without shade structures

* City of Austin Tree Canopy Map book which contains the percentages of tree canopy cover across neighborhoods in Austin. This is a PDF, but you can [download the CSV](https://docs.google.com/spreadsheets/d/1ptIINYTGmxdhp9P2UEXrbl7FC0qTLwgPEIbcstq2_QI/edit?usp=sharing) I created. If you want to access the full PDF, google *"Austin Tree Canopy Map Book."* The table can be found on page 8 and 9.

* [City of Austin Neighborhood Planning Areas Shapefiles](https://data.austintexas.gov/Locations-and-Maps/Neighborhood-Plan-Status/b2z2-zp7a)       


* Capital Metro Shapefiles January 2020


<br>

##### Other sites and sources:  

* [Using Tidy Census and Leaflet to Map Census Data](https://juliasilge.com/blog/using-tidycensus/) by Julia Silge 

* [Mapping Interactive Maps with Public Data in R](https://medium.com/civis-analytics/making-interactive-maps-of-public-data-in-r-d360c0e13f13) by Ryan Rosenberg

* If you're interested in the topic of shade I recommend the [Shade Episode](https://99percentinvisible.org/episode/shade/) by the 99% Invisible Podcast. It was recommended to me by my dear friend Kathleen Stanford and I loved it! 

* The podcast episode also led me to Sam Blocks's [Shade article](https://placesjournal.org/article/shade-an-urban-design-mandate/) on Places Journal. He brings up so many points I had never thought about before. 


<br><br>

Code, links and interacive maps are also available here: https://rpubs.com/grecia_white/shade_bus_stops_austin
