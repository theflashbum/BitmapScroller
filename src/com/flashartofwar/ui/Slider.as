/*
 * The MIT License
 *
 * Original Author:  Jesse Freeman of FlashArtOfWar.com
 * Copyright (c) 2010
 * Class File: Slider.as
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.flashartofwar.ui
{
    import com.flashartofwar.behaviors.ISlider;
    import com.flashartofwar.behaviors.SliderBehavior;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;
    import flash.geom.Rectangle;

    public class Slider extends Sprite implements ISlider
    {

        private var behavior:SliderBehavior;
        private var track:Sprite;
        private var dragger:Sprite;
        private var _width:Number;
        private var _height:Number;
        private var draggerWidth:Number;
        private var roundedCorners:Number;
        private var maskShape:Sprite;

        public function Slider(width:Number = 100, height:Number = 10, draggerWidth:Number = 40, roundedCorners:Number = 5)
        {
            _width = width;
            _height = height;
            this.draggerWidth = draggerWidth;
            this.roundedCorners = roundedCorners;
            init();
        }

        override public function set width(value:Number):void
        {
            track.width = mask.width = Math.round(value);
            if (behavior) behavior.refresh();
        }

        override public function set height(value:Number):void
        {
            track.height = mask.height = Math.round(value);
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

            maskShape = createTrack();
            addChild(maskShape);
            mask = maskShape;
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(event:Event):void
        {
            behavior = new SliderBehavior(this);

            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        }

        private function onRemovedFromStage(event:Event):void
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        }

        private function createDragger():Sprite
        {
            var sprite:Sprite = new Sprite();
            sprite.name = SliderBehavior.DRAGGER;
            sprite.graphics.beginFill(0xffffff);
            sprite.graphics.drawRoundRect(0, 0, draggerWidth, _height, roundedCorners);
            sprite.graphics.endFill();
            sprite.graphics.lineStyle(2, 0x666666, .6);

            sprite.graphics.moveTo(draggerWidth/2 , 2);
            sprite.graphics.lineTo(draggerWidth/2, _height - 2);

            sprite.graphics.moveTo(draggerWidth/2 + 3, 2);
            sprite.graphics.lineTo(draggerWidth/2 + 3, _height - 2);

            sprite.graphics.moveTo(draggerWidth/2 - 3, 2);
            sprite.graphics.lineTo(draggerWidth/2 - 3, _height - 2);

            sprite.buttonMode = true;
            sprite.useHandCursor = true;

            var dropShadow:DropShadowFilter = new DropShadowFilter();
            dropShadow.color = 0x000000;
            dropShadow.blurX = 40;
            dropShadow.strength = 1;
            dropShadow.alpha = .7;
            dropShadow.distance = 0;

            var filtersArray:Array = new Array(dropShadow);
            sprite.filters = filtersArray;
            
            return sprite;
        }

        private function createTrack():Sprite
        {
            var sprite:Sprite = new Sprite();
            sprite.name = SliderBehavior.TRACK;
            sprite.graphics.beginFill(0x000000, .4);
            sprite.graphics.drawRoundRect(0, 0, _width, _height, roundedCorners);
            sprite.graphics.endFill();
            sprite.scale9Grid = new Rectangle(roundedCorners+2, _height/2 + 2, _width - (roundedCorners * 2 + 4), 2);
            return sprite;
        }


    }
}

