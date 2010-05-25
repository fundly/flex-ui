package com.enilsson.elephantadmin.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SidForIdEvent extends CairngormEvent
	{
		public static const SID_FOR_ID : String = 'sidForId';
		
		public var table : String;
		public var recordId : int;
		
		public function SidForIdEvent( table : String, recordId : int )
		{
			super( SID_FOR_ID, false, false );
			this.table = table;
			this.recordId = recordId;
		}
		
		override public function clone():Event {
			return new SidForIdEvent( table, recordId );
		}
	}
}