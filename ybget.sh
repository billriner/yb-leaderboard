#!/usr/bin/env zsh

# ypget.sh - Get tracking data from Yellowbrick and create a KML file for Google Earth
#            Developer: Bill Riner

URL='https://yb.tl/l/chicagomac2021?class=section07'

DATE=
TIME=

# Get the current tracking data

#DATA=$(wget -qO- $URL)
#echo $DATA

# Convert to KML format

# THESE RESULTS ARE PREDICTED OR PROVISIONAL - Refer to race website for official results!
# Rank,Team,TCF,Time (UTC),Latitude,Longitude,Average COG,Average SOG (knots),VMG so far (knots),DTF (NM)
#
# Section 07
# 1,Bad Dog,1.034,20/07/2021 04:54:41,045 50.779N,084 37.148W,286,0.5,4.7,0.0
# 2,Archimedes III,1.059,20/07/2021 03:20:00,045 50.634N,084 36.510W,005,1.4,4.9,0.0
# 3,Le Reve,1.048,20/07/2021 06:42:21,045 50.783N,084 37.142W,225,0.4,4.6,0.0
# 4,Courageous,1.036,20/07/2021 06:55:35,045 50.780N,084 37.141W,217,0.2,4.6,0.0
# 5,Alpha Puppy,1.029,20/07/2021 07:00:25,045 50.780N,084 37.141W,209,1.1,4.6,0.0
# 6,Paradigm Shift,1.060,20/07/2021 05:29:56,045 50.781N,084 37.138W,224,0.5,4.7,0.0
# 7,Titan,1.034,20/07/2021 07:39:14,045 50.780N,084 37.140W,211,0.4,4.5,0.0
# 8,Night Train,1.036,20/07/2021 07:21:16,045 50.782N,084 37.141W,214,0.4,4.5,0.0
# 9,Papa Gaucho II,1.040,20/07/2021 07:00:00,045 50.922N,084 36.942W,318,0.3,4.6,0.0
# 10,Free Agent,1.050,20/07/2021 08:02:23,045 50.781N,084 37.138W,216,0.3,4.5,0.0
# 11,Captain Blood,1.042,20/07/2021 07:48:06,045 50.780N,084 37.135W,244,0.2,4.5,0.0
# 12,Maskwa,1.054,20/07/2021 07:25:26,045 50.782N,084 37.138W,211,0.6,4.5,0.0
# 13,Bravo,1.053,20/07/2021 11:57:13,045 50.780N,084 37.141W,213,0.2,4.2,0.0
# 14,Geronimo,1.057,20/07/2021 14:30:17,045 50.781N,084 37.141W,081,0.0,4.1,0.0
# 15,The Flying Spaghetti Monster,1.021,20/07/2021 16:18:27,045 50.779N,084 37.143W,208,0.9,4.0,0.0
# RTD,Pandora,1.046,20/07/2021 00:45:49,045 50.780N,084 37.138W,160,0.2,1.4,203.3

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

curl $URL >& /dev/null | awk -F, '

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
