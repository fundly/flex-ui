package com.enilsson.elephantadmin.events.session
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class PingEvent extends CairngormEvent
	{
		static public var EVENT_PING:String = 'ping';
		
		public function PingEvent()
		{
			super( EVENT_PING );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new PingEvent();
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