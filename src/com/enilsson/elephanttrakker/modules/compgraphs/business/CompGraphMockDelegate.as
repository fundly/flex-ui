package com.enilsson.elephanttrakker.modules.compgraphs.business
{
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.mx_internal;
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;	
	use namespace mx_internal;
	
	public class CompGraphMockDelegate implements ICompGraphsDelegate
	{
		private var _token : AsyncToken;
		
		public function getFundraiserStats() : AsyncToken {
			
			var t : AsyncToken = new AsyncToken( new RemotingMessage() );			
			setTimeout( generateFundraiserStatsResult, 1000, t);
			return t;
		}
		
		public function generateFundraiserStatsResult( token : AsyncToken ) : void {
			var response : ArrayCollection = new ArrayCollection
			([
				{firstName:"Aaaaaa",lastName:"Bbbbbbb", raised:100},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:200},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:300},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:400},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:500},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:600},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:700},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:800},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:900},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1000},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1100},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1200},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1300},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1400},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1500},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1600},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1700},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1800},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:1900},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:2000},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:2100},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:2200},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:2300},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:2400},
				{firstName:"Bbbbbb",lastName:"Ccccccc", raised:2500}				
			]);
			
			var e : ResultEvent = ResultEvent.createEvent( response, token );
			token.applyResult(e);
		}
		
		public function generateFundraiserStatsFault( token : AsyncToken ) : void {
			var e : FaultEvent = FaultEvent.createEvent( new Fault("CompGraphMockDelegate Fault", "fault"), token );
			token.applyFault( e );			
		}
		
		public function getGroupStats() : AsyncToken {
			return null;
		}
		
		public function generateGroupStatsResult() : void {
			
		}
	}
}