package com.enilsson.elephantadmin.events.modules
{
	import flash.events.Event;

	public class ReportModuleEvent extends Event
	{
		//static public const LOADING_START:String = "moduleStartLoading";
		//static public const LOADING_STOP:String = "moduleStopLoading";

		public function ReportModuleEvent(	type:String, bubbles:Boolean = false,
											cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}


		override public function clone():Event
		{
			return new ReportModuleEvent(type, bubbles, cancelable);
		}
	}
}
