package com.enilsson.elephanttrakker.events.modules.my_history
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class MyHistoryEvent extends CairngormEvent
	{
		static public var EVENT_STATS:String = 'my_history_stats';
		static public var EVENT_DOWNLINE:String = 'my_history_downline';
		static public var EVENT_EXPORT:String = 'my_history_export';
		static public var EVENT_CHART:String = 'my_history_charts';
		static public var GET_TOPDONORS:String = 'get_topdonors';
		static public var DELETE_PLEDGE:String = 'delete_pledge';
		static public var DELETE_SAVED_PLEDGE:String = 'delete_saved_pledge';		
		
		private var e:String;
		public var obj:Object;
		
		public function MyHistoryEvent(e:String = 'my_history_stats', obj:Object = null)
		{
			this.e = e;
			this.obj = obj;
			
			super( e, obj );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new MyHistoryEvent(e, obj);
		}
	}
}