<!doctype html>

<html lang="en">
<head>
<meta charset="utf-8" />
<title>Timesheet</title>
<link rel="stylesheet"
	href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
<script src="jquery.sortElements.js"></script>
<script src="jquery.printElement.js"></script>
<style media="screen" type="text/css">

body {
	font-family: "Trebuchet MS", "Helvetica", "Arial", "Verdana",
		"sans-serif";
	font-size: 80%;
	margin-left: 5%;
	margin-top: 2%;
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

#time-range {
	width: 7em;
	margin-bottom: 10px;
}

#standardDay {
	width: 20em;
}

.help {
	font-size: 62.5%;
	margin-left: 2em;
}

#autoAdvanceTime {
	width: 4em;
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
    settings.moveToNextWorkingDayAfterTime="15:00"
    settings.workingDays=[2,3,4,5];
    settings.standardDay=["08301230","13001700"];

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
      return date.substring(6,8) + date.substring(3,5) + date.substring(0,2);
    }
    
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
    
    function refresh() {
        $("#working").toggleClass("invisible");
		$("#times").empty();
		if (offline) {
        	setTimeout(function () {
	        	  loadTimes(offlineTimes);
				  submitTime("08301200");
				  submitTime("13001730");
				  submitTime("08001300");
				  submitTime("14001645");
				  sortRows();
	              $("#working").toggleClass("invisible");
		  	},1000);
		} else {
			$.ajax({
  		      type: "GET",
  		      url: "command",
  		      contentType: 'application/json',
  		      dataType: "json",
  		      data: "command=getTimes&n=100",
  		      success: function (response) {
  		    	loadTimes(response);
  		        console.log("loaded");
  		        sortRows();
                $("#working").toggleClass("invisible");
  		      },
  		      error: function (xhr, ajaxOptions, thrownError) {
  		        alert("could not load times due to " + xhr.status  + ","+ thrownError);
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
    
    $("#refresh").click(refresh);
    
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
		var date = theDate;
		var rowId = guid();
		var durationMs = (parseInt(hh2)*60+parseInt(mm2)-(parseInt(hh1)*60+parseInt(mm1)))*60000;
		
		addDate(date,t1,t2,rowId,valid,"Saving...");

	   	sortRows();
	   	$("#time-range").val('');
	
	   	if (valid && (hh2+':'+mm2)>=settings.moveToNextWorkingDayAfterTime) {
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
	    					"-" + twoDigits(date.getDay()) + 
	    					"-" + hh1 + 
	    					"-" + mm1
	    					
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
			'<div class="timesDelete"><div id="delete'+rowId+'" class="'+deleteClass+'">Delete</div></div>'+
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
			for (i=0;i<settings.standardDay.length;i++) {
				submitTime(settings.standardDay[i]);
			}
		}
		
		// Cancel the keypress if not a number 
		if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
		    event.preventDefault(); 
		}   
	}
	});

	$( "#settings-dialog" ).dialog({
      autoOpen: false,
      height: $(window).height()-50,
      width: "80%",
      modal: true,
      buttons: {
        "Ok": function() {
            $( this ).dialog( "close" );
        },
        Cancel: function() {
          $( this ).dialog( "close" );
        }
      },
      close: function() {
      }
    });

	$("#settings")
      .click(function() {
        $( "#settings-dialog" ).dialog( "open" );
      });
	
	$("#load")
	  .click(function(){
		 document.location.href='load'; 
	  });
	
	$("#report")
    .click(function() {
      $( "#report-dialog" ).dialog( "open" );
    });
	
	$("#from").datepicker();
    $("#from").datepicker("option","dateFormat","dd/mm/yy");
	$("#to").datepicker();
    $("#to").datepicker("option","dateFormat","dd/mm/yy");
    $("#showReport").button().click(function () {

    	if (offline) 
    		loadReport(offlineTimes);
    	else {
			var dateStart = $("#from").datepicker("getDate");
			var dateFinish = $("#to").datepicker("getDate");
			
	    	$.ajax({
			      type: "GET",
			      url: "command",
			      contentType: 'application/json',
			      dataType: "json",
			      data: "command=getTimeRange&start=2013-04-01&finish=2013-05-31",
			      success: function (response) {
			    	loadReport(response);
			        console.log("loaded");
			        sortRows();
	              $("#working").toggleClass("invisible");
			      },
			      error: function (xhr, ajaxOptions, thrownError) {
			        alert("could not load times due to " + xhr.status  + ","+ thrownError);
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
			  dayOfWeek = weekday[theDate.getDay()];
		  else 
			  dayOfWeek = "&nbsp;";
		  
		  var formattedDate;
		  if (isNewDate)
			  formattedDate = day + ' ' + months[month-1] + ' ' + year;
		  else 
			  formattedDate = "&nbsp;";
		  
		  //class=reportDayOfWeek
		  buffer += '<div style="float:left;width:12em;">'+dayOfWeek+'</div>';
		  //add date, class=reportDate
		  buffer += '<div style="float:left;width:8em;">'+ formattedDate + '</div>';
		  //add from time, class="reportTimeFrom"
		  buffer += '<div style="float:left;width:6em;">'+ t1 + '</div>';
		  //add to time, class=reportTimeTo
		  buffer += '<div style="float:left;width:6em;">'+ t2 + '</div>';
		  dailyMinutes += durationMs/60000; 
  		  previousDate = date;
  	   }
       if (dailyMinutes >0) {
         //add total to previous entry
	     buffer += '<div style="float:left; width:6em;">' + formatTime(dailyMinutes) + '</div>';
       }
    	
	   buffer += '<p style="font-weight:bold;clear:both;margin-top:10px;">Total: '+ formatTime(totalMinutes) + '</p>';
	   buffer += '<p style="margin-bottom:3.5em;">Submitted by</p>';
	   buffer += '<p style="margin-bottom:3.5em;">Signature</p>';
	   buffer += '<p style="margin-bottom:3.5em;">Date</p>';
	   buffer += '<p style="margin-bottom:3.5em;">Authorized by</p>';
	   buffer += '<p style="margin-bottom:3.5em;">Signature</p>';
	   buffer += '<p style="margin-bottom:3.5em;">Date</p>';
	   $("#reportContent").append(buffer);
    }
    
    $( "#report-dialog" ).dialog({
        autoOpen: false,
        height: $(window).height()-50,
        width: "80%",
        modal: true,
        buttons: {
          "Print": function() {
			  $('#reportContent').printElement();        	  
              $( this ).dialog( "close" );
          },
          Cancel: function() {
            $( this ).dialog( "close" );
          }
        },
        close: function() {
        }
      });

    refresh();
	$("#time-range").focus();
  });

  </script>
</head>
<body>

	<div class="ui-widget">

		<div id="report-dialog">
			<div>
				<div style="float:left;width:4em;margin-top:3px;">From</div><div style="float:left"><input type="text" id="from" /></div>
				<br style="clear:both"/>
				<div style="float:left;width:4em;margin-top:3px;">To</div><div style="float:left"><input type="text" id="to" /></div>
				<br style="clear:both"/>
				<div id="showReport" style="margin-top:10px;">Show report</div>
				<div id="reportContent" style="margin-top:20px;" class="print" >
				</div>
			</div>
		</div>

		<div id="settings-dialog">

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
			<input type="checkbox" id="tuesday" value="true" checked="true">Tuesday<br>
			<input type="checkbox" id="wednesday" value="true" checked="true">Wednesday<br>
			<input type="checkbox" id="thursday" value="true" checked="true">Thursday<br>
			<input type="checkbox" id="friday" value="true" checked="true">Friday<br>
			<input type="checkbox" id="saturday" value="true">Saturday<br>

			<p>
				Standard day (space delimited):&nbsp;<input id="standardDay"
					value="08301230 13001700" />
			</p>
			<p class="help">A standard day is input using the 's' character
				in the time field. To specify a standard day of 08:30 to 12:30 then
				back working between 13:00 and 17:30, enter '08301230 13001730' in
				this field.</p>

		</div>

		<div class="links">
			<div id="refresh" class="link">Refresh</div>
			<div id="report" class="link">Report</div>
			<div id="load" class="link">Load</div>
			<div id="settings" class="link">Settings</div>
		</div>

		<div id="main">
			<img id="working" class="invisible" src="image/spinner.gif" /><br />
			<div id="day"></div>
			<label id="date" for="time-range"></label> <input id="time-range" />
			<div id="times"></div>
			<div id="more">More</div>
		</div>

	</div>


</body>
</html>
