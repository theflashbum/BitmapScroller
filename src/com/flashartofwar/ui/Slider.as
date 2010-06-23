package com.flashartofwar.ui
{
    import com.flashartofwar.behaviors.ISlider;
    import com.flashartofwar.behaviors.SliderBehavior;

    import flash.display.Sprite;
    import flash.events.Event;

    public class Slider extends Sprite implements ISlider
    {

        private var behavior:SliderBehavior;
        private var track:Sprite;
        private var dragger:Sprite;

        public function Slider()
        {
            init();
        }

        override public function set width(value:Number):void
        {
            track.width = Math.round(value);
            if (behavior) behavior.refresh();
        }

        override public function set height(value:Number):void
        {
            track.height = Math.round(value);
            if (behavior) behavior.refresh();
        }

        public function get value():Number
        {
            return behavior.value;
        }

        public function set value(value:Number):void
        {
            behavior.value = value;
        }

        private function init():void
        {
            track = addChild(createTrack()) as Sprite;
            dragger = addChild(createDragger()) as Sprite;

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
        }

        private function onAddedToStage(event:Event):void
        {
            behavior = new SliderBehavior(this);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage)
        }

        private function onRemovedFromStage(event:Event):void
        {

        }

        private function createDragger():Sprite
        {
            var sprite:Sprite = new Sprite();
            sprite.name = SliderBehavior.DRAGGER;
            sprite.graphics.beginFill(0xffffff);
            sprite.graphics.drawRoundRect(0, 0, 40, 10, 5);
            sprite.graphics.endFill();
            sprite.buttonMode = true;
            sprite.useHandCursor = true;
            return sprite;
        }

        private function createTrack():Sprite
        {
            var sprite:Sprite = new Sprite();
            sprite.name = SliderBehavior.TRACK;
            sprite.graphics.beginFill(0x000000, .4);
            sprite.graphics.drawRect(0, 0, 100, 10);
            sprite.graphics.endFill();

            return sprite;
        }


    }
}

