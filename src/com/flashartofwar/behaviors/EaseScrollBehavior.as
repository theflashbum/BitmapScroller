package com.flashartofwar.behaviors {
    import flash.events.EventDispatcher;
    import flash.utils.Timer;

    public class EaseScrollBehavior extends EventDispatcher {

    private var _targetX:Number;
    private var timer:Timer;
    private var target:Object;
    private var time:Number;
    private var easeFunction:Function;

    public function EaseScrollBehavior(target:Object, targetX:Number = 0) {

        if (!target.hasOwnProperty("scrollX")) {
            throw new Error("Supplied target does not have a scrollX property.");
        }
        else
        {
            this.target = target;
            _targetX = targetX;
            this.time = time;
        }

    }

    public function set targetX(value:Number):void
    {
        _targetX = value;
    }

    public function calculateScrollX():void
    {
        if ((target.x != _targetX))
        {
            //t: current time, b: beginning value, c: change in position, d: duration
            var c:Number = _targetX - target.scrollX;
            var t:Number = .25;
            var d:Number = .8;
            var b:Number = target.scrollX;
            target.scrollX = Math.round(quadEaseInOut(t, b, c, d));

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


}
}