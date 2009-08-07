package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class NewsEvent extends CairngormEvent
	{
		static public var NEWS_LAYOUT:String = 'news_layout';
		static public var NEWS_RECORDS:String = 'news_records';
		static public var NEWS_RECORD:String = 'news_record';
		static public var NEWS_SEARCH:String = 'news_search';
		static public var NEWS_UPSERT:String = 'news_upsert';
		static public var NEWS_DELETE:String = 'news_delete';
		static public var NEWS_ACTIVITY:String = 'news_activity';
		static public var NEWS_EXPORT:String = 'news_export';
		
		public var e:String;
		public var params:Object
		
		public function NewsEvent(e:String, params:Object=null)
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
			return new NewsEvent(e, params);
		}
				
	}
}