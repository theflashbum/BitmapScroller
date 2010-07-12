/*
 * The MIT License
 *
 * Original Author:  Jesse Freeman of FlashArtOfWar.com
 * Copyright (c) 2010
 * Class File: BitmapScroller.as
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
 * 
 */

package com.flashartofwar
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class BitmapScroller extends Bitmap
    {
        protected const INVALID_SIZE:String = "size";
        protected const INVALID_SCROLL:String = "scroll";
        protected const INVALID_SIZE_SCROLL:String = "all";
        protected const INVALID_VISUALS:String = "visuals";

        protected var _bitmapDataCollection:Array;
        protected var collectionRects:Array = [];
        protected var _totalWidth:int = 0;
        protected var _maxHeight:Number = 0;
        protected var collectionTotal:int = 0;
        protected var copyPixelOffset:Point = new Point();
        protected var internalSampleArea:Rectangle = new Rectangle(0, 0, 0, 0);
        protected var collectionID:int;
        protected var sourceRect:Rectangle;
        protected var sourceBitmapData:BitmapData;
        protected var leftOver:Number;
        protected var point:Point;
        protected var calculationPoint:Point = new Point();
        protected var difference:Number;
        protected var sampleArea:Rectangle;
        protected var samplePositionPoint:Point = new Point();
        protected var _invalid:Boolean;
        protected var invalidSize:Boolean;
        protected var invalidScroll:Boolean;
        protected var invalidVisuals:Boolean;


        public function BitmapScroller(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false)
        {
            super(null, pixelSnapping, smoothing);
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        override public function get width():Number
        {
            return internalSampleArea.width;
        }

        override public function set width(value:Number):void
        {
            if (value == internalSampleArea.width)
            {
                return;
            }
            else
            {
                internalSampleArea.width = value;
                invalidate(INVALID_SIZE);
            }
        }

        override public function get height():Number
        {
            return internalSampleArea.height;
        }

        override public function set height(value:Number):void
        {
            if (value == internalSampleArea.height)
            {
                return;
            }
            else
            {
                internalSampleArea.height = value;
                invalidate(INVALID_SIZE);
            }
        }

        public function get scrollX():Number
        {
            return internalSampleArea.x;
        }

        public function set scrollX(value:Number):void
        {
            if (value == internalSampleArea.x)
            {
                return;
            }
            else
            {
                internalSampleArea.x = value;
                invalidate(INVALID_SCROLL);
            }
        }

        public function get totalWidth():int
        {
            return _totalWidth;
        }

        public function get maxHeight():Number
        {
            return _maxHeight;
        }

        public function render():void
        {

            if (_invalid)
            {
                // We check to see if the size has changed. If it has we create a new bitmap. If not we clear it with fillRect
                if (invalidSize)
                {
                    bitmapData = new BitmapData(internalSampleArea.width, internalSampleArea.height, true, 0x000000);
                }
                else
                {
                    bitmapData.fillRect(internalSampleArea, 0);
                }

                // Call sample to get the party started
                draw(internalSampleArea.clone());

                // Clear any invalidation
                clearInvalidation();
            }
        }

        private function clearInvalidation():void
        {
            _invalid = false;
            invalidSize = false;
            invalidScroll = false;
            invalidVisuals = false;
        }

        protected function indexCollection():void
        {
            var i:int;
            collectionTotal = _bitmapDataCollection.length;
            _totalWidth = 0;
            _maxHeight = 0;

            for (i = 0; i < collectionTotal; ++ i)
            {
                if (_bitmapDataCollection[i] is BitmapData)
                {
                    indexBitmapData(_bitmapDataCollection[i]);
                }
                else
                {
                    throw new Error("BitmapScroller can only process BitmapData.");
                }
            }

        }

        protected function indexBitmapData(bmd:BitmapData):void
        {
            var lastRect:Rectangle = collectionRects[collectionRects.length - 1];

            var lastX:int = lastRect ? lastRect.x + lastRect.width + 1 : 0;

            // create a rect to represent the BitmapData
            var rect:Rectangle = new Rectangle(lastX, 0, bmd.width, bmd.height);

            collectionRects.push(rect);

            _totalWidth += rect.width;

            if (bmd.height > _maxHeight)
            {
                _maxHeight = bmd.height;
            }

        }

        /**
         *
         * @param sampleCoord
         * @return
         */
        protected function calculateCollectionStartIndex(sampleCoord:Point):int
        {

            if (sampleCoord.x < 0)
                return -1;

            var i:int;

            for (i = 0; i < collectionTotal; ++ i)
            {
                if (collectionRects[i].containsPoint(sampleCoord))
                {
                    return i;
                }
            }

            return -1;
        }

        protected function draw(sampleArea:Rectangle, offset:Point = null):void
        {
            calculationPoint.x = sampleArea.x;
            calculationPoint.y = sampleArea.y;

            collectionID = calculateCollectionStartIndex(calculationPoint);

            if (collectionID != -1)
            {
                sourceRect = collectionRects[collectionID];

                sourceBitmapData = _bitmapDataCollection[collectionID];

                leftOver = Math.round(calculateLeftOverValue(sampleArea.x, sampleArea.width, sourceRect));

                if (!offset)
                    offset = copyPixelOffset;

                point = calculateSamplePosition(sampleArea, sourceRect);

                sampleArea.x = point.x;
                sampleArea.y = point.y;

                bitmapData.copyPixels(sourceBitmapData, sampleArea, offset);

                if (leftOver > 0)
                {
                    offset = new Point(bitmapData.width - leftOver, 0);
                    var leftOverSampleArea:Rectangle = calculateLeftOverSampleArea(sampleArea, leftOver, sourceRect);

                    draw(leftOverSampleArea, offset);
                }

            }
        }


        protected function calculateLeftOverValue(offset:Number, sampleWidth:Number, sourceRect:Rectangle):Number
        {

            difference = (offset + sampleWidth) - (sourceRect.x + sourceRect.width);

            return (difference < 0) ? 0 : difference;
        }


        protected function calculateLeftoverOffset(sampleArea:Rectangle, leftOver:Number):Point
        {

            return new Point(sampleArea.width - leftOver, 0);
        }

        protected function calculateLeftOverSampleArea(sampleAreaSRC:Rectangle, leftOver:Number, sourceRect:Rectangle):Rectangle
        {
            sampleArea = sampleAreaSRC.clone();
            sampleArea.width = leftOver + 1;
            sampleArea.x = sourceRect.x + sourceRect.width + 1;

            return sampleArea;
        }

        protected function calculateSamplePosition(sampleRect:Rectangle, sourceArea:Rectangle):Point
        {
            samplePositionPoint.x = sampleRect.x - sourceArea.x;

            return samplePositionPoint;
        }

        public function clear():void
        {

        }

        /** Invalidation Logic **/

        protected function invalidate(type:String = "all"):void
        {
            if (!_invalid)
            {
                _invalid = true;

                switch (type)
                {
                    case INVALID_VISUALS:
                        invalidVisuals = true;
                        break;
                    case INVALID_SIZE:
                        invalidSize = true;
                        break;
                    case INVALID_SCROLL:
                        invalidScroll = true;
                        break;
                    case INVALID_SIZE_SCROLL:
                        invalidScroll = true;
                        invalidSize = true;
                        break;
                }
            }
        }

        /**
         *
         * @param event
         */
        protected function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            render();
        }

        /**
         *
         * @param event
         */
        protected function onRemovedFromStage(event:Event):void
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        public function set bitmapDataCollection(value:Array):void
        {
            _bitmapDataCollection = value;
            indexCollection();
        }
    }
}