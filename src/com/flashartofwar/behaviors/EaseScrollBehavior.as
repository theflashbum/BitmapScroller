package com.flashartofwar.behaviors
{
    import flash.events.EventDispatcher;

    public class EaseScrollBehavior extends EventDispatcher
    {

        public var targetX:Number;
        private var target:Object;

        public function EaseScrollBehavior(target:Object, targetX:Number = 0)
        {

            if (!target.hasOwnProperty("scrollX"))
            {
                throw new Error("Supplied target does not have a scrollX property.");
            }
            else
            {
                this.target = target;
                targetX = targetX;
            }

        }

        public function update():void
        {

            if ((target.scrollX == targetX))
            {
                return;
            }
            else
            {
                var c:Number = targetX - target.scrollX;
                var b:Number = target.scrollX;
                target.scrollX = c * 25.0 / 256.0 + b;

                if (c < .01 && c > -.01)
                {
                    target.scrollX = targetX;
                }
            }


        }
    }
}