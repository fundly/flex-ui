package com.enilsson.elephantadmin.events.session
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SessionFailEvent extends CairngormEvent
	{
		static public var EVENT_SESSION_FAIL:String = 'session_fail';
		
		public var faultCode:String;
		
		public function SessionFailEvent( faultCode:String )
		{
			super( EVENT_SESSION_FAIL );
			
			this.faultCode = faultCode;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new SessionFailEvent( faultCode );
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