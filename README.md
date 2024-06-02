
# Food Cart


This is a simple application that allow you to query the Mobile Food Facilty Permit data set [hosted Data SF site](https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat/data).  It consists of information on the mobile food vendors that are registered and operating. 

This command line application allows you - from the command line to search - the data set for a food cart by vendor, a food type or the type of cart (cart or truck).  In addition, a geo search is done (using third party API - [Radar](https://radar.com/search)) to find how far the food truck is by car and foot. 

## Configuration

The following dependencies need to be met to run  this project

- Ruyby 3.0+
- MongoDB

I will walk through a simple path to setup both of these on MacOS X (as that is my main development box).  If you are using Linux, it should be relatively simple as the steps are similar. 

In order for these steps to work correctly, you must have the latest version of XCode installed. This can easily be done via the Apple Appstore. 

Also we are using HomeBrew to install these dependencies.  Refer to the [home page for  installation](https://brew.sh/). 

### Setting up Ruby

By default - ruby is installed on MacOS x, however we will need an upgraded version of it.  You can install it manually but it is recommended that you use rbenv to manage versions.

In case you don't have rbenv we can use the homebrew to install:

```bash
brew install rbenv ruby-build
```
and then setup your shell to load rbenv

```bash
rbenv init
```

Close your Terminal window and open a new one so your changes take effect.  Now we will install Ruby 3.3.1

From a new terminal simply type:

```bash
rbenv install 3.3.1   
```

this will setup ruby 3.3.1 on your system.  CD into the this repo's directory you will be switched to ruby 3.3.1 - if not you can simply enter the followng command form inside this repo:

```bash
rbenv local 3.1.1
```

In the projects directory, pull all dependencies by typing:

```bash
bundle install
```

### Setting up MongoDB

To install MongoDB execute the following commands on the OS X terminal:

```bash
brew tap mongodb/brew  
brew install mongodb-community                                                         
brew install mongosh     
```

Thats it - we are all set.  Don't forget to start the mongo server by typing:

```bash
brew services start mongodb/brew/mongodb-community
```

Thats it for the dependencies.  Everything else needed to run this utility is part of the repo. Two more things regarding configuring the application. 

1. The mongo server information is located in config/mongoid.yml file. There should be no need to modify this file but if you do - change the host & database to point to your systems.
2. We are using the Radar third party API to query for geo. The config/radar.yml file contains the key definitions for API access. There is a test key that is used for free tier access witch should be okay for the purposes of the test. If you get api band with errors - you have will have to update this key (Go and create a new account and update the keys from the setup page). 

## Running the Foodcart application

This application will allow you to find the nearest food carts to your location with the criteria of the who owns the food cart and the food that vendor serves.  Also we will use a provided address to perform a geo based search for the closest vendors.  

Here is the options for the app:

```console
Usage: foodcart [options]
    -f, --food <food>                the food that cart offers
    -t, --type <type>                type of cart
    -a, --address <address>          address where you are located
    -d, --distance <distance>        distance between carts
    -v, --vendor <vendor>            food cart owner
    -h, --help                       Prints this help
```

Here are two examples of usage:

In the following example we are looking for all food carts with that are owned by 'natan' that are 1000 meters away from the address of 2343 3rd St UNIT 100, San Francisco, CA 94107

```bash
vijayparikh@Vijays-Mac-mini> foodcart % bundle exec ruby ./bin/foodcart.rb -v "natan" -a "2343 3rd St UNIT 100, San Francisco, CA 94107" -d 1000
```

output

```

OWNER            | ADDRESS                      | FOOD                           | CAR     | FOOT   
-----------------|------------------------------|--------------------------------|---------|--------
Natan's Catering | Assessors Block 4058/Lot010  | Burgers: melts: hot dogs: b... | 0.2 min | 2 mins 
Natan's Catering | Assessors Block 4172/Lot010  | Burgers: melts: hot dogs: b... | 1 min   | 4 mins 
Natan's Catering | Assessors Block 4046/Lot001  | Burgers: melts: hot dogs: b... | 1 min   | 6 mins 
Natan's Catering | Assessors Block 4103/Lot023A | Burgers: melts: hot dogs: b... | 1 min   | 9 mins 
Natan's Catering | Assessors Block 3941/Lot001  | Burgers: melts: hot dogs: b... | 1 min   | 8 mins 
Natan's Catering | 435 23RD ST                  | Burgers: melts: hot dogs: b... | 2 mins  | 11 mins
Natan's Catering | 555 MISSOURI ST              | Burgers: melts: hot dogs: b... | 2 mins  | 10 mins
Natan's Catering | Assessors Block 4227/Lot012  | Burgers: melts: hot dogs: b... | 2 mins  | 12 mins
Natan's Catering | Assessors Block 4241/Lot002  | Burgers: melts: hot dogs: b... | 3 mins  | 13 mins
Natan's Catering | Assessors Block 4296/Lot010  | Burgers: melts: hot dogs: b... | 3 mins  | 10 mins
Natan's Catering | 600 16TH ST                  | Burgers: melts: hot dogs: b... | 2 mins  | 12 mins
Natan's Catering | Assessors Block 8722/Lot001  | Burgers: melts: hot dogs: b... | 2 mins  | 12 mins
Natan's Catering | Assessors Block 8722/Lot003  | Burgers: melts: hot dogs: b... | 2 mins  | 14 mins
```

Here is another example of searching for all vendors that are near us that have tacos:

```bash
vijayparikh@Vijays-Mac-mini> foodcart % bundle exec ruby ./bin/foodcart.rb -f tacos -a "2343 3rd St UNIT 100, San Francisco, CA 94107" -d 1000
```
output:

```
OWNER          | ADDRESS         | FOOD                           | CAR    | FOOT   
---------------|-----------------|--------------------------------|--------|--------
Street Meet    | 777 MARIPOSA ST | Tacos: burritos: quesadilla... | 1 min  | 9 mins 
Tacos El Flaco | 2901 03RD ST    | Tacos: Burritos: Tortas: Qu... | 3 mins | 10 mins
Buenafe        | 901 16TH ST     | Tacos burritos quesadillas ... | 2 mins | 15 mins
```

### Next Steps
As stated earlier - we have time boxed our selves to four to five hours.  Given this time frame, we have made great progress and consider this a proof of concept (databse, apis, geo search, etc.) However, given more development time:

- currently we are hard coding our access keys.  This definitely needs to change as this is not secure.  Ideally:
  - we could save it in a secure key store like [Vault](https://www.vaultproject.io/) and query them as we need this is the best solution
  - alternatively we can have the key stored as environment variables and that way they are not in the repo in plain site.  This requires more complexity in deployment / maintenance than using a tool like Vault
- If we create a web app - configure single sign on 
- A test suit that mocks the actual data set calls so that we can test the functionality repeatably without the full infrastructure setup
- Directly pull the data set from web site and update it on a scheduled bases 
  - ideally monitor for updates and download and install it
- provide a more robust web based UI.
  - a web based UI to collect search criteria
  - possibly use the local IP address to determine the address
  - in addition to displaying the result sets on a tabular table, have a map with pins for each location
  - a click on the resulting data record should show you a web page of a map with the route and step by step directions for it (this is accessible by Google Maps API and Radar)
- a better deployment method then the current manual one. Ideally I would have setup a docker image that you can just run locally to avoid and setup/dependency issues at all.
- do proper research of the data set - there are fields that are [not obvious on their meaning](https://github.com/vijayparikh/foodcart/blob/70ab6f9df5a0fc85d91c475bb418570e684dade7/lib/mobile_food_facility.rb#L36) 
- Tune geo queries / lookups for better performance and accuracy
- Pick the correct tech stack for this project for production / cost efficiency currently the criteria was minimize time/complexity. 
  - If we are going for outright performance, NodeJS would be the obvious choice (optimized to maintain even based structure)
  - however, I am a big fan of RAILS as it is the best backend system for maintainability and quick development. 
  - Mongo database configuration - setup Geo shards / replication properly  (obviously depends on how much data we have)

### Thoughts

I have time boxed 4-5 hours for this project.   

- Looking over the data set, we have a list of food vendors, their operating locations with geo and addresses. We dont have detailed look at the data set info, but looking through the data, it seems pretty much self evident. The fields which are not obvious, we really don't need for our main app build.
- regarding the app build - I decided that the most import thing I would want is to search for is either by the name, the type of vendor and food that they offer. We would need to search by how far it is from our location.
- The first issues was how to figure out where we are located.  I quickly did research on any available third party APIs - none of the free ones were acceptable.  We need a reverse geo lookup, and a distance to vendor from an address.  Could have used Google API but they are overly complicated.  Came across Radar which had a very dev friendly API with a generous free tier for what we are looking to do
- Choosing a database was a bit tricky and would have large consequences and what can be easily done - especially in the time frames we needed it to happen.  Initially the thought was to use postgresql with some extentions for Geo. However the setup complexity was two high for our time frame. MongoDB - a 'NoSQL' database that I had used extensively in the past fit the use case here perfectly:
  - It allows for direct storage of JSON objects - so no need to constantly convert between datasets
  - provides excellent API for searches and updates
    - In addition to the native JSON based SQL query language - there is an officially supported ORM for our chosen environment - Mongoid. 
    - MongoDB has built in first class support for geo searches - really easy to perform
    - Easy to install and get up and running with minimal fuss
    - low overhead and minimal footprint
  - Next came the language to use, as we are not bounded by our choice.  I wold normally use JavaScript for front end / backend work - but the time to prototype is high with all of the various libraries and setup involved.  Ruby is a great scripting language that is fast and great to prototype with.  Plus it has large set of libraries to do just about anything that are very well documented.  And has the best package manager I have used.  So I decided to go with Ruby for this project
  - Initially I was thinking that we setup a web UI to collect our inputs and then query the back end of the system and plot the items on a map (using the Google API). But quickly retreated on this idea as it would not be solvable in our time box.  The next best thing to do was drop down to a command line tool. 
  - Researching the Radar API - a simple API to get the two things we need:
    - a lookup of the address to the geo location (lat,long)
    - a lookup of distances between two coordinates
      - we can do this with mongodb or a simple haversion algorithm compute but Radar already has that functionality - plus we get distances with both cars & foot traffic! This is a plus for our functionality
      - The API is extremely simple to use and has a free tier that is suitable to our list
- First we need to get the data into our db - so I used the Mongoid ORM to do this, seemed to be the quickest and simplest way, and was an excuse to learn the use of the ORM system. 
  - was able to get the basics of the ORM working, however could not get the geo lookups working through the ORM. 
  - Instead of struggling with this  - I just decided to use the native MongoDB querying for our use case as it was simple enough
- Querying the data was simple enough.  Mongo uses GeoJSON for our geo queries - and we lucked out on this as that is the same format that is used by Radar. 
- Querying the data turned out to be simple - we had four queries - search for vendor, food, truck type and geo distances
  - these were all combined in an and logic as they are all filtering out data 
  - would have been ideal to enforce / assume SF region but decided against to maintain time 
  - We are doing minimal validation and safety checks on this, again due to time boxing
  - Ideally would like to see performance metrics on these as I am sure the queries are sub optimal at this point, but again need to get this to work in the time allotment.
- Outputting data to tabular format was extremely simple - a gem already existed for what we needed. 
- Really wish I could spend more time with error checking and defensive coding - but I view this as a proof of concept and so we will let this slide for now
- Approaching the time limit and we have our initial stated functionality done. 
