package com.enilsson.elephanttrakker.events.modules.call_logging
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.vo.RecordVO;
	
	import flash.events.Event;

	public class CallLoggingRecordEvent extends CairngormEvent
	{
		static public var EVENT_RECORD:String = 'record';
		
		public var record:RecordVO;
		
		public function CallLoggingRecordEvent(record:RecordVO)
		{
			super( EVENT_RECORD );
			
			this.record = record;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new CallLoggingRecordEvent(record);
		}
	}
}