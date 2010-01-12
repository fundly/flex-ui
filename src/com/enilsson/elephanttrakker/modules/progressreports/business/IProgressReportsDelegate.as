package com.enilsson.elephanttrakker.modules.progressreports.business
{
	import mx.rpc.AsyncToken;
	
	public interface IProgressReportsDelegate
	{
		function getFundraiserStats() : AsyncToken;
		function getGroupStats() : AsyncToken;
	}
}