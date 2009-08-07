package com.enilsson.elephantadmin.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;	

	public class InitAppEvent extends CairngormEvent
	{
		static public var EVENT_INIT_APP:String = 'init_app';
		
		public function InitAppEvent()
		{
			super( EVENT_INIT_APP );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new InitAppEvent();
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