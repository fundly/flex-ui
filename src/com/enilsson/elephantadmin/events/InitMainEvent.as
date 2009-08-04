package com.enilsson.elephantadmin.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class InitMainEvent extends CairngormEvent
	{
		static public var EVENT_MAIN_APP:String = 'init_main';
		
		public function InitMainEvent()
		{
			super( EVENT_MAIN_APP );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new InitMainEvent();
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