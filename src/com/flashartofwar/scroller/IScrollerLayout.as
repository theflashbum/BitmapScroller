package com.flashartofwar.scroller
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public interface IScrollerLayout
	{
		function clear():void;
		function position(bmd:BitmapData):void;
		
		function getVisibleBitmaps(visibleArea:Rectangle):Array;
		
		function getRect(bmd:BitmapData, area:Rectangle):Rectangle;
		function adjustOffset(rect:Rectangle, offset:Point):Point;
		
		function get height():Number;
		function get width():Number;
	}
}