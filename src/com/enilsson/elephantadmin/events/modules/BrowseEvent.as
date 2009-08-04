package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class BrowseEvent extends CairngormEvent
	{
		static public var RECORDS:String = 'browse_records';
		static public var SEARCH:String = 'browse_search';
		static public var EXPORT:String = 'browse_export';

		public var e:String;
		public var params:Object

		public function BrowseEvent(e:String, params:Object=null)
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
			return new BrowseEvent(e, params);
		}
				
	}
}