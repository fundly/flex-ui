package com.enilsson.elephanttrakker.modules.progressreports.topfundraisers.pm
{
	import com.enilsson.common.events.GetEvent;
	import com.enilsson.elephanttrakker.modules.progressreports.events.Events;
	import com.enilsson.elephanttrakker.modules.progressreports.topfundraisers.components.FundraiserStatsWrapper;
	import com.enilsson.elephanttrakker.modules.progressreports.topfundraisers.components.RankingIconEnum;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class TopFundraisersPm
	{
		public var fundraisersWithIcons : ArrayCollection = new ArrayCollection();
		
		
		public static const OPTIONS : ArrayCollection = new ArrayCollection([
			{ label:'contributions', eventType:Events.GET_FUNDRAISER_STATS },
			{ label:'downline contributions', eventType:Events.GET_FUNDRAISER_STATS },
			{ label:'number of downline members', eventType:Events.GET_FUNDRAISER_STATS }
		]);
		
				
		
		public function set topFundraisers( val :ArrayCollection ) : void { 
			_topFundraisers = val; 
			
			fundraisersWithIcons.removeAll();
			
			if( _topFundraisers ) {
				
				for( var i : int = 0; i < val.length; i++ ) {						
					var data : Object = val[i];  
					var icon : Class = null;
					
					switch(i) {
						case 0: icon = RankingIconEnum.FIRST; break;
						case 1: icon = RankingIconEnum.SECOND; break;
						case 2: icon = RankingIconEnum.THIRD; break;
					}
					
					fundraisersWithIcons.addItemAt( new FundraiserStatsWrapper( data, i+1, icon ), i );
				}
			}
		}
		public function get topFundraisers() : ArrayCollection { return _topFundraisers; }
		private var _topFundraisers : ArrayCollection;		
		
		public function handleOptionChange( event : Event ) : void {
			
			var item : Object = event.currentTarget.selectedItem;
			if(! item)
				item = event.currentTarget.selectedItem = OPTIONS.getItemAt(0);
			
			dispatchGetEvent( item.eventType );
		}
		
		public function TopFundraisersPm( dispatcher : IEventDispatcher ) {
			_dispatcher = dispatcher;
			dispatchGetEvent( OPTIONS.getItemAt(0).eventType );
		}
		
		private function dispatchGetEvent( eventType : String ) : void {
			var e : GetEvent = new GetEvent( eventType, this, "topFundraisers" );
			_dispatcher.dispatchEvent( e );
		}
		
		private var _dispatcher : IEventDispatcher;
	}
}