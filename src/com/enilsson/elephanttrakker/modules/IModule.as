package com.enilsson.elephanttrakker.modules
{
	import flash.events.IEventDispatcher;
	
	public interface IModule extends IEventDispatcher
	{
		function set gatewayUrl( val : String ) : void;
		function update() : void;
	}
}