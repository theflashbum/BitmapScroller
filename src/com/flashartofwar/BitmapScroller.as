package com.flashartofwar
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class BitmapScroller extends Bitmap
    {

        private var _bitmapDataCollection:Vector.<BitmapData>;
        protected var collectionRects:Vector.<Rectangle>;
        protected var _totalWidth:int = 0;
        protected var _maxHeight:Number = 0;
        protected var collectionTotal:int = 0;
        protected var copyPixelOffset:Point = new Point();
        protected var directionProp:String = "x";
        protected var inverseDirectionProp:String = "y";
        protected var dimensionProp:String = "width";
        protected var inverseDimensionProp:String = "height";
        private var _internalSampleArea:Rectangle;
        protected var collectionID:int;
        protected var sourceRect:Rectangle;
        protected var sourceBitmapData:BitmapData;
        protected var leftOver:Number;
        protected var sampleAreaX:Number;
        protected var point:Point;
        protected var calculationPoint:Point = new Point();
        protected var difference:Number;
        protected var sampleArea:Rectangle;
        protected var samplePositionPoint:Point = new Point();
        protected var _invalid:Boolean;
        protected var invalidSize:Boolean;
        protected var invalidScroll:Boolean;
        private const INVALID_SIZE:String = "size";
        private const INVALID_SCROLL:String = "scroll";
        private const INVALID_SIZE_SCROLL:String = "all";

        public function BitmapScroller(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false)
        {
            super(null, pixelSnapping ,smoothing);
            internalSampleArea = new Rectangle(0,0, 600, 800);
        }


        override public function get width():Number
        {
            return _internalSampleArea.width;
        }

        override public function set width(value:Number):void
        {
            if( value == _internalSampleArea.width)
            {
                return;
            }
            else
            {
                _internalSampleArea.width = value;
                invalidate(INVALID_SIZE);
            }
        }

        override public function get height():Number
        {
            return _internalSampleArea.height;
        }

        override public function set height(value:Number):void
        {
            if( value == _internalSampleArea.height)
            {
                return;
            }
            else
            {
                _internalSampleArea.height = value;
                invalidate(INVALID_SIZE);
            }
        }

        public function get scrollX():Number
        {
            return _internalSampleArea.x;
        }

        public function set scrollX(value:Number):void
        {
             if(value == _internalSampleArea.x)
             {
                 return;
             }
            else
             {
                 trace("value",value);
                 _internalSampleArea.x = value;
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

        public function set direction(value:String):void
        {
            //TODO this needs to be implemented
            if (value == "horizontal")
            {
                directionProp = "x";
                inverseDirectionProp = "y";
                dimensionProp = "width";
                inverseDirectionProp = "height";
            }
        }

        public function render():void
        {

            if (_invalid)
            {
                // We check to see if the size has changed. If it has we create a new bitmap. If not we clear it with fillRect
                trace("Render");
                if(invalidSize)
                {
                    bitmapData = new BitmapData(_internalSampleArea.width, _internalSampleArea.height, false, 0x000000);
                    invalidSize = true;
                }
                else
                {
                    bitmapData.fillRect(_internalSampleArea, 0);
                }

                // Call sample to get the party started
                draw(_internalSampleArea.clone(), bitmapData);

                // Clear any invalidation
                _invalid = false;
            }
        }

        protected function indexCollection():void
        {
            var bmd:BitmapData;
            var lastX:Number = 0;
            var i:int;
            collectionTotal = _bitmapDataCollection.length;
            var rect:Rectangle;

            collectionRects = new Vector.<Rectangle>(collectionTotal);

            var lastWidth:Number = 0;
            _totalWidth = 0;
            _maxHeight = 0;

            for (i = 0; i < collectionTotal; ++ i)
            {
                bmd = _bitmapDataCollection[i] as BitmapData;

                // create a rect to represent the BitmapData
                rect = new Rectangle(lastX, 0, bmd.width, bmd.height);
                collectionRects[i] = rect;

                lastX += bmd[dimensionProp] + 1;
                // Save out width information
                lastWidth = bmd[dimensionProp];

                _totalWidth += lastWidth;

                if (bmd[inverseDimensionProp] > maxHeight)
                {
                    _maxHeight = bmd[inverseDimensionProp];
                }
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

        protected function draw(sampleArea:Rectangle, output:BitmapData, offset:Point = null):void
        {

            calculationPoint.x = sampleArea.x;
            calculationPoint.y = sampleArea.y;

            collectionID = calculateCollectionStartIndex(calculationPoint);

            if (collectionID != -1)
            {
                sourceRect = collectionRects[collectionID];

                sourceBitmapData = _bitmapDataCollection[collectionID];

                leftOver = calculateLeftOverValue(sampleArea[directionProp], sampleArea[dimensionProp], sourceRect);

                sampleAreaX = sampleArea[directionProp];

                if (!offset)
                    offset = copyPixelOffset;

                point = calculateSamplePosition(sampleArea, sourceRect);

                sampleArea.x = point.x;
                sampleArea.y = point.y;

                output.copyPixels(sourceBitmapData, sampleArea, offset);

                if (leftOver > 0)
                {
                    offset = new Point(output[dimensionProp] - leftOver, 0);
                    var leftOverSampleArea:Rectangle = calculateLeftOverSampleArea(sampleArea, leftOver, sourceRect);

                    draw(leftOverSampleArea, output, offset);
                }

            }
        }


        protected function calculateLeftOverValue(offset:Number, sampleWidth:Number, sourceRect:Rectangle):Number
        {

            difference = (offset + sampleWidth) - (sourceRect[directionProp] + sourceRect[dimensionProp]);

            return (difference < 0) ? 0 : difference;
        }


        protected function calculateLeftoverOffset(sampleArea:Rectangle, leftOver:Number):Point
        {

            return new Point(sampleArea[dimensionProp] - leftOver, 0);
        }

        protected function calculateLeftOverSampleArea(sampleAreaSRC:Rectangle, leftOver:Number, sourceRect:Rectangle):Rectangle
        {
            sampleArea = sampleAreaSRC.clone();
            sampleArea[dimensionProp] = leftOver + 1;
            sampleArea[directionProp] = sourceRect[directionProp] + sourceRect[dimensionProp] + 1;

            return sampleArea;
        }

        protected function calculateSamplePosition(sampleRect:Rectangle, sourceArea:Rectangle):Point
        {
            samplePositionPoint[directionProp] = sampleRect[directionProp] - sourceArea[directionProp];

            return samplePositionPoint;
        }

        public function get internalSampleArea():Rectangle
        {
            return _internalSampleArea;
        }

        public function set internalSampleArea(value:Rectangle):void
        {
            _internalSampleArea = value;
            bitmapData = new BitmapData(_internalSampleArea.width, _internalSampleArea.height, false, 0x000000);
            render();
        }


        public function clear():void
        {

        }

        /** Invalidation Logic **/

        protected function invalidate(type:String = "all"):void
        {
            if (!_invalid)
            {
                try
                {
                    stage.invalidate();
                    _invalid = true;

                    switch(type)
                    {
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
                catch(error:Error)
                {
                    _invalid = false;
                }
            }
        }

        /**
         *
         * @param event
         */
        protected function onAddedToStage(event:Event):void
        {
            //render();
        }

        /**
         *
         * @param event
         */
        protected function onRemovedFromStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        }

        public function set bitmapDataCollection(value:Vector.<BitmapData>):void
        {
            _bitmapDataCollection = value;
            indexCollection();
        }
    }
}