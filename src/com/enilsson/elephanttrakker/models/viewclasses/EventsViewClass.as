package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;

	/**
	 * A collection of data for the Events module
	 */	
	[Bindable]
	public class EventsViewClass
	{
		public function EventsViewClass()
		{
		}
		
		public var events:ArrayCollection = new ArrayCollection();
		
		public var showTable:Boolean = false;
		public var numEvents:int = 0;
		public var showPagination:Boolean = false;
	
		public var showRSVPForm:Boolean = false;
		public var showDetails:Boolean = false;
		
		public var errorVO:ErrorVO;
		
		public var eventDetails:Object;
		public var rsvpDetails:Object;
		
		public var isSubmitting:Boolean = false;
		
		public var onClose:Function;
		
		public var selectedEventName:String;
		public var selectedEventID:uint;
		public var selectedContactName:String;
		public var selectedContactID:uint;
		public var selectedData:Object;
		
		public var showRSVPFormOnStart:Boolean = false;
		
		public var events_eventsSearch:ArrayCollection = new ArrayCollection();
		public var events_contactsSearch:ArrayCollection = new ArrayCollection();

	}
}