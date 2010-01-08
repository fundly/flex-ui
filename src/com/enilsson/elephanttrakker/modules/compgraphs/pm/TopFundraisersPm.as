package com.enilsson.elephanttrakker.modules.compgraphs.pm
{
	import com.enilsson.common.events.GetEvent;
	import com.enilsson.elephanttrakker.modules.compgraphs.events.Events;
	import com.enilsson.elephanttrakker.modules.compgraphs.views.topfundraisers.components.FundraiserStatsWrapper;
	import com.enilsson.elephanttrakker.modules.compgraphs.views.topfundraisers.components.RankingIconEnum;
	
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class TopFundraisersPm
	{
		public var fundraisersWithIcons : ArrayCollection;
		
		public function set topFundraisers( val :ArrayCollection ) : void { 
			_topFundraisers = val; 
			
			var ac : ArrayCollection = new ArrayCollection();
			
			if( _topFundraisers ) {
				
				for( var i : int = 0; i < val.length; i++ ) {						
					var data : Object = val[i];  
					var icon : Class = null;
					
					switch(i) {
						case 0: icon = RankingIconEnum.FIRST; break;
						case 1: icon = RankingIconEnum.SECOND; break;
						case 2: icon = RankingIconEnum.THIRD; break;
					}
					
					ac.addItemAt( new FundraiserStatsWrapper( data, i+1, icon ), i );
				}
			}
			
			fundraisersWithIcons = ac;
		}
		public function get topFundraisers() : ArrayCollection { return _topFundraisers; }
		private var _topFundraisers : ArrayCollection;
		
		
		public function TopFundraisersPm( dispatcher : IEventDispatcher ) {
			_dispatcher = dispatcher;
			requestFundraisers();
		}
		
		private function requestFundraisers() : void {
			var e : GetEvent = new GetEvent( Events.GET_FUNDRAISER_STATS, this, "topFundraisers" );
			_dispatcher.dispatchEvent( e );
		}
		
		private var _dispatcher : IEventDispatcher;
	}
}