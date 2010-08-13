package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import flash.events.Event;
	
	public class RecordsEvent extends CairngormEvent
	{
		public static const GET_RECORDS 	: String = "getRecords";
		public static const SEARCH_RECORDS 	: String = "searchRecords";
		public static const EXPORT_RECORDS	: String = "exportRecords";
	
		public var e:String;
		public var table:String;
		public var recordsVO:RecordsVO;
		
		public function RecordsEvent(e:String, table:String, vo:RecordsVO)
		{
			super(e);
			this.e = e;
			this.table = table;
			this.recordsVO = vo;
		}
		
		/**
		 * Override clone mehod.
		 */
		override public function clone():Event
		{
			return new RecordsEvent(e, table, recordsVO);
		}
	}
}