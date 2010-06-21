package com.flashartofwar.behaviors {
    import flash.events.EventDispatcher;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class EaseScrollBehavior extends EventDispatcher {

    private var _targetX:Number;
    private var target:Object;
    private var time:int;
    private var defaultDuration:int = 500;
    private var duration:int;
        
    public function EaseScrollBehavior(target:Object, targetX:Number = 0) {

        if (!target.hasOwnProperty("scrollX")) {
            throw new Error("Supplied target does not have a scrollX property.");
        }
        else
        {
            this.target = target;
            _targetX = targetX;
        }

    }

    public function set targetX(value:Number):void
    {
        if(_targetX == value)
        {
            return;
        }
        else
        {
            if((target.scrollX == _targetX))
            {
                time = getTimer();
            }
            else
            {
                duration += defaultDuration;
            }
            _targetX = value;
        }
    }

    public function calculateScrollX():void
    {

        if ((target.scrollX == _targetX))
        {
            duration = defaultDuration;
            return;
        }
        else
        {
            var interval:int = getTimer() - time;
            //t: current time, b: beginning value, c: change in position, d: duration
            var c:Number = _targetX - target.scrollX;
            var t:Number = interval;
            var d:Number = duration;
            var b:Number = target.scrollX;
            target.scrollX = quadEaseInOut(t, b, c, d);
        }


    }

    /**
     * t: current time, b: beginning value, c: change in position, d: duration
     * @param t - current time
     * @param b - beginning value
     * @param c - change in position
     * @param d - duration
     * @return
     *
     */
    public static function quadEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
    {
        if ((t /= d / 2) < 1) return c / 2 * t * t + b;
        return -c / 2 * ((--t) * (t - 2) - 1) + b;
    }

    public static function easeNone (t:Number, b:Number, c:Number, d:Number):Number {
		return c*t/d + b;
	}
}
}