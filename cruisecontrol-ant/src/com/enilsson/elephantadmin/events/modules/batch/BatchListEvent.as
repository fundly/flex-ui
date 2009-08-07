package com.enilsson.elephantadmin.events.modules.batch
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class BatchListEvent extends CairngormEvent
	{
		public static const ADD_CHECKS_TO_NEW_BATCH 		: String = "addChecksToBatch";
		public static const REMOVE_CHECKS_FROM_NEW_BATCH	: String = "removeChecksFromBatch";
		public static const MARK_CHECKS_IN_BATCH			: String = "markChecksInBatch";
		
		// an Array of Check objects
		public var checks : Array;
		
		public function BatchListEvent(type:String, checks:Array=null)
		{
			super(type, bubbles, cancelable);
			this.checks = checks;
		}

		override public function clone():Event
		{
			return new BatchListEvent(type, checks);
		}
	}
}