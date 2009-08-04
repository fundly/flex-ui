package com.enilsson.elephanttrakker.events.modules.call_logging
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.vo.LayoutVO;
	
	import flash.events.Event;

	public class CallLoggingLayoutEvent extends CairngormEvent
	{
		static public var EVENT_LAYOUT:String = 'layout';
		
		public var layout:LayoutVO;
		
		public function CallLoggingLayoutEvent(layout:LayoutVO)
		{
			super( EVENT_LAYOUT );
			
			this.layout = layout;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new CallLoggingLayoutEvent(layout);
		}
		
		/**
		 * Override copyFrom method to get a copy of this event.
		 */
		public function copyFrom(src:Event):Event 
		{	
			return this;
		}
		
		/**
		 * String representation of class.
		 */
		override public function toString():String 
		{	
			return super.toString();
		}
		
	}
}