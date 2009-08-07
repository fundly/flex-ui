package com.enilsson.elephantadmin.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SidEvent extends CairngormEvent
	{
		static public var TEST_SID:String = 'test_sid';
		
		public var sid:String;
		
		public function SidEvent( sid:String )
		{
			super( TEST_SID );
			
			this.sid = sid;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new SidEvent( sid );
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