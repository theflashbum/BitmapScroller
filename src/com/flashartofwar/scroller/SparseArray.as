package com.flashartofwar.scroller
{
	import flash.utils.Dictionary;
	
	public dynamic class SparseArray extends Array
	{
		private var positionMap:Dictionary = new Dictionary(false);
		private var _size:Number = 0;
		
		public function add(item:*, size:int):*
		{
			positionMap[_size] = length;
			positionMap[item] = _size;
			push(item);
			_size += size;
		}
		
		public function get size():Number
		{
			return _size;
		}
		
		public function clear():void
		{
			positionMap = new Dictionary(false);
			length = 0;
			_size = 0;
		}
		
		public function getItemPosition(item:*):int
		{
			if(!hasItem(item))
				return -1;
			
			return positionMap[item];
		}
		
		public function hasItem(item:*):Boolean
		{
			return item in positionMap;
		}
		
		public function getRange(start:int, end:int):Array
		{
			var a:Array = [];
			
			start = getPositionIndex(start);
			end = Math.min(getPositionIndex(end) + 1, length);
			
			for(; start < end; start += 1)
			{
				a.push(this[start]);
			}
			
			return a;
		}
		
		private function getPositionIndex(position:int):int
		{
			while((position in positionMap) == false)
			{
				position -= 1;
				if(position < 0)
					return 0;
			}
			
			return positionMap[position];
		}
	}
}