package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class ReportingEvent extends CairngormEvent
	{
		static public var REPORTING_LAYOUT:String = 'reporting_layout';
		static public var REPORTING_RECORDS:String = 'reporting_records';
		static public var REPORTING_RECORD:String = 'reporting_record';
		static public var REPORTING_SEARCH:String = 'reporting_search';
		static public var REPORTING_UPSERT:String = 'reporting_upsert';
		static public var REPORTING_DELETE:String = 'reporting_delete';
		static public var REPORTING_ACTIVITY:String = 'reporting_activity';
		static public var RECORDS_LOADED:String = 'reporting_records_loaded';
		static public var SHOW_RECORD:String = 'reportingShowRecord';
		
		public var e:String;
		public var params:Object
		public var recordID:int;
		public var moduleName:String;
		
		public function ReportingEvent(e:String, params:Object=null, moduleName:String = null, recordID:int = 0)
		{
			super( e );
			this.e = e;
			this.params = params;
			this.moduleName = moduleName;
			this.recordID = recordID;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new ReportingEvent(e, params);
		}
				
	}
}