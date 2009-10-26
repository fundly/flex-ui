package com.enilsson.elephanttrakker.events.main
{
	import flash.events.Event;
	
	import mx.utils.UIDUtil;
	
	public class ResizeContentEvent extends Event
	{
		public static const RESTORE : String = UIDUtil.createUID();
		public static const RESIZE 	: String = UIDUtil.createUID();
		
		public function get width() : Number { return _width; }
		private var _width : Number;
		
		public function get height() : Number { return _height; }
		private var _height : Number;
		
		public function ResizeContentEvent(type:String, width : Number = NaN, height : Number = NaN) {
			super(type, true, false);
			
			if(type == RESIZE) {
				_width = width;
				_height = height;
			}						
		}
	}
}