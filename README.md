timesheet
=========
[![Travis CI](https://travis-ci.org/davidmoten/timesheet.svg)](https://travis-ci.org/davidmoten/timesheet)<br/>

Time recording web application configured for deployment to Google AppEngine. I've been using this to record my time since at least 2012 and still works great (4 Dec 2020).

Status: *production*

Features are:

* Very concise time entry
* Fast to use
* Enter your daily work periods using the numeric keypad as fast as you can type!
* Creates printable report on specified time range with signature blocks for yourself and supervisor
* Displays graphs of your working hours by day, week, month, year
* Asynchronous non-blocking ui using JQueryUI
* Built and deployed with Maven
* Sends backup of all entered data in csv format to your email address on demand

<img src="https://raw.github.com/davidmoten/timesheet/master/src/docs/screen.png"/>

Demonstration
-------------------
[Demo on Youtube](http://www.youtube.com/watch?v=RsRdYpR1FGU).

Try it on Google AppEngine
----------------------------------
Go to http://its-showtime.appspot.com

How to build and run locally
-----------------------------
    mvn clean package appengine:devserver

Browse to [http://localhost:8080](http://localhost:8080)

How to run offline (rapid dev of html/js)
------------------------------------------
Open this file with your browser (and add the offline parameter):

    timesheet/src/main/webapp/main.jsp?offline=true

How to deploy to appengine
----------------------------
    mvn clean package appengine:update -Dappengine.app.name=<YOUR_APP_NAME>

If behind a proxy, use (for example):
    
    mvn clean package appengine:update -DproxySet=true -DproxyHost=proxy -DproxyPort=8080 -Dappengine.app.name=<YOUR-APP-NAME>




