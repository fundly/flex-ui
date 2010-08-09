package com.enilsson.elephanttrakker.modules.business
{
	import mx.rpc.AsyncToken;
	
	public interface IProgressReportsDelegate
	{
		function getTopFundraisers() : AsyncToken;
		function getTopFundraisersByDownlineContributions() : AsyncToken;
		function getTopFundraisersByDownlineUsers() : AsyncToken;
		
		function getGroupStats() : AsyncToken;
	}
}