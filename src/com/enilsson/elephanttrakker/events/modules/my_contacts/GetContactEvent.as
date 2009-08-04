package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetContactEvent extends CairngormEvent
	{
		static public var EVENT_GET_CONTACT:String = 'get_contact';
		static public var EVENT_GET_CONTACT_INFO:String = 'get_contact_info';
		
		public var contactID:int;
		public var e:String;
		
		public function GetContactEvent(e:String = 'get_contact', contactID:int = 0)
		{
			super( e );
			
			this.contactID = contactID;
			this.e = e;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetContactEvent(e, contactID );
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