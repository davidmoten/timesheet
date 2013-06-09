<!doctype html>

<html lang="en">
<head>
<meta charset="utf-8" />
<title>Showtime</title>

<link rel="stylesheet" media="all"
	href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/smoothness/jquery-ui.css" />
<script
	src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script
	src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>

<script src="jquery.sortElements.js"></script>
<style type="text/css">
@media print {
	.noprint {
		display: none;
	}
}

body {
	font-family: "Trebuchet MS", "Helvetica", "Arial", "Verdana",
		"sans-serif";
	font-size: 80%;
}

.bold {
	font-weight:bold;
}

.busy {
	color: green;
}

#table,td {
	padding-right: 30px;
}

.invisible {
	visibility: hidden;
}

.invisibleCompact {
	display: none;
}

.invalid {
	color: red;
}

.links {
	color: blue;
	padding-bottom: 30px;
}

.link {
	float: left;
	padding-right: 20px;
	cursor: pointer;
}

#more {
	color: blue;
	margin-top: 10px;
	cursor: pointer;
}

.delete {
	color: blue;
	cursor: pointer;
}

#main {
	clear: both;
}

#nonBanner {
	margin-left: 5%;
	margin-top: 2%;
}

#banner {
   margin-left: -8px;
   margin-top: -8px;
}

#day {
	width: 6.5em;
	float: left;
	padding-top: 4px;
}

#date {
	width: 7em;
	float: left;
	padding-top: 4px;
}

#entryHelp {
	float:left;
	padding-top:3px;
	padding-left:10px;
}

#help {
	padding-top:0.5em;
	padding-bottom:0.5em;
	padding-left:1em;
	padding-right:1em;
	font-size:80%;
	background-color:rgb(240,240,240);
	width:50em;
	max-width: 85%;
	margin-bottom:0.5em;
	border:thin solid;
	border-color:gray;
}

.timesDay {
	float: left;
	width: 6.5em;
}

.timesDate {
	float: left;
	width: 7em;
}

.timesFrom {
	float: left;
	width: 4em;
}

.timesTo {
	float: left;
	width: 4em;
}

.timesDelete {
	float: left;
	width: 5em;
}

.timesMsg {
	float: left;
}

#time-range {
	width: 7em;
	margin-bottom: 10px;
	float:left;
}

#standardDay {
	width: 20em;
}

#autoAdvanceTime {
	width: 4em;
}

.help {
	font-size: 62.5%;
	margin-left: 2em;
}

.reportDayOfWeek {
	float: left;
	width: 12em;
}

.reportDate {
	float: left;
	width: 12em;
}

.reportTimeFrom {
	float: left;
	width: 4em;
}

.reportTimeTo {
	float: left;
	width: 4em;
}

.spaceBelow {
	margin-bottom: 5em;
}

.no-close .ui-dialog-titlebar-close {
	display: none;
}
</style>
<script>
  $(function() {
	  
	$.ajaxSetup ({  
	    cache: false  
	});

	var weekday=new Array(7);
	weekday[0]="Sunday";
	weekday[1]="Monday";
	weekday[2]="Tuesday";
	weekday[3]="Wednesday";
	weekday[4]="Thursday";
	weekday[5]="Friday";
	weekday[6]="Saturday";
	
	var months=new Array(12);
	months[0]="Jan";
	months[1]="Feb";
	months[2]="Mar";
	months[3]="Apr";
	months[4]="May";
	months[5]="Jun";
	months[6]="Jul";
	months[7]="Aug";
	months[8]="Sep";
	months[9]="Oct";
	months[10]="Nov";
	months[11]="Dec";

    var settings={};
//    settings.autoAdvanceTime="15:00"
//    settings.standardDay="08301230 13001700";
     settings.workingDays=[2,3,4,5];

	var theDate = new Date();
	theDate.setHours(0);
	theDate.setMinutes(0);
	theDate.setSeconds(0);
	theDate.setMilliseconds(0);


    function formattedDate(d) {
     var dd = d.getDate();
	 var mm = d.getMonth()+1; //January is 0!
	 var yyyy = d.getFullYear();
	 if(dd<10){dd='0'+dd} 
	 if(mm<10){mm='0'+mm} 
	 return dd+'/'+mm+'/'+yyyy;
    }

	function formattedDateWithDay() {
	 var theDateFormatted = weekday[theDate.getDay()] + ' '+ formattedDate(theDate);
	 return theDateFormatted;
	}

	function updateDate() {
     $("#day").text(weekday[theDate.getDay()]);
	 $("#date").text(formattedDate(theDate));
	}

	function nextDate() {
	 theDate.setDate(theDate.getDate() +1);
	 updateDate();
	}

	function previousDate() {
	 theDate.setDate(theDate.getDate() -1);
	 updateDate();
	}

    function orderedFormat(date) {
      return date.substring(6,10) + date.substring(3,5) + date.substring(0,2);
    }
    
    assert("20120825"==orderedFormat("25/08/2012"), "orderedFormat unit test 1");
    
    function getURLParameter(name) {
        return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
    }
    
    function guid() {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
      });
    }
    
    function formatTime(minutes) {
    	var h = Math.floor(minutes/60);
    	var m = minutes - h*60;
    	var hh;
    	if (h<10) 
    		hh="0"+ h;
    	else 
    		hh =h;
    	if (m<10)
    		mm = "0" + m;
    	else 
    		mm = m;
    	return hh + ":" + mm;
    }
    
    //unit test formatTime
    assert("11:20"==formatTime(680),"formatTime test 1");
    assert("00:01"==formatTime(1), "formatTime test 2");
    
    function formatDateForUrl(d) {
   	 var dd = d.getDate();
   	 var mm = d.getMonth()+1; //January is 0!
   	 var yyyy = d.getFullYear();
   	 if(dd<10){dd='0'+dd} 
   	 if(mm<10){mm='0'+mm} 
   	 return yyyy + "-" + mm + "-" + dd;
    }
    
    function assert(b,msg){
    	if (!b) alert(msg + " failed");
    }

    var offline = getURLParameter("offline") == "true";
    
    //load settings and create onchange functions
    settings.autoAdvanceTime = getSetting("autoAdvanceTime","15:00");
    $("#autoAdvanceTime").val(settings.autoAdvanceTime);
    $("#autoAdvanceTime").blur(function () {
    	setSetting("autoAdvanceTime",$("#autoAdvanceTime").val());
    	settings.autoAdvanceTime = $("#autoAdvanceTime").val();
    });

    settings.standardDay = getSetting("standardDay","08301230 13301700");
    $("#standardDay").val(settings.standardDay);
    $("#standardDay").blur(function () {
    	setSetting("standardDay",$("#standardDay").val());
    	settings.standardDay = $("#standardDay").val();
    });
    
    settings.numDaysToDisplay = parseInt(getSetting("numDaysToDisplay","100"));
    $("#numDaysToDisplay").val(settings.numDaysToDisplay);
    $("#numDaysToDisplay").blur(function () {
        setSetting("numDaysToDisplay",$("#numDaysToDisplay").val());
    	settings.numDaysToDisplay = parseInt($("#numDaysToDisplay").val());
    });

    settings.submittedBy = getSetting("submittedBy","");
    $("#submittedBy").val(settings.submittedBy);
    $("#submittedBy").blur(function () {
    	setSetting("submittedBy",$("#submittedBy").val());
    	settings.submittedBy = $("#submittedBy").val();
    });
    
    function isNumeric(n) {
   	  return !isNaN(parseFloat(n)) && isFinite(n);
   	}
   	
   	assert(isNumeric(10),"isNumeric test 1");
   	assert(isNumeric(10.1),"isNumeric test 2");
   	assert(!isNumeric("a"),"isNumeric test 3");
   	assert(!isNumeric(null),"isNumeric test 4");
    	
    var offlineTimes = new Object();
    offlineTimes.entries = 
			  [  
			    {"startTime" : "2013-05-17T09:00:00.000Z","durationMs" : "19200000"},
	            {"startTime" : "2013-05-28T08:50:00.000Z","durationMs" : "13200000"},
	            {"startTime" : "2013-05-28T13:10:00.000Z","durationMs" : "12300000"},
	            {"startTime" : "2013-05-29T08:50:00.000Z","durationMs" : "13200000"},
	            {"startTime" : "2013-05-29T13:00:00.000Z","durationMs" : "15600000"},
	            {"startTime" : "2013-05-30T08:55:00.000Z","durationMs" : "12900000"},	
	            {"startTime" : "2013-05-30T13:05:00.000Z","durationMs" : "15000000"},
	            {"startTime" : "2013-05-31T08:50:00.000Z","durationMs" : "13200000"},
	            {"startTime" : "2013-05-31T13:00:00.000Z","durationMs" : "16200000"}	
		       ];
    
    function hideAll() {
        $("#main").addClass("invisibleCompact");
        $("#reporting").addClass("invisibleCompact");
        $("#importing").addClass("invisibleCompact");
        $("#exporting").addClass("invisibleCompact");
        $("#settings").addClass("invisibleCompact");
        $("#refreshLink").removeClass("bold");
        $("#reportLink").removeClass("bold");
        $("#settingsLink").removeClass("bold");
    }
    
    function refresh() {
        $("#working").removeClass("invisible");
        hideAll();
        $("#main").removeClass("invisibleCompact");
        $("#refreshLink").addClass("bold");
		$("#times").empty();
		if (offline) {
        	setTimeout(function () {
	        	  loadTimes(offlineTimes);
				  submitTime("08301200");
				  submitTime("13001730");
				  submitTime("08001300");
				  submitTime("14001645");
				  sortRows();
	              $("#working").addClass("invisible");
		  	},1000);
		} else {
			$.ajax({
  		      type: "GET",
  		      url: "command",
  		      contentType: 'application/json',
  		      dataType: "json",
  		      data: "command=getTimes&n="+settings.numDaysToDisplay,
  		      success: function (response) {
  		    	loadTimes(response);
  		        console.log("loaded");
  		        sortRows();
                $("#working").addClass("invisible");
  		      },
  		      error: function (xhr, ajaxOptions, thrownError) {
  		        alert("could not load times due to " + xhr.status  + ","+ thrownError);
  		        $("#working").addClass("invisible");
  		      }
  		    });
		}
    }
    
    function loadTimes(times) {
    	for (i=0;i<times.entries.length;i++) {
  		  var entry = times.entries[i];
  		  var year = parseInt(entry.startTime.substring(0,4));
  		  var month = parseInt(entry.startTime.substring(5,7));
  		  var day = parseInt(entry.startTime.substring(8,10));
  		  var date = new Date(year,month-1,day,0,0,0);
  		  var hh1 = parseInt(entry.startTime.substring(11,13));
  		  var mm1 = parseInt(entry.startTime.substring(14,16));
  		  var durationMs = parseInt(entry.durationMs);
  		  var startMinutes = hh1*60 + mm1;
  		  var finishMinutes = startMinutes + durationMs/60000;
  		  var t1 = formatTime(startMinutes);
  		  var t2 = formatTime(finishMinutes);
  		  console.log("dt="+date + ",t1=" + t1 + ",t2="+ t2);
  		  var rowId = entry.id;
  		  addDate(date,t1,t2,rowId,true,"");
  		  rowReady(rowId);
  	  }
    }

    function twoDigits(n) {
    	if (n<10) return "0"+ n;
    	else return "" + n;
    }
    
    assert("01" == twoDigits(1),"twoDigits test 1");
    assert("23" == twoDigits(23),"twoDigits test 2");
    
    $("#refreshLink").click(refresh);
    
    function rowReady(rowId) {
    	$("#msg"+rowId).html("");
		$("#delete"+rowId).removeClass("invisible");
		$("#delete"+rowId).addClass("delete");
    }

	function submitTime(s) {
		var hh1 = s.substring(0,2);
		var mm1 = s.substring(2,4);
		var hh2 = s.substring(4,6);
		var mm2 = s.substring(6,8);
		var valid = s.length==8 && 
		        parseInt(hh1)>=0 && parseInt(hh1) <=23 && 
		        parseInt(mm1)>=0 && parseInt(mm1) <=59 && 
		        parseInt(hh2)>=0 && parseInt(hh2)<=23 &&
		        parseInt(mm2)>=0 && parseInt(mm2) <=59 && 
				parseInt(hh1)*60+parseInt(mm1) < parseInt(hh2)*60+parseInt(mm2); 
		
		var t1 = hh1 + ":" + mm1;
		var t2 = hh2 + ":" + mm2;
		var date =new Date(theDate.getTime());
		var rowId = guid();
		var durationMs = (parseInt(hh2)*60+parseInt(mm2)-(parseInt(hh1)*60+parseInt(mm1)))*60000;
		
		addDate(date,t1,t2,rowId,valid,"Saving...");

	   	sortRows();
	   	$("#time-range").val('');
	
	   	if (valid &&
	   			settings.autoAdvanceTime != null &&
	   			settings.autoAdvanceTime != "" &&
	   			(hh2+':'+mm2)>=settings.autoAdvanceTime) {
	        nextDate();
		 	while ($.inArray(theDate.getDay(),settings.workingDays)==-1)
	          nextDate();
	      }
	
	   	//do ajax save call
	    if (valid) {
	    	if (offline) {
		    	setTimeout(function() {
					rowReady(rowId);
		          	},1000);
	    	} else {
	    		var startTime = date.getFullYear() + 
	    					"-" + twoDigits(date.getMonth()+1) +
	    					"-" + twoDigits(date.getDate()) + 
	    					"-" + hh1 + 
	    					"-" + mm1
	    		console.log("saving startTime="+ startTime);	
	    		var parameters = "command=saveTime&start="+startTime + "&durationMs="+durationMs + "&id="+rowId;
	    		$.ajax({
	    		      type: "GET",
	    		      url: "command",
	    		      dataType: "html",
	    		      data: parameters,
	    		      success: function (response) {
	    		        console.log("saved");
	    		        rowReady(rowId);
	    		      },
	    		      error: function (xhr, ajaxOptions, thrownError) {
	    		        alert("could not save time due to " + xhr.status  + ","+ thrownError);
	    		      }
	    		    });
	    	}
	    }
	}

	function addDate(date,t1,t2,rowId,valid,defaultMsg) {
	  var msgCls = valid ? "busy" :"invalid";
      var msg = valid ? defaultMsg : "Invalid";
      var deleteClass = valid ? "invisible" :"delete";
 	   $('#times').append(
			'<div id="'+ rowId + '" class="row">'+
			'<div class="timesDay">' + weekday[date.getDay()] + '</div>'+
			'<div class="timesDate">'+ formattedDate(date) +'</div>'+ 
			'<div class="timesFrom">'+ t1 + '</div>'+
			'<div class="timesTo">'+ t2 + '</div>'+
			'<div class="timesDelete"><div id="delete'+rowId+'" class="'+deleteClass+'"><img src="image/delete.png"></div></div>'+
			'<div id="msg'+rowId+'" class="'+msgCls+' timesMsg">'+msg+'</div>'+
			'<br style="clear:both;"/>'+			
			'</div>'
			);
 	   
	   //define delete action
	   $("#delete"+rowId).click(function (){
		   var answer = confirm("Are you sure you want to delete this row?");
		   if (answer != true) return;
		   
           $("#msg"+rowId).html("Deleting...");
		   $("#delete"+rowId).removeClass("invisible");
		   
		   if (!valid) {
			 setTimeout(function () {$("#"+rowId).remove();},1000);
		   }
           else {
			 if (offline)
             	setTimeout(function () {$("#"+rowId).remove();},1000);
			 else {
				 $.ajax({
	    		      type: "GET",
	    		      url: "command",
	    		      dataType: "html",
	    		      data: "command=delete&id="+rowId,
	    		      success: function (response) {
	    		        console.log("deleted");
	    		        $("#"+rowId).remove();
	    		      },
	    		      error: function (xhr, ajaxOptions, thrownError) {
	    		        alert("could not save time due to " + xhr.status  + ","+ thrownError);
	    		      }
	    		    });
			 }
		   } 
       });

	}

    function sortRows() {
	   $('#times').find('.row').sortElements(function(a, b){

         return orderedFormat($(a).children('div')[1].textContent) + $(a).children('div')[2].textContent <
                orderedFormat($(b).children('div')[1].textContent) + $(b).children('div')[2].textContent      ? 1 : -1;
       });
	}

	updateDate();
	
	$("#time-range").keydown(function(event) {
	// Allow: backspace, delete, tab, escape, enter, F5
	if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || event.keyCode == 116 ||
		 // Allow: Ctrl+A
		(event.keyCode == 65 && event.ctrlKey === true) || 
		 // Allow: home, end, left, right
		(event.keyCode >= 35 && event.keyCode <= 40)) {
		     // let it happen, don't do anything
		     if (event.keyCode==38)
		         nextDate();
		     else if (event.keyCode==40)
				previousDate();
		     else if (event.keyCode == 13)
		        submitTime($("#time-range").val());
		     return;
	}
	else {
		// if s pressed then put in standard day
		if (event.keyCode == 83){
			event.preventDefault();
                        var items = settings.standardDay.split(" ");
			for (i=0;i<items.length;i++) {
				submitTime(items[i]);
			}
		}
		
		// Cancel the keypress if not a number 
		if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
		    event.preventDefault(); 
		}   
	}
	});


	$("#settingsLink")
      .click(function() {
    	hideAll();
    	$("#settingsLink").addClass("bold");
        $( "#settings" ).removeClass( "invisibleCompact" );
      });
	
	$("#loadLink").button()
	  .click(function(){
		 document.location.href='load'; 
	  });
	
	$("#reportLink")
    .click(function() {
		hideAll();
		$("#reportLink").addClass("bold");
    	$( "#reporting" ).removeClass("invisibleCompact");
    	//default from and to dates to the 1st to end of previous month
    	if ($("#from").val().length==0) {
    		var date = new Date();
    		date.setDate(1);
    		date.setMonth(date.getMonth()-1);
    		$("#from").val(formattedDate(date));
    	}
    	if ($("#to").val().length==0) {
    		var date = new Date();
    		date.setDate(0);
    		$("#to").val(formattedDate(date));
    	}
    });
	
	$("#from").datepicker({
	      changeMonth: true,
	      changeYear: true
	    });
    $("#from").datepicker("option","dateFormat","dd/mm/yy");
	$("#to").datepicker({
	      changeMonth: true,
	      changeYear: true
	    });
    $("#to").datepicker("option","dateFormat","dd/mm/yy");
    $("#showReport").button().click(function () {
    	$("#reportWorking").removeClass("invisible");
    	if (offline) { 
    		loadReport(offlineTimes);
    		$("#reportWorking").addClass("invisible");
    	}
    	else {
			var dateStart = $("#from").datepicker("getDate");
			var dateFinish = $("#to").datepicker("getDate");
			if (dateStart == null)
				dateStart = new Date(1000,1,1,1,1,1,1);
			if (dateFinish == null)
				dateFinish = new Date(3000,1,1,1,1,1,1)
			var startParam = formatDateForUrl(dateStart);
			var finishParam = formatDateForUrl(dateFinish);
			
	    	$.ajax({
			      type: "GET",
			      url: "command",
			      contentType: 'application/json',
			      dataType: "json",
			      data: "command=getTimeRange&start="+ startParam + "&finish="+ finishParam,
			      success: function (response) {
			    	loadReport(response);
			        console.log("loaded");
			        sortRows();
			        $("#reportWorking").addClass("invisible");
			      },
			      error: function (xhr, ajaxOptions, thrownError) {
			        alert("could not load times due to " + xhr.status  + ","+ thrownError);
			        $("#reportWorking").addClass("invisible");
			      }
			    });
    	}
    });
    
    function loadReport(times) {
   		$("#reportContent").empty().append("<h3>Timesheet</h3>");
   		
   		var buffer = "";
		var previousDate = null;    	
		var dailyMinutes = 0;
		var totalMinutes = 0;
    	for (i=0;i<times.entries.length;i++) {
  		  var entry = times.entries[i];
  		  var year = parseInt(entry.startTime.substring(0,4));
  		  var month = parseInt(entry.startTime.substring(5,7));
  		  var day = parseInt(entry.startTime.substring(8,10));
  		  var date = new Date(year,month-1,day,0,0,0);
  		  var hh1 = parseInt(entry.startTime.substring(11,13));
  		  var mm1 = parseInt(entry.startTime.substring(14,16));
  		  var durationMs = parseInt(entry.durationMs);
  		  var startMinutes = hh1*60 + mm1;
  		  var finishMinutes = startMinutes + durationMs/60000;
  		  totalMinutes+=finishMinutes - startMinutes;
  		  var t1 = formatTime(startMinutes);
  		  var t2 = formatTime(finishMinutes);
  		  var rowId = entry.id;
  		  var isNewDate = previousDate==null || date.getTime()!=previousDate.getTime(); 
		  if (isNewDate && previousDate !=null) {
 			  //add total to previous entry
 			  buffer += '<div style="float:left; width:6em;">' + formatTime(dailyMinutes) + '</div>';
 			  //add br
 			  buffer += '<br style="clear:both"/>';
 			  $("#reportContent").append(buffer);
 			  buffer = "";
 			  dailyMinutes = 0;
		  } else {
			  buffer +=  '<br style="clear:both"/>';
		  }
		  //add Day of week
		  var dayOfWeek;
		  if (isNewDate)
			  dayOfWeek = weekday[date.getDay()];
		  else 
			  dayOfWeek = "&nbsp;";
		  
		  var formattedDate;
		  if (isNewDate)
			  formattedDate = day + ' ' + months[month-1] + ' ' + year;
		  else 
			  formattedDate = "&nbsp;";
		  
		  //class=reportDayOfWeek
		  buffer += '<div class="reportDayOfWeek">'+dayOfWeek+'</div>';
		  //add date
		  buffer += '<div class="reportDate">'+ formattedDate + '</div>';
		  //add from time
		  buffer += '<div class="reportTimeFrom">'+ t1 + '</div>';
		  //add to time
		  buffer += '<div class="reportTimeTo">'+ t2 + '</div>';
		  dailyMinutes += durationMs/60000; 
  		  previousDate = date;
  	   }
       if (dailyMinutes >0) {
         //add total to previous entry
	     buffer += '<div style="float:left; width:6em;">' + formatTime(dailyMinutes) + '</div>';
       }
    	
       var decimalHours = (totalMinutes/60.0).toFixed(2);
	   buffer += '<p style="font-weight:bold;clear:both;margin-top:10px;">Total: '+ formatTime(totalMinutes) + '  ('+ decimalHours +' decimal)</p>';
	   buffer += '<p class="spaceBelow">Submitted by:</p>';
	   buffer += '<p class="spaceBelow">Signature:</p>';
	   buffer += '<p class="spaceBelow">Date:</p>';
	   buffer += '<p class="spaceBelow">Authorized by:</p>';
	   buffer += '<p class="spaceBelow">Signature:</p>';
	   buffer += '<p class="spaceBelow">Date:</p>';
	   $("#reportContent").append(buffer);
    }

    $("#entryHelp").click(function () {
    	$("#help").toggleClass("invisibleCompact");
    });
    
    $("#exportLink").button().click(function () {
    	window.location = "command?command=exportTimes";
    });
    
    $("#print").button().click(function() {
    	window.print();
    });
    
    function getSetting(key,defaultValue){
    	var result;
    	$.ajax({
            type: "GET",
            url:  "command",
            data: "command=getSetting&key="+ key,
            contentType: 'text/plain',
		    dataType: "html",
            async: false,
            success : function(data) {
                result = data;
            },
    		error: function (xhr, ajaxOptions, thrownError) {
		        alert("could not get setting " + key + " due to " + xhr.status  + ","+ thrownError);
		    }
        });
    	console.log("getSetting "+ key + "='" + result + "'");
    	if (offline || result == '')
    		return defaultValue;
    	else 
    		return result;
    }
    
    function setSetting(key,val){
    	$.ajax({
            type: "GET",
            url: "command",
            data: "command=setSetting&key="+ key + "&value=" + val,
            async: true,
            success : function(data) {
            },
    		error: function (xhr, ajaxOptions, thrownError) {
		        alert("could not set setting " + key + " due to " + xhr.status  + ","+ thrownError);
		    }
        });
    }
    
    refresh();
	$("#time-range").focus();
	$("#more").click(function () {
		settings.numDaysToDisplay = parseInt(settings.numDaysToDisplay) + 100;
		refresh();
	});
  });

  </script>
