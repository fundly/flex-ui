package com.enilsson.elephanttrakker.modules.progressreports.business
{
	import mx.rpc.AsyncToken;

	public class ProgressReportsDelegate implements IProgressReportsDelegate
	{
		public function ProgressReportsDelegate( service : Object ) : void {
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