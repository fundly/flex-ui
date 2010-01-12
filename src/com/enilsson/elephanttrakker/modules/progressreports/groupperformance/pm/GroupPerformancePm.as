package com.enilsson.elephanttrakker.modules.progressreports.groupperformance.pm
{
	import com.enilsson.common.events.GetEvent;
	import com.enilsson.elephanttrakker.modules.progressreports.events.Events;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class GroupPerformancePm
	{
		public function set groupStats( val : ArrayCollection ) : void {
			_groupStats = val; 
		}
		public function get groupStats() : ArrayCollection {
			return _groupStats;		
		}
		private var _groupStats : ArrayCollection;
		
		public function GroupPerformancePm( dispatcher : IEventDispatcher )
		{
			_dispatcher = dispatcher;
			requestGroupStats();
		}
		
		private function requestGroupStats() : void {
			var e : GetEvent = new GetEvent( Events.GET_GROUP_STATS, this, "groupStats" );
			_dispatcher.dispatchEvent( e );
		}
		
		private var _dispatcher : IEventDispatcher;
	}
}