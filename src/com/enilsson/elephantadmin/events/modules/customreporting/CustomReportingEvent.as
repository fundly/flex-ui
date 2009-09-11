package com.enilsson.elephantadmin.events.modules.customreporting
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class CustomReportingEvent extends CairngormEvent
	{
		public static const SAVE_REPORT:String = "customReportSave";
		public static const LOAD_REPORT:String = "customReportLoad";
		public static const EXPORT_REPORT:String = "customReportExport";
		public static const GET_REPORTS:String = "customReportGetReports";
		public static const GET_RELATIONS:String = "customReportGetRelations";
		public static const GET_SCHEMA:String = "customReportGetSchema";

		public var callBack:Function;
		public var reportID:int;

		public function CustomReportingEvent(type:String, callBack:Function = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.callBack = callBack;
		}

		override public function clone():Event
		{
			var newEvent:CustomReportingEvent = new CustomReportingEvent(type, callBack, bubbles, cancelable);
			newEvent.reportID = this.reportID;

			return newEvent;
		}
	}
}