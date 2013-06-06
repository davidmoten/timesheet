timesheet
=========

timesheet web application

How to run 
--------------
    mvn clean package appengine:devserver
Browse to http://localhost:8080

How to run offline (rapid dev of html/js)
------------------------------------------

Browse to file://<WORKSPACE>/timesheet/src/main/webapp/main.jsp?offline=true

How to deploy to appengine
----------------------------
    mvn clean package appengine:update
