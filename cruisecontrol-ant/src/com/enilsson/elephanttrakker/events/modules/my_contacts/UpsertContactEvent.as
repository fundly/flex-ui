package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class UpsertContactEvent extends CairngormEvent
	{
		static public var EVENT_UPSERT_CONTACT:String = 'upsert_contact';

		public var formData:Object;
		
		public function UpsertContactEvent(formData:Object)
		{
			super( EVENT_UPSERT_CONTACT );
			
			this.formData = formData;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new UpsertContactEvent(formData);
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