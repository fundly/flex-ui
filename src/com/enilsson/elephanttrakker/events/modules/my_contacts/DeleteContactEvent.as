package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class DeleteContactEvent extends CairngormEvent
	{
		static public var EVENT_DELETE_CONTACT:String = 'delete_contact';
		
		public var contactID:int;
		
		public function DeleteContactEvent( contactID:int )
		{
			super( EVENT_DELETE_CONTACT );
			
			this.contactID = contactID;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new DeleteContactEvent( contactID );
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