package com.enilsson.elephanttrakker.events.modules.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class EventsEvent extends CairngormEvent
	{
		static public var EVENT_GET_EVENTS:String = 'get_events';
		static public var EVENT_SEARCH_EVENTS:String = 'search_events';
		static public var EVENT_ATTEND_EVENT:String = 'attend_event';
		static public var EVENT_SEARCH_CONTACTS:String = 'events_search_contacts';
		static public var EVENT_SEARCH:String = 'event_search_all';
		
		public var e:String;
		public var obj:Object;
		
		public function EventsEvent(e:String, obj:Object = null)
		{
			super( e );
			
			this.e = e;
			this.obj = obj;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new EventsEvent(e, obj);
		}
		
	}
}