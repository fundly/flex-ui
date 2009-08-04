package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetContactHistoryEvent extends CairngormEvent
	{
		static public var EVENT_GET_CONTACT_HISTORY:String = 'get_contact_history';
		
		public var contactID:int;
		
		public function GetContactHistoryEvent( contactID:int )
		{
			super( EVENT_GET_CONTACT_HISTORY );
			
			this.contactID = contactID;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetContactHistoryEvent( contactID );
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