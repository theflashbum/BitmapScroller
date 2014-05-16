package com.flashartofwar.scroller
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public final class HorizontalScrollerLayout extends ScrollerLayout
	{
		public function HorizontalScrollerLayout()
		{
			bitmaps = new SparseArray();
		}
		
		override public function clear():void
		{
			bitmaps = new SparseArray();
		}
		
		override public function position(bmp:BitmapData):void
		{
			if(bmp.height > largestHeight)
				largestHeight = bmp.height;
			
			SparseArray(bitmaps).add(bmp, bmp.width);
		}
		
		override public function getRect(bmd:BitmapData, area:Rectangle):Rectangle
		{
			var rect:Rectangle = super.getRect(bmd, area);
			
			var position:int = SparseArray(bitmaps).getItemPosition(bmd);
			
			if(area.x > position)
			{
				rect.x = area.x - position;
				rect.width -= (area.x - position);
			}
			
			return rect;
		}
		
		override public function adjustOffset(rect:Rectangle, offset:Point):Point
		{
			offset.x += rect.width;
			return offset;
		}
		
		override public function getVisibleBitmaps(visibleArea:Rectangle):Array
		{
			return SparseArray(bitmaps).getRange(visibleArea.x, visibleArea.x + visibleArea.width);
		}
		
		private var largestHeight:Number = 0;
		
		override public function get height():Number
		{
			return largestHeight;
		}
		
		override public function get width():Number
		{
			return SparseArray(bitmaps).size;
		}
	}
}