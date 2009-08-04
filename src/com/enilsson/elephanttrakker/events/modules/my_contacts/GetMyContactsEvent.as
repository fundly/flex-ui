package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetMyContactsEvent extends CairngormEvent
	{
		static public var EVENT_GET_MYCONTACTS:String = 'get_mycontacts';
		static public var CONTACTS_FETCHED:String = 'contacts_fetched';
		
		public var iFrom:int;
		public var iCount:int;
		public var paginate:String;
		public var sort:String;
		public var evt:String;
		
		public function GetMyContactsEvent(evt:String = 'get_mycontacts', iFrom:int=0, iCount:int=200, paginate:String='', sort:String='')
		{
			super( evt);
			
			this.evt = evt;
			this.iFrom = iFrom;
			this.iCount = iCount;
			this.paginate = paginate;
			this.sort = sort;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetMyContactsEvent(evt, iFrom, iCount, paginate, sort);
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