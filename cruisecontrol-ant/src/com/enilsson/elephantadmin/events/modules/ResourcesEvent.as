package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class ResourcesEvent extends CairngormEvent
	{
		static public var RESOURCES_LAYOUT:String = 'resources_layout';
		static public var RESOURCES_RECORDS:String = 'resources_records';
		static public var RESOURCES_RECORD:String = 'resources_record';
		static public var RESOURCES_SEARCH:String = 'resources_search';
		static public var RESOURCES_UPSERT:String = 'resources_upsert';
		static public var RESOURCES_DELETE:String = 'resources_delete';
		static public var RESOURCES_ACTIVITY:String = 'resources_activity';
		static public var RESOURCES_EXPORT:String = 'resources_export';
		
		public var e:String;
		public var params:Object
		
		public function ResourcesEvent(e:String, params:Object=null)
		{
			super( e );
			this.e = e;
			this.params = params;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new ResourcesEvent(e, params);
		}
				
	}
}