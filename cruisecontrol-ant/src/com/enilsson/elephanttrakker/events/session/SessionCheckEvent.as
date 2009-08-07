package com.enilsson.elephanttrakker.events.session
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SessionCheckEvent extends CairngormEvent
	{

		static public var EVENT_SESSION_CHECK:String = 'session_check';
		
		public function SessionCheckEvent()
		{
			super( EVENT_SESSION_CHECK );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new SessionCheckEvent();
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