package com.enilsson.elephantadmin.events.session
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class UpdateSessionEvent extends CairngormEvent
	{

		static public var EVENT_UPDATE_SESSION:String = 'update_session';
		
		public function UpdateSessionEvent()
		{
			super( EVENT_UPDATE_SESSION );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new UpdateSessionEvent();
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