$.noConflict();
jQuery( document ).ready(function( $ ) {
    var idealHours = [];
	var xy;
	
	var showDot = false;
	
	var projectHours = 400 + Math.round(Math.random()*600);
	
	projectHours = 400;
	
	var resources = 2;
	var weeklyHours=40;
	
	
	var hoursRemaining=projectHours;
	for(var i=0, len=projectHours;(i<=len && hoursRemaining>0);i++)
	{
		hoursRemaining = len-(i*weeklyHours);
		if(hoursRemaining<0)
		{
			hoursRemaining = 0;
		}
		idealHours.push([i*weeklyHours,hoursRemaining]);		
	}
	
	
	var actualHours = [[0,projectHours]];
	//actualHours = [];
	var lastTotal = projectHours;
	var workCompleted = 0;
	var i=1;
	var estimatedHours=0;
	var pct;
	
	//lastTotal = 25
	
	while(lastTotal>0)
	{
		workCompleted = ((weeklyHours) + Math.round(Math.random()*5));
		
		pct=Math.round(Math.random()*10);
		
		switch(pct)
		{
			//Total Failure
			case 0:
				workCompleted = Math.round(weeklyHours*.66);
				break;
			case 1:
				workCompleted = Math.round(weeklyHours*.75);
				break;	
			case 2:
				workCompleted = Math.round(weeklyHours*.85);
				break;					
			case 3:
				workCompleted = Math.round(weeklyHours*.90);
				break;	
			case 4:
				workCompleted = Math.round(weeklyHours*.95);
				break;	
			case 8:
				workCompleted = Math.round(weeklyHours*1.05);
				break;	
			case 9:
				workCompleted = Math.round(weeklyHours*1.1);
				break;	
			case 10:
				workCompleted = Math.round(weeklyHours*1.2);
				break;	
			default:
				workCompleted = weeklyHours
		}
		
		lastTotal = lastTotal - workCompleted;
		if(lastTotal<0)
		{
			lastTotal=0;
		}
		
		estimatedHours+=weeklyHours;
		
		if(workCompleted>weeklyHours)
		{
			actualHours.push([estimatedHours, lastTotal, {tooltip: lastTotal + "(" + (workCompleted-weeklyHours) + "h OT)", show_dot:showDot}]);
		}
		else if(workCompleted<weeklyHours)
		{
			actualHours.push([estimatedHours, lastTotal, {tooltip: lastTotal + "(" + (weeklyHours-workCompleted) + "h UT)", show_dot:showDot}]);
		}
		else
		{
		actualHours.push([estimatedHours, lastTotal]);
		}
		i++;
	}
	
	estimatedHours+=weeklyHours;
	
	//actualHours.push([estimatedHours, 1, {no_dot:true}]);
	
	//actualHours.splice(actualHours.length-3,3);
	
	/*if(actualHours.length<idealHours.length)
	{
		estimatedHours = actualHours[actualHours.length-1][0];
		for(var i=actualHours.length, len=idealHours.length;i<len;i++)
		{
			estimatedHours+=weeklyHours;
			actualHours.push([estimatedHours,0,{no_dot:true}]);
		}
	}*/
	
	if(idealHours.length<=actualHours.length)
	{
		estimatedHours = idealHours[idealHours.length-1][0];
		for(var i=idealHours.length, len=actualHours.length;i<len;i++)
		{
			estimatedHours+=weeklyHours;
			idealHours.push([estimatedHours,0,{no_dot:true}]);
		}
	}
	
	
	
	/*for(var i=0, len=idealHours.length;i<len;i++)
	{
		idealHours[0] = idealHours[0]*weeklyHours;
	}
	for(var i=0, len=actualHours.length;i<len;i++)
	{
		actualHours[0] = actualHours[0]*weeklyHours;
	}
	*/
    /*[new Date("2012-09-01T01:00:00+01:00"), 1486],
    [new Date("2012-10-01T01:00:00+01:00"), 952],
    [new Date("2012-11-01T00:00:00+00:00"), 2461],
    [new Date("2012-12-01T00:00:00+00:00"), 631],
    [new Date("2013-01-01T00:00:00+00:00"), 3644],
    [new Date("2013-02-01T00:00:00+00:00"), 0],
    [new Date("2013-03-01T00:00:00+00:00"), 0],
    [new Date("2013-04-01T01:00:00+01:00"), 0],
    [new Date("2013-05-01T01:00:00+01:00"), 0],
    [new Date("2013-06-01T01:00:00+01:00"), 0],
    [new Date("2013-07-01T01:00:00+01:00"), 0],
    ]*/
	
	
	
	
    var chart1 = new Charts.LineChart('chart1', {
      show_grid: true,
      show_y_labels: true,
      show_x_labels:true,
      label_max: false,
      label_min: false,
      multi_axis: false,
      //max_y_labels: 10,
      //max_x_labels: 10,
      x_padding: 40,
      y_padding:30,
      //x_label_size: 13,
	  //x_axis_scale:[0,projectHours+weeklyHours],
      //y_axis_scale: [0, projectHours+weeklyHours]
    });
	
	var actualLine = {
      data: actualHours,
      options: {
        line_color: "red",
        dot_color: "red",
        dot_stroke_size: 1,
        dot_stroke_color: "#16728c",
        area_opacity: 0.0,
        dot_size: 5,
        line_width: 1,
        smoothing: 0,
		hover_enabled: 0
      }
    };
	var idealLine = {
      data: idealHours,
      options: {
        line_color: "#16728c",
        dot_color: "#16a2cb",
        dot_stroke_size: 1,
        dot_stroke_color: "#16728c",
        area_opacity: 0.0,
        dot_size: 5,
        line_width: 1,
        smoothing: 0,
		
      }
    }
	
	chart1.add_line(idealLine);
	chart1.add_line(actualLine);
	
    chart1.draw();

	var txt = [];   
	var attr = {font: "18px Helvetica", opacity: 1};	
    
	txt[0] = chart1.r.text(chart1.width/2, 10, "Burndown Chart - Sprint 1").attr(attr).attr({fill: "#000000"});
	
	attr = {font: "16px Helvetica", opacity: 1};
	txt[1] = chart1.r.text(chart1.width/2, chart1.height+10, "Scheduled Hours").attr(attr).attr({fill: "#000000"});
	txt[2] = chart1.r.text(20, chart1.height/2, "Estimated Hours").attr(attr).attr({fill: "#000000"}).transform("r90");
	
	chart1.r.setSize(chart1.width, chart1.height+40);
	$("#chart1").height(chart1.height+30);
	
	var elements = $(chart1.r.canvas).children();
	var el;
	for(var i=0, len=elements.length;i<len;i++)
	{
		if(typeof elements[i].raphaelid == "undefined")
			continue;
		
		el = chart1.r.getById(elements[i].raphaelid);
		el.transform(el.attr("transform") + ",t15,10");
	}
	
	txt[0].transform(txt[0].attr("transform") + ",t-15,-5");
	txt[1].transform(txt[1].attr("transform") + ",t-15,0");
    
});
