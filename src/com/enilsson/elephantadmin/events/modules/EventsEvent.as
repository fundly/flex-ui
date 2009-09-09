package com.enilsson.elephantadmin.events.modules
{
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	
	import flash.events.Event;

	public class EventsEvent extends RecordModuleEvent
	{
		static public var DELETE:String = 'events_delete';
		static public var EXPORT:String = 'events_export';
		static public var GET_HOSTS:String = 'events_hosts';
		static public var GET_PLEDGES:String = 'events_pledges';
		static public var LOOKUP_SEARCH:String = 'events_lookupsearch';
		static public var UPSERT_HOST_RECORD:String = 'events_upserthost';
		static public var DELETE_HOST_RECORD:String = 'events_deletehost';

		public function EventsEvent( type:String, model:RecordModel, vo:Object = null )
		{
			super( type , model , vo);
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return PledgeEvent(super.clone());
		}
	}
}