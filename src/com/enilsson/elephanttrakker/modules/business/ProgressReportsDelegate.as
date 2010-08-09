package com.enilsson.elephanttrakker.modules.business
{
	import mx.rpc.AsyncToken;

	public class ProgressReportsDelegate implements IProgressReportsDelegate
	{
		public function ProgressReportsDelegate( service : Object ) : void {
			_service = service;
		}
			
		public function getTopFundraisers() : AsyncToken {
			return _service.top_fundraisers();
		}
		
		public function getTopFundraisersByDownlineContributions() : AsyncToken {
			return _service.top_fundraisers_downline_contributions();
		}
		
		public function getTopFundraisersByDownlineUsers() : AsyncToken {
			return _service.top_fundraisers_downline_users();
		}
		
		public function getGroupStats() : AsyncToken {
			return _service.group_competition();
		}
		
		private var _service : Object;
	}
}