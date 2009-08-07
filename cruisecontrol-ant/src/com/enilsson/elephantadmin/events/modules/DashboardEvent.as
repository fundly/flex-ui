package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	import com.enilsson.elephantadmin.vo.SearchVO;
	
	import flash.events.Event;
	
	import mx.rpc.Responder;

	public class DashboardEvent extends CairngormEvent
	{
		static public var GET_LATEST_PLEDGES:String = 'dashboardGetLatestPledges';
		static public var GET_ACTIVE_USERS:String = 'dashboardGetActiveUsers';
		static public var SEARCH_EVENTS:String = 'dashboardSearchEvents';
		static public var GET_EVENT_STATS:String = 'dashboardGetEventStats';
		static public var GET_EVENT:String = 'dashboardGetEvent';

		public var responder:Responder;
		public var recordsVO:RecordsVO;
		public var recordVO:RecordVO;
		public var searchVO:SearchVO;

		public function DashboardEvent(type:String, responder:Responder)
		{
			super( type );
			this.responder = responder;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new DashboardEvent(type, responder);
		}
	}
}