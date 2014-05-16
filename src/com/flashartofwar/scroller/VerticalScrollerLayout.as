package com.flashartofwar.scroller
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public final class VerticalScrollerLayout extends ScrollerLayout
	{
		public function VerticalScrollerLayout()
		{
			bitmaps = new SparseArray();
		}
		
		override public function clear():void
		{
			bitmaps = new SparseArray();
		}
		
		override public function position(bmp:BitmapData):void
		{
			if(bmp.width > largestWidth)
				largestWidth = bmp.width;
			
			SparseArray(bitmaps).add(bmp, bmp.height);
		}
		
		override public function getRect(bmd:BitmapData, area:Rectangle):Rectangle
		{
			var rect:Rectangle = super.getRect(bmd, area);
			
			var position:int = SparseArray(bitmaps).getItemPosition(bmd);
			
			if(area.y > position)
			{
				rect.y = area.y - position;
				rect.height -= (area.y - position);
			}
			
			return rect;
		}
		
		override public function adjustOffset(rect:Rectangle, offset:Point):Point
		{
			offset.y += rect.height;
			return offset;
		}
		
		override public function getVisibleBitmaps(visibleArea:Rectangle):Array
		{
			return SparseArray(bitmaps).getRange(visibleArea.y, visibleArea.y + visibleArea.height);
		}
		
		private var largestWidth:Number = 0;
		
		override public function get width():Number
		{
			return largestWidth;
		}
		
		override public function get height():Number
		{
			return SparseArray(bitmaps).size;
		}
	}
}