package com.enilsson.elephanttrakker.modules.compgraphs.business
{
	import mx.rpc.AsyncToken;

	public class CompGraphDelegate implements ICompGraphsDelegate
	{
		public function CompGraphDelegate( service : Object ) : void {
			_service = service;
		}
			
		public function getFundraiserStats() : AsyncToken {
			return _service.fundraiser_competition();
		}
		
		public function getGroupStats() : AsyncToken {
			return _service.group_competition();
		}
		
		private var _service : Object;
		
	}
}