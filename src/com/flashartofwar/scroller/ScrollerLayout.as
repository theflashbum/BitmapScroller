package com.flashartofwar.scroller
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ScrollerLayout implements IScrollerLayout
	{
		public function clear():void
		{
			bitmaps = [];
		}
		
		protected var bitmaps:Array = [];
		
		public function getRect(bmd:BitmapData, area:Rectangle):Rectangle
		{
			return bmd.rect.clone();
		}
		
		public function adjustOffset(rect:Rectangle, offset:Point):Point
		{
			return offset;
		}
		
		public function getVisibleBitmaps(visibleArea:Rectangle):Array
		{
			return bitmaps;
		}
		
		public function position(bmd:BitmapData):void
		{
			bitmaps.push(bmd);
		}
		
		public function get height():Number
		{
			return 0;
		}
		
		public function get width():Number
		{
			return 0;
		}
	}
}