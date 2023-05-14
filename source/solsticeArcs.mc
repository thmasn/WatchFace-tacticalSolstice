import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;
//moved to solsticeView.mc
class ArcLayer extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "ArcLayer"
        };

        Drawable.initialize(dictionary);
    }
    
    function degreesRotateAndClamp(degree){
        degree = 360-degree;
        degree += 90;
        if(degree > 260){
        	degree -= 360;
        }
        if(0 > degree){
        	degree += 360;
        }
    	return degree;
    }
    function drawMonth(dc as Dc, center, primaryColor, secondaryColor) as Void {
        //draw calendar month
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekDay = date.day_of_week-2;
        if(0 > weekDay){
        	weekDay += 7;
        }
        // range 0-6
        //System.println("weekDay"+weekDay);
        
        var month = date.month;
        var monthDuration = [31,29,31,30,31,30,31,31,30,31,30,31];
        var currMonthDuration = monthDuration[month-1];
        //range 1-31
        var day = date.day;
        //System.println("day"+day);
        //range 0-6
        var firstDayOfWeekInMonth = (weekDay - (day-1)+35)%7;
        //System.println("firstDayOfWeekInMonth"+firstDayOfWeekInMonth);
        
        var dayWidth= 14;
        var dayHeight = 14;
        var offsetX = -dayWidth*3;
        var offsetY = -dayHeight*2;
        
        var curWeek = 0;
        for(var d = 1; d <= currMonthDuration; d++){
        	var curDayOfWeek = (firstDayOfWeekInMonth+d-1) % 7;
        	if(d == day){
	        	dc.setColor(primaryColor, 0x000000);
        	
        	} else {
        		dc.setColor(secondaryColor, 0x000000);
        	}
        	dc.fillCircle(center+offsetX + dayWidth * curDayOfWeek,
        				  center+offsetY + dayHeight* curWeek,
        				  2);
        	if(curDayOfWeek == 6){
        		curWeek++;
        	}
        	//System.println("drawing day"+d+"curDayOfWeek"+curDayOfWeek);
        }
        
        //Month indicator
        dc.setPenWidth(3);
        var space = 4;
        var monthWidth = 360/12;
        for(var m = 0; m < 12; m++){
        	
        	if(m == month-1){
	        	dc.setColor(primaryColor, 0x000000);
        	
        	} else {
        		dc.setColor(secondaryColor, 0x000000);
        	}
	        dc.drawArc(center, center, 94, 1,
	        -(monthWidth*m+space)+90, 
	        -(monthWidth*(m+1)-space)+90
	        );
        
        }
    }
    function clearTime(dc as Dc, center, primaryColor, secondaryColor) as Void {
		//clear outside
        dc.setColor(0x000000, 0x000000);
        var pwidth = 45;
        dc.setPenWidth(pwidth);
        dc.drawArc(center, center, center-pwidth/2, 1, 0, 360);
    }
    function drawTime(dc as Dc, center, primaryColor, secondaryColor) as Void {
		
        var pwidth = 1;
        
    	var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var min = clockTime.min;
    	
    	var filldirection = 1;
        if (hours >= 12) {
            filldirection = 0;
        }
        if (hours > 12) {
            hours = hours - 12;
        }
        
        var degrees = 360*hours/12;
        degrees += min*360/60/12;
        degrees = degreesRotateAndClamp(degrees);
    
        // Set the background color then call to clear the screen
        
        //Hour Arc
        dc.setColor(secondaryColor, 0x000000);
        pwidth = 6;
        dc.setPenWidth(pwidth);
        dc.drawArc(center, center, center-pwidth/2, filldirection, 0, 360);
        
        if(degrees != 90 or filldirection == 0){
	        dc.setColor(primaryColor, 0x000000);
	        pwidth = 16;
	        dc.setPenWidth(pwidth);
	        dc.drawArc(center, center, center-pwidth/2, filldirection, 90, degrees);
        }
        
        
        //minute Arc
        degrees = min*360/60;
        degrees += clockTime.sec*360/60/60;
        degrees = degreesRotateAndClamp(degrees);
        
	    var minuteRadius = dc.getWidth()/2 -30;
        
        dc.setColor(secondaryColor, 0x000000);
        pwidth = 3;
        dc.setPenWidth(pwidth);
        dc.drawArc(center, center, minuteRadius-pwidth/2, filldirection, 0, 360);
        
        filldirection = clockTime.hour%2 == 0;
        if(degrees != 90 or filldirection == 0){
	        dc.setColor(primaryColor, 0x000000);
	        pwidth = 3;
	        dc.setPenWidth(pwidth);
	        dc.drawArc(center, center, minuteRadius-pwidth/2, filldirection, 90, degrees);
        }
        
        //draw marks
	    dc.setPenWidth(5);
        dc.setColor(0x000000, 0x000000);
        var outerRadius = center;
        var innerRadius = center-2;
        for(var i = 0; i < 12; i++){
        	var angle = i/12.0 *Math.PI * 2;
	        var cos = Math.cos(angle);
	        var sin = Math.sin(angle);
        	dc.drawLine(
        	center +innerRadius*sin, 
        	center +innerRadius*cos,
        	center +outerRadius*sin,
        	center +outerRadius*cos
        	);
        }
	
	}
    function draw(dc as Dc) as Void {
        //dc.setColor(Graphics.COLOR_TRANSPARENT, 0x000000);
        //dc.clear();
    	
    	var primaryColor = 0xFFFFFF;
    	var secondaryColor = 0x2F73B5;
        var center = dc.getWidth()/2;
        
    	if(dc has :setAntiAlias) {
        	dc.setAntiAlias(true);
    	}
    
    	drawMonth(dc, center, primaryColor, secondaryColor);
    	//clearTime(dc, center, primaryColor, secondaryColor);
    	drawTime( dc, center, primaryColor, secondaryColor);
    
    }

}
