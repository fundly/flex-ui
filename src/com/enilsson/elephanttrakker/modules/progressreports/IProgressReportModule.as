package com.enilsson.elephanttrakker.modules.progressreports
{
	import flash.events.IEventDispatcher;
	
	public interface IProgressReportModule extends IEventDispatcher
	{
		function set gatewayUrl( val : String ) : void;
		function set instanceId( val : int ) : void;
		function update() : void;
	}
}