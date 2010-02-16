package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SearchMyContactsEvent extends CairngormEvent
	{
		static public var EVENT_SEARCH_MYCONTACTS:String = 'search_mycontacts';

		public var searchTerm:String;		
		public var iFrom:int;
		public var iCount:int;
		
		public function SearchMyContactsEvent(searchTerm:String, iFrom:int=0, iCount:int=200)
		{
			super( EVENT_SEARCH_MYCONTACTS );
			
			this.searchTerm = searchTerm;
			this.iFrom = iFrom;
			this.iCount = iCount;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new SearchMyContactsEvent(searchTerm, iFrom, iCount);
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