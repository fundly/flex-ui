package com.enilsson.elephanttrakker.modules.progressreports
{
	public interface IProgressReportModule
	{
		function set gatewayUrl( val : String ) : void;
		function set instanceId( val : int ) : void;
	}
}