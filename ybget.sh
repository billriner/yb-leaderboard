#!/usr/bin/env zsh

#*******************************************************************************
#
# ypget.sh - Get tracking data from Yellowbrick and create a KML file for 
#            Google Earth
#
#            Developer: Bill Riner
#
#********************************************************************************

# Web address for section text leaderboard
URL='https://yb.tl/l/chicagomac2021?class=section07'

# Example Yellowbrick text leaderboard file:
# THESE RESULTS ARE PREDICTED OR PROVISIONAL - Refer to race website for official results!
# Rank,Team,TCF,Time (UTC),Latitude,Longitude,Average COG,Average SOG (knots),VMG so far (knots),DTF (NM)
#
# Section 07
# 1,Bad Dog,1.034,20/07/2021 04:54:41,045 50.779N,084 37.148W,286,0.5,4.7,0.0
# :
# RTD,Pandora,1.046,20/07/2021 00:45:49,045 50.780N,084 37.138W,160,0.2,1.4,203.3

# Columns
# 1. Rank
# 2. Team
# 3. TCF
# 4. Time (UTC)
# 5. Latitude
# 6. Longitude
# 7. Average COG
# 8. Average SOG (knots)
# 9. VMG so far (knots)
# 10. DTF (nm)

# KML template
# <?xml version="1.0" encoding="UTF-8"?>
#<kml xmlns="http://www.opengis.net/kml/2.2">
#
#  <Placemark>
#
#    <name>A simple placemark on the ground</name>
#
#    <Point>
#			 <coordinates>8.542952335953721,47.36685263064198,0</coordinates>
#    </Point>
#
#  </Placemark>
#
#</kml>

# Get the current tracking data and write a KML file

# Save the leaderboard text file
DATE=`date | sed 's/ /-/g'`
curl -o $DATE.txt $URL

cat $DATE.txt | awk -F, > $DATE.kml '

    BEGIN {
        # Write KML header
        print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        print "<kml xmlns=\"http://www.opengis.net/kml/2.2\">"
        print "<Document>"
        print "  <name>Yellowbrick</name>"
    }

    ($1 !~ /[a-zA-Z]/) && (NF > 1) {

        rank = $1
        name = $2
        
        timedate = $4
        split($4,a," ")
        date = a[1]
        time = a[2]

        lat = $5
        lat = substr($5, 1, length($5)-1)
        ns = substr($5, length($5), 1)
        split(lat,a," ")
        latdeg = a[1] + 0.0
        latdec = a[2] + 0.0
        lat = latdeg + latdec / 60.0
        if (ns == "S") lat = -lat

        lon = substr($6, 1, length($6)-1)
        ew = substr($6, length($6), 1)
        split(lon,b," ")
        londeg = b[1] + 0.0
        londec = b[2] + 0.0
        lon = b[1] + b[2] / 60.0
        if (ew == "W") lon = -lon

        printf "  <Placemark>\n"
        printf "    <description>%s-%s</description>\n", date, time
        printf "    <name>%s</name>\n", name
        printf "    <Point>\n"
        printf "      <coordinates>%s,%s,0.0</coordinates>\n", lon, lat
        printf "    </Point>\n"
        printf "  </Placemark>\n"
    }

    END {
        print "</Document>"
        print "</kml>"
    }

'
