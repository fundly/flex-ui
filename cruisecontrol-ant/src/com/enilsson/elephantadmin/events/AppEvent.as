package com.enilsson.elephantadmin.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;	

	public class AppEvent extends CairngormEvent
	{
		static public var EVENT_APP:String = 'app';
		
		public function AppEvent()
		{
			super( EVENT_APP );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new AppEvent();
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