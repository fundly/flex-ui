package com.enilsson.elephanttrakker.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetSiteOptionsEvent extends CairngormEvent
	{
		static public var EVENT_GET_OPTIONS:String = 'get_options';
		
		public function GetSiteOptionsEvent()
		{
			super( EVENT_GET_OPTIONS );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetSiteOptionsEvent();
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