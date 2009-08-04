package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class RecordEvent extends CairngormEvent
	{
		static public var GET_LAYOUTS:String = 'get_layouts';
		static public var GET_FULL_RECORD:String = 'get_full_record';
		static public var GET_AUDIT_TRAIL:String = 'get_audit_trail';
		static public var GET_DELETED_RECORD:String = 'get_deleted_record';
		static public var UPSERT:String = 'upsert';
		static public var RESTORE:String = 'restore';
		
		public var e:String;
		public var params:Object;
		
		public function RecordEvent( e:String, params:Object=null )
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
			return new RecordEvent(e, params);
		}
	}
}