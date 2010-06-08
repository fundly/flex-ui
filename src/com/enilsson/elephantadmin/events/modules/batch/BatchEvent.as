package com.enilsson.elephantadmin.events.modules.batch
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class BatchEvent extends CairngormEvent
	{
		public static const SAVE_BATCH:String = "batchUpsertBatch";
		public static const SAVE_CHECK:String = "batchUpsertCheck";
		public static const EXPORT_BATCH:String = "batchExportBatch";
		public static const GET_CHECK_LIST:String = "batchGetCheckList";
		public static const GET_BATCH_LIST:String = "batchGetBatchList";
		public static const GET_CHECKS_FOR_BATCH:String = "batchGetChecksForBatch";

		public var callBack:Function;

		public function BatchEvent(type:String, callBack:Function = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.callBack = callBack;
		}

		override public function clone():Event
		{
			return new BatchEvent(type, callBack, bubbles, cancelable);
		}
	}
}