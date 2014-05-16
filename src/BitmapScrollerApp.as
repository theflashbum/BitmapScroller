/*
 * The MIT License
 *
 * Original Author:  Jesse Freeman of FlashArtOfWar.com
 * Copyright (c) 2010
 * Class File: BitmapScrollerApp.as
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

package
{
    import com.flashartofwar.BitmapScroller;
    import com.flashartofwar.behaviors.EaseScrollBehavior;
    import com.flashartofwar.scroller.HorizontalScrollerLayout;
    import com.flashartofwar.ui.Slider;

    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;

    import flash.text.TextField;

    import flash.text.TextFieldAutoSize;

    import net.hires.debug.Stats;

	[SWF(width="800",height="480",backgroundColor="#333333",frameRate="60")]
    public class BitmapScrollerApp extends Sprite
    {

        private var preloadList:Array = ["image1.jpg","image2.jpg","image3.jpg","image4.jpg","image5.jpg","image6.jpg","image7.jpg","image8.jpg","image9.jpg","image10.jpg","image11.jpg","image12.jpg","image13.jpg","image14.jpg","image15.jpg","image16.jpg","image17.jpg","image18.jpg","image19.jpg","image20.jpg","image21.jpg","image22.jpg","image23.jpg"];
        private var baseURL:String = "images/";
        private var currentlyLoading:String;
        private var loader:Loader = new Loader();
        private var bitmapScroller:BitmapScroller;
        private var images:Array = new Array();
        private var easeScrollBehavior:EaseScrollBehavior;
        private var stats:Stats;
        private var isMouseDown:Boolean;
        private var slider:Slider;
        private var preloadStatus:TextField;

        /**
         *
         */
        public function BitmapScrollerApp()
        {
            trace("Hello");
			
			configureStage();

            if (CONFIG::mobile)
            {
                baseURL = "/" + baseURL;
            }
			

            preloadStatus = new TextField();
			preloadStatus.text = "Loading...";
            preloadStatus.autoSize = TextFieldAutoSize.LEFT;
            preloadStatus.x = 10;
            preloadStatus.y = 10;
            preloadStatus.selectable = false;
            addChild(preloadStatus);
            
            preload();
			
        }

        /**
         *
         */
        private function configureStage():void
        {
            this.stage.align = StageAlign.TOP_LEFT;
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
        }

        /**
         *
         */
        protected function init():void
        {
            createBitmapScroller();
            createScrubber();
            createEaseScrollBehavior();
            createStats();

            if (!CONFIG::mobile)
            {
                // Once everything is set up add stage resize listeners
                this.stage.addEventListener(Event.RESIZE, onStageResize);

                // calls stage resize once to put everything in its correct place
                onStageResize();
            }
            else
            {
                //fingerTouch();
            }

            onStageResize();
            activateLoop();
        }

        /**
         *
         * @param event
         */
        private function onStageResize(event:Event = null):void
        {
            var stageWidth:int = stage.stageWidth;
            var stageHeight:int = stage.stageHeight;
			
			/*if (!CONFIG::mobile)
            {
				stageWidth = stage.fullScreenWidth;
				stageHeight = stage.fullScreenHeight;
			}*/
			
			bitmapScroller.width = slider.width = stageWidth;
            bitmapScroller.height = stageHeight;
           	stats.x = (stageWidth - stats.width) - 10;
			slider.y = stage.stageHeight - slider.height - 20;
			if(slider.y > 770)
				slider.y = 770;
            slider.width -= 40;
            slider.x = 20;
        }

        /**
         *
         */
        private function createStats():void
        {
            stats = addChild(new Stats({ bg: 0x000000 })) as Stats;
			stats.y = 10;
        }

        /**
         *
         */
        private function activateLoop():void
        {
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        /**
         *
         * @param event
         */
        private function onEnterFrame(event:Event):void
        {
            loop();
        }

        /**
         *
         */
        private function createEaseScrollBehavior():void
        {
            easeScrollBehavior = new EaseScrollBehavior(bitmapScroller, 0);
        }

        /**
         *
         */
        private function createScrubber():void
        {
            var sWidth:int = stage.stageWidth; 
            var sHeight:int = 10;
            var dWidth:int = 40;
            var corners:int = 5;
            if (CONFIG::mobile)
            {
                sHeight = 20;
                dWidth = 60;
                corners = 10;
            }

            slider = new Slider(sWidth, sHeight, dWidth, corners, 0);
            slider.y = stage.stageHeight - slider.height - 20;
			
            slider.addEventListener(Event.CHANGE, onSliderValueChange)
            addChild(slider);

        }

        private function onSliderValueChange(event:Event):void
        {
            trace("Slider Changed", slider.value);
        }

        /**
         *
         */
        private function createBitmapScroller():void
        {

            bitmapScroller = new BitmapScroller();
            bitmapScroller.layout = new HorizontalScrollerLayout();
            bitmapScroller.bitmapDataCollection = images;
            addChild(bitmapScroller);
            bitmapScroller.width = stage.stageWidth;
            bitmapScroller.height = stage.stageHeight;

        }

        /**
         * Handles preloading our images. Checks to see how many are left then
         * calls loadNext or compositeImage.
         */
        protected function preload():void
        {

            if (preloadList.length == 0)
            {
                removeChild(preloadStatus);
                init();
            }
            else
            {
                loadNext();
                preloadStatus.text = preloadList.length + " Images Left To Load.";
            }
        }

        /**
         * Loads the next item in the prelaodList
         */
        private function loadNext():void
        {
            currentlyLoading = preloadList.shift();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

            loader.load(new URLRequest(baseURL + currentlyLoading));
        }

        /**
         *
         * @param event
         */
        private function onError(event:*):void
        {
            preloadStatus.text = event.text;
        }

        /**
         * Handles onLoad, saves the BitmapData then calls preload
         */
        private function onLoad(event:Event):void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoad);

            images.push(Bitmap(event.target.content).bitmapData);

            currentlyLoading = null;

            preload();
        }

        /**
         *
         */
        public function loop():void
        {
            var percent:Number = slider.value / 100;
            var s:Number = bitmapScroller.totalWidth;
            var t:Number = bitmapScroller.width;

            easeScrollBehavior.targetX = percent * (s - t);
            //
            easeScrollBehavior.update();
            //
            bitmapScroller.render();
        }

        // This is for mobile touch support

        /**
         *
         */
        private function fingerTouch():void
        {
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }

        /**
         *
         * @param event
         */
        private function onMouseDown(event:MouseEvent):void
        {
            isMouseDown = true;
        }

        /**
         *
         * @param event
         */
        private function onMouseUp(event:MouseEvent):void
        {
            isMouseDown = false;
        }

        /**
         *
         * @param event
         */
        private function onMouseMove(event:MouseEvent):void
        {
            if (isMouseDown)
            {
                var percent:Number = (event.localX) / (stage.stageWidth) * 100;
                slider.value = percent;
            }
        }
    }
}