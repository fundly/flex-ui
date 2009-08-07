package com.enilsson.elephanttrakker.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetStruktorLayoutEvent extends CairngormEvent
	{
		static public var GET_STRUKTOR_LAYOUT:String = 'get_struktor_layout';
		
		public function GetStruktorLayoutEvent()
		{
			super( GET_STRUKTOR_LAYOUT );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetSiteLayoutEvent();
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