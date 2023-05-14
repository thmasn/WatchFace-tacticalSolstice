import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Timer;

class solsticeView extends WatchUi.WatchFace {
    private var _isAwake as Boolean?;
    
    private var animationTicks as Number = 0;
    private var animationTimer;
    private var center;
    private var doFullUpdate = false;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        //setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    	doFullUpdate = true;
    	_isAwake = true;
    	startTimer();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);   
             
    	if(dc has :setAntiAlias) {
        	dc.setAntiAlias(true);
    	}
    	updateWatchOverlay(dc);
    }
    //! Handle the partial update event
    //! @param dc Device Context
    /*public function onPartialUpdate(dc as Dc) as Void {
    	updateWatchOverlay(dc, false);
    }*/
    private function updateWatchOverlay(dc as Dc) as Void {
    	var primaryColor = 0xFFFFFF;
    	var secondaryColor = 0x2F73B5;
        center = dc.getWidth()/2;
        //TODO: find out why the partial update does not work when deployed. maybe we need to use an offsreenbuffer?
        doFullUpdate = true;
        if(doFullUpdate){
	        dc.setColor(Graphics.COLOR_TRANSPARENT, 0x000000);
	        dc.clear();
	        if(_isAwake){
    			drawMonth(dc, center, primaryColor, secondaryColor);
	        }
    		doFullUpdate = false;
        } else {
        	clearTime(dc, center, primaryColor, secondaryColor);
        }
    	drawTime( dc, center, primaryColor, secondaryColor);
    
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    	_isAwake = true;
    	doFullUpdate = true;
    	startTimer();
    }
    function startTimer() as Void{
    	animationTicks = 0;
	    animationTimer = new Timer.Timer();
	    animationTimer.start(method(:timerCallback), 50, true);
    }
    function timerCallback() {
	    animationTicks += 1;
	    self.requestUpdate();
	    if(animationTicks > 15){
	    	animationTimer.stop();
	    }
	}

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    	_isAwake = false;
    	doFullUpdate = true;
	    if(animationTimer != null){
	    	animationTimer.stop();
	    }
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
        	if(d < animationTicks*3-10){
	        	dc.fillCircle(center+offsetX + dayWidth * curDayOfWeek,
	        				  center+offsetY + dayHeight* curWeek,
	        				  2);
        	}
        	if(curDayOfWeek == 6){
        		curWeek++;
        	}
        	//System.println("drawing day"+d+"curDayOfWeek"+curDayOfWeek);
        }
        
        //Month indicator
	    var pwidth = clamp(animationTicks-10,0,2);
	    if(pwidth > 0){
	        dc.setPenWidth(pwidth);
	        var space = 4;
	        var monthWidth = 360/12;
	        for(var m = 0; m < 12; m++){
	        	
	        	if(m == month-1){
	        		dc.setPenWidth(pwidth+1);
		        	dc.setColor(primaryColor, 0x000000);
	        	
	        	} else {
	        		dc.setPenWidth(pwidth);
	        		dc.setColor(secondaryColor, 0x000000);
	        	}
		        dc.drawArc(center, center, 94, 1,
		        -(monthWidth*m+space)+90, 
		        -(monthWidth*(m+1)-space)+90
		        );
	        }
        }
        
    }
    function clearTime(dc as Dc, center, primaryColor, secondaryColor) as Void {
		//clear outside
        dc.setColor(0x000000, 0x000000);
        var pwidth = 45;
        dc.setPenWidth(pwidth);
        dc.drawArc(center, center, center-pwidth/2, 1, 0, 360);
    }
    function clamp(v,a,b){
    	if(v<a){
    		return a;
    	}else if(v>b){
    		return b;
    	}else{
    		return v;
    	}
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
        //blue bg arc
        if(_isAwake){
	        dc.setColor(secondaryColor, 0x000000);
	        pwidth = clamp(animationTicks,1,5);
	        dc.setPenWidth(pwidth);
	        dc.drawArc(center, center, center-pwidth/2, filldirection, 0, 360);
        }
        //white main arc
        var sleepHourWidth = 2;
        if(degrees != 90 or filldirection == 0){
	        dc.setColor(primaryColor, 0x000000);
	        pwidth = clamp(animationTicks+sleepHourWidth,1,15);
	        if(!_isAwake){
	        	pwidth = sleepHourWidth;
	        }
	        dc.setPenWidth(pwidth);
	        dc.drawArc(center, center, center-pwidth/2, filldirection, 90, degrees);
        }
        
        
	    //minute Arc
        if(_isAwake){
	        degrees = min*360/60;
	        degrees += clockTime.sec*360/60/60;
	        degrees = degreesRotateAndClamp(degrees);
	        
		    var minuteRadius = dc.getWidth()/2 -30;
	        
	        dc.setColor(secondaryColor, 0x000000);
	        pwidth = clamp(animationTicks-8,0,3);
	        if(pwidth > 0){
		        dc.setPenWidth(pwidth);
		        dc.drawArc(center, center, minuteRadius-pwidth/2, filldirection, 0, 360);
		        
		        filldirection = clockTime.hour%2 == 0;
		        if(degrees != 90 or filldirection == 0){
			        dc.setColor(primaryColor, 0x000000);
			        dc.drawArc(center, center, minuteRadius-pwidth/2, filldirection, 90, degrees);
		        }
	        }
        }
        
	    //draw marks
        if(_isAwake){
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
        /*
        dc.setColor(0xAAAAAA, 0x000000);
        outerRadius = center;
        innerRadius = 0;
        
    	var angle = animationTicks/90.0 *Math.PI * 2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
    	dc.drawLine(
    	center +innerRadius*sin, 
    	center +innerRadius*cos,
    	center +outerRadius*sin,
    	center +outerRadius*cos
    	);
		*/
	}

}
