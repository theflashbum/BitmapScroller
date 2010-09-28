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
	import com.flashartofwar.scroller.IScrollerLayout;
	import com.flashartofwar.scroller.VerticalScrollerLayout;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * BitmapScroller v1.1
	 * @author Paul Taylor, guyinthechair.com
	 *
	 */
	public class BitmapScroller extends Bitmap
	{
		public function BitmapScroller(pixelSnapping:String = "auto", smoothing:Boolean = false)
		{
			super(null, pixelSnapping, smoothing);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * Tells BitmapScroller to force the Flash Player to cache the
		 * pixels of each bitmap when the bitmap is first indexed.
		 *
		 * The increased rendering time of large bitmaps will cause the
		 * Flash Player to extend the rendering phase of the frame's
		 * life, causing a visible hang when the bitmaps are first
		 * scrolled.
		 *
		 * If this is set to true, BitmapScroller will force the
		 * Flash Player to cache the pixels of each bitmap when it is
		 * first introduced. This increases bitmap indexing time,
		 * but ensures that the first scroll is as fast as the rest.
		 *
		 * @default false
		 */
		public var cacheOnIndex:Boolean = false;
		
		private var area:Rectangle = new Rectangle(0, 0, 1, 1);
		
		private var sizeChanged:Boolean = false;
		private var invalidated:Boolean = false;
		
		override public function get width():Number
		{
			return area.width;
		}
		
		override public function set width(value:Number):void
		{
			if(value == area.width)
				return;
			
			area.width = value;
			sizeChanged = true;
			invalidated = true;
		}
		
		override public function get height():Number
		{
			return area.height;
		}
		
		override public function set height(value:Number):void
		{
			if(value == area.height)
				return;
			
			area.height = value;
			sizeChanged = true;
			invalidated = true;
		}
		
		override public function set scrollRect(value:Rectangle):void
		{
			area.x = value.x;
			area.y = value.y;
			width = value.width;
			height = value.height;
			invalidated = true;
		}
		
		override public function get scrollRect():Rectangle
		{
			return area.clone();
		}
		
		public function get scrollX():Number
		{
			return area.x;
		}
		
		public function set scrollX(value:Number):void
		{
			if(value == area.x)
				return;
			
			area.x = value;
			invalidated = true;
		}
		
		public function get scrollY():Number
		{
			return area.y;
		}
		
		public function set scrollY(value:Number):void
		{
			if(value == area.y)
				return;
			
			area.y = value;
			invalidated = true;
		}
		
		public function get totalWidth():Number
		{
			return layout.width;
		}
		
		public function get totalHeight():Number
		{
			return layout.height;
		}
		
		public function render():void
		{
			if(!invalidated)
				return;
			
			if(sizeChanged)
				initBitmapData();
			else
				bitmapData.fillRect(area, 0);
			
			draw();
			invalidated = false;
		}
		
		public function get layout():IScrollerLayout
		{
			return _layout ||= new VerticalScrollerLayout();
		}
		
		private var _layout:IScrollerLayout;
		
		public function set layout(value:IScrollerLayout):void
		{
			if(value == _layout)
				return;
			
			_layout = value;
			indexCollection();
		}
		
		private var _bitmapDataCollection:Array;
		
		public function get bitmapDataCollection():Array
		{
			return _bitmapDataCollection;
		}
		
		public function set bitmapDataCollection(value:Array):void
		{
			if(value == _bitmapDataCollection)
				return;
			
			_bitmapDataCollection = value;
			indexCollection();
		}
		
		protected function indexCollection():void
		{
			if(!bitmapDataCollection)
				return;
			
			var n:int = bitmapDataCollection.length;
			var val:Object;
			
			for(var i:int = 0; i < n; i += 1)
			{
				val = bitmapDataCollection[i];
				
				if(val is BitmapData)
					indexBitmapData(BitmapData(val));
				else
					throw new Error("ScrollingBitmap can only process BitmapData.");
			}
		}
		
		protected function indexBitmapData(bmp:BitmapData):void
		{
			layout.position(bmp);
			
			if(!cacheOnIndex)
				return;
			
			if(!bitmapData)
				initBitmapData();
			
			bitmapData.copyPixels(bmp, bmp.rect.clone(), new Point());
		}
		
		protected function initBitmapData():void
		{
			bitmapData = new BitmapData(area.width, area.height, true, 0);
		}
		
		protected function draw():void
		{
			var theArea:Rectangle = area.clone();
			var bitmaps:Array = layout.getVisibleBitmaps(theArea);
			var n:int = bitmaps.length;
			
			var bmd:BitmapData;
			var rect:Rectangle;
			var offset:Point = new Point();
			
			for(var i:int = 0; i < n; i += 1)
			{
				bmd = bitmaps[i];
				
				rect = layout.getRect(bmd, theArea);
				
				bitmapData.copyPixels(bmd, rect, offset);
				
				offset = layout.adjustOffset(rect, offset);
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
	}
}