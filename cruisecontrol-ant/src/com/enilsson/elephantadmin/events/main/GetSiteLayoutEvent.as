package com.enilsson.elephantadmin.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetSiteLayoutEvent extends CairngormEvent
	{
		static public var EVENT_GET_LAYOUT:String = 'get_layout';
		
		public function GetSiteLayoutEvent()
		{
			super( EVENT_GET_LAYOUT );
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