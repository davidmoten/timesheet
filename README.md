timesheet
=========

Time recording web application configured for deployment to Google AppEngine. 

Status: *beta*

Features are:

* Very concise time entry
* Fast to use
* Creates printable report on specified time range with signature blocks for yourself and supervisor
* Enter your daily work periods using the numeric keypad as fast as you can type!
* Asynchronous non-blocking ui

<img src="https://raw.github.com/davidmoten/timesheet/master/src/docs/screen.png"/>

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

How to configure running application
--------------------------------------
Add the url parameter *n* = the number of days from today to go back in history and display in main view.

For example

    http://its-showtime.appspot.com?n=10

will show maximum 10 rows at a time.