</head>
<body>

	<div class="ui-widget">

		<div id="banner" class="noprint"><img src="image/banner.jpg"/></div>
		<div id="nonBanner">
		<div class="links noprint">
			<div id="refreshLink" class="link bold">Time</div>
			<div id="reportLink" class="link">Report</div>
			<div id="settingsLink" class="link">Settings</div>
		</div>

		<div id="main">
			<img id="working" class="invisible" src="image/spinner.gif" /><br />
			<div id="day"></div>
			<label id="date" for="time-range"></label> <input id="time-range" />
			<div id="entryHelp"><img src="image/help.png"/></div> 
			<br style="clear:both"/>
			<div id="help" class="invisibleCompact">
			    <p>The expected format is:</p>
			    <p style="margin-left:2em;">HHMMHHMM</p>
			    <p>For example, the work period 13:30-17:30 is entered:</p>
			    <p style="margin-left:2em;">13301730</p>
			    <p>Hit Enter to submit a value</p>
			    <p>All times are in 24 hour clock.</p>
				<p>Up-arrow = next date, Down-arrow = previous date</p>
				<p>Type 's' to enter a standard day as defined in Settings</p>
			</div>
			<div id="times"></div>
			<div id="more">More</div>
		</div>

		<div id="reporting" class="invisibleCompact">
			<div class="noprint">
				<div style="float: left; width: 4em; margin-top: 3px;">From</div>
				<div style="float: left;">
					<input type="text" id="from" />
				</div>
				<br style="clear: both;" />
				<div style="float: left; width: 4em; margin-top: 3px;">To</div>
				<div style="float: left;">
					<input type="text" id="to" />
				</div>
				<br style="clear: both;" />
				<div id="showReport" style="margin-top: 10px; float: left;">Show
					report</div>
				<div id="print" style="margin-left:2em; margin-top: 10px; float: left;">Print</div>
				<div style="float: left;margin-left:1em;padding-top:15px;">
					<img id="reportWorking" class="invisible" src="image/spinner.gif" />
				</div>
				<br style="clear: both;" />
			</div>
			<div id="reportContent" style="margin-top: 20px;"></div>
		</div>

		<div id="settings" class="invisibleCompact">

			<p>
				Auto-advance to next day after time (HHMM):&nbsp;<input
					id="autoAdvanceTime" value="1500" />

			</p>
			<p class="help">If an auto-advance time is specified (in format
				HHMM) then the date will be auto-advanced to the next working day if
				the end time of a submission is greater than this time.</p>

			<p>Working days:</p>
			<p class="help">Used by auto-advance.</p>
			<input type="checkbox" id="sunday" value="true">Sunday<br>
			<input type="checkbox" id="monday" value="true">Monday<br>
			<input type="checkbox" id="tuesday" value="true" checked="checked">Tuesday<br>
			<input type="checkbox" id="wednesday" value="true" checked="checked">Wednesday<br>
			<input type="checkbox" id="thursday" value="true" checked="checked">Thursday<br>
			<input type="checkbox" id="friday" value="true" checked="checked">Friday<br>
			<input type="checkbox" id="saturday" value="true">Saturday<br>

			<p>
				Standard day (space delimited):&nbsp;<input id="standardDay"
					value="08301230 13001700" />
			</p>
			<p class="help">A standard day is input using the 's' character
				in the time field. To specify a standard day of 08:30 to 12:30 then
				back working between 13:00 and 17:30, enter '08301230 13001730' in
				this field.</p>
			<p>
				Number of days to display:&nbsp;<input id="numDaysToDisplay" value="100" />
			</p>
			<p class="help">The number of days back in time from now that
				will be displayed in the list of times on the entry view.</p>
			<p>
				Submitted by:&nbsp;<input id="submittedBy" value="David Moten" />
			<p class="help">This value will be placed in the 'Submitted by' section of the report.</p>
			
			<div id="loadLink">Import</div>
			<p class="help">Import tab delimited values in bulk.</p>
			<div id="exportLink">Export</div>
			<p class="help">Export all times from the database as tab delimited values.</p>
		</div>

	</div>
	</div>

</body>
</html>
