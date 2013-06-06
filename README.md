timesheet
=========

Time recording web application using Google Big Table storage on Google AppEngine. 

Features are:

* Very concise time entry.
* Creates printable report on specified time range with signature blocks for yourself and supervisor.
* Enter your daily work periods using the numeric keypad as fast as you can type!
* Asynchronous non-blocking ui

Try timesheet on Google AppEngine
----------------------------------
Go to http://its-showtime.appspot.com

How to build and run locally
-----------------------------
    mvn clean package appengine:devserver

Browse to [http://localhost:8080](http://localhost:8080)

    

How to run offline (rapid dev of html/js)
------------------------------------------

Browse to file://&lt;WORKSPACE&gt;/timesheet/src/main/webapp/main.jsp?offline=true

How to deploy to appengine
----------------------------
    mvn clean package appengine:update


