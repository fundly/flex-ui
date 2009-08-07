package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.vo.StruktorItemVO;
	
	import flash.events.Event;

	public class ChecksEvent extends CairngormEvent
	{
		static public var LAYOUT:String = 'checks_layout';
		static public var RECORD:String = 'checks_record';
		static public var RECORDS:String = 'checks_records';
		static public var SEARCH:String = 'checks_search';
		static public var UPSERT:String = 'checks_upsert';
		static public var UPSERT_MULTIPLE:String = 'checks_upsertMultiple';
		static public var DELETE:String = 'checks_delete';
		static public var VALIDATE:String = 'checks_validate';

		public var e:String;
		public var params:Object
		public var struktorVO:StruktorItemVO

		public function ChecksEvent(e:String, params:Object=null)
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
			return new ChecksEvent(e, params);
		}
				
	}
}