class PowerdashboardforStrydApp extends Toybox.Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new DatarunView() ];
    }
}


class DatarunView extends Toybox.WatchUi.DataField {
	using Toybox.WatchUi as Ui;

    hidden var mTimerRunning                = false;
    hidden var mStartStopPushed             = 0;    //! Timer value when the start/stop button was last pushed

    hidden var mLaps                        = 1;
    hidden var mLastLapPowerMarker           = 0;
    hidden var mLastLapTimeMarker           = 0;
    hidden var mLastLapStoppedTimeMarker    = 0;
    hidden var mLastLapStoppedPowerMarker    = 0;

    hidden var mLastLapTimerTime            = 0;
    hidden var mCurrentPower    			= 0; 
    hidden var mElapsedPower    			= 0;
    hidden var mLastLapElapsedPower			= 0;
    hidden var mPowerTime					= 0;

    function initialize() {
    	System.println(mLaps);
    }


    //! Calculations we need to do every second even when the data field is not visible
    function compute(info) {
        if (mTimerRunning) {  //! We only do some calculations if the timer is running
            mCurrentPower    = (info.currentPower != null) ? info.currentPower : 0;
            mPowerTime		 = (info.currentPower != null) ? mPowerTime+1 : mPowerTime;
            mElapsedPower    = mElapsedPower + mCurrentPower;  
            var mLapElapsedPower = mElapsedPower - mLastLapPowerMarker;
        }
    }

    //! Store last lap quantities and set lap markers
    function onTimerLap() {
        var info = Activity.getActivityInfo();

        mLastLapTimerTime        = mPowerTime - mLastLapTimeMarker;
        mLastLapElapsedPower  = (info.currentPower != null) ? mElapsedPower - mLastLapPowerMarker : 0;


        mLaps++;
        mLastLapPowerMarker           = mElapsedPower;
        mLastLapTimeMarker           = mPowerTime;
    }
    
    //! Timer transitions from stopped to running state
    function onTimerStart() {
        startStopPushed();
        mTimerRunning = true;
    }


    //! Timer transitions from running to stopped state
    function onTimerStop() {
        startStopPushed();
        mTimerRunning = false;
    }


    //! Timer transitions from paused to running state (i.e. resume from Auto Pause is triggered)
    function onTimerResume() {
        mTimerRunning = true;
    }


    //! Timer transitions from running to paused state (i.e. Auto Pause is triggered)
    function onTimerPause() {
        mTimerRunning = false;
    }


    //! Start/stop button was pushed - emulated via timer start/stop
    function startStopPushed() {
        var info = Activity.getActivityInfo();
        mStartStopPushed = info.elapsedTime;
      }


    //! Current activity is ended
    function onTimerReset() {
        mPrevElapsedPower	        = 0;
        mLaps                       = 1;
        mLastLapPowerMarker          = 0;
        mLastLapTimeMarker          = 0;
        mLastLapTimerTime           = 0;
        mLastLapElapsedPower     = 0;
        mStartStopPushed            = 0;
    }


    //! Do necessary calculations and draw fields.
    //! This will be called once a second when the data field is visible.
    function onUpdate(dc) {
        var info = Activity.getActivityInfo();
        var mColour;
	   var Garminfont2 = Ui.loadResource(Rez.Fonts.Garmin2);
	   var Garminfont3 = Ui.loadResource(Rez.Fonts.Garmin3);

        //! Calculate lap power
        var mLapElapsedPower = 0;
        if (info.currentPower != null) {
            mLapElapsedPower = mElapsedPower - mLastLapPowerMarker;
        }

        //! Calculate lap time and convert timers from milliseconds to seconds
        var mTimerTime      = 0;
        var mLapTimerTime   = 0;

        if (info.timerTime != null) {
            mTimerTime = mPowerTime;
            mLapTimerTime = mPowerTime - mLastLapTimeMarker;
        }
        
        //! Draw colour indicators
        mColour = Graphics.COLOR_LT_GRAY; 
        dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(108, 0, 106, 40);
        dc.fillRectangle(0, 0, 106, 40);
        dc.fillRectangle(108, 140, 106, 40);        
        dc.fillRectangle(0, 140, 106, 40);

//! Draw separator lines
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0,   90,  215, 90);
        dc.drawLine(107, 0,  107, 180);
        
        //! Set text colour
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        //!
        //! Draw field values
        //! =================
        //!

        mColour = Graphics.COLOR_BLACK;
		dc.setColor(mColour, Graphics.COLOR_TRANSPARENT);



		var xul = 55;
		var yul = 60;
		var xtul = 65;
		var ytul = 22;
		
		var xur = 160;
		var yur = 60;
		var xtur = 155;
		var ytur = 22;
		
		var xbl = 55;
		var ybl = 113;
		var xtbl = 65;
		var ytbl = 152;
		
		var xbr = 160;
		var ybr = 113;
		var xtbr = 155;
		var ytbr = 152;

		var zero = 0;
		
        //! Top row left: Power
        dc.drawText(xul, yul, Garminfont2, mCurrentPower, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(xtul, ytul, Garminfont3,  "Power", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        //! Top row right: Lap power
        dc.drawText(xur, yur, Garminfont2, (mLapTimerTime != 0) ? Math.round(mLapElapsedPower/mLapTimerTime) : zero.format("%d"), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(xtur, ytur, Garminfont3,  "Lap P", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        //! Bottom left: Average power
        dc.drawText(xbl, ybl, Garminfont2, (mPowerTime != 0) ? Math.round(mElapsedPower/mPowerTime) : zero.format("%d"), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(xtbl, ytbl, Garminfont3,  "Average", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        //! Bottom right: Last lap power
        dc.drawText(xbr, ybr, Garminfont2, (mLastLapTimerTime != 0) ? Math.round(mLastLapElapsedPower/mLastLapTimerTime) : zero.format("%d"), Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(xtbr, ytbr, Garminfont3, "L-1 P", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

	}
}
