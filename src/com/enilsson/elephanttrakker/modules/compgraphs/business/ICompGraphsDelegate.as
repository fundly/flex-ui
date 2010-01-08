package com.enilsson.elephanttrakker.modules.compgraphs.business
{
	import mx.rpc.AsyncToken;
	
	public interface ICompGraphsDelegate
	{
		function getFundraiserStats() : AsyncToken;
		function getGroupStats() : AsyncToken;
	}
}