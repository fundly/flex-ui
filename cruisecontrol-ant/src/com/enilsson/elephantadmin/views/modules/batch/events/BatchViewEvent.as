package com.enilsson.elephantadmin.views.modules.batch.events
{
	import flash.events.Event;

	public class BatchViewEvent extends Event
	{

		public static const SUCCESS_CREATE_NEW_BATCH:String = "successCreateNewBatch";
		public static const CANCEL_NEW_BATCH:String = "cancelNewBatch";
		public static const CREATE_NEW_BATCH:String = "createNewBatch";
		public static const SAVE_NEW_BATCH:String = "saveNewBatch";
		public static const BATCH_SELECTED:String = "batchSelected";

		public function BatchViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}

}