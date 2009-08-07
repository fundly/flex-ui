package com.enilsson.elephantadmin.interfaces
{
	import mx.collections.ArrayCollection;
	import mx.core.IUIComponent;
	
	public interface IReportModule extends IUIComponent
	{
		function set gatewayURL( value:String ) : void;

		function set itemsPerPage( value:int ) : void;

		function set allGroups( value:ArrayCollection ):void;
		function set userGroups( value:Array ):void;

		function set instanceID( value:int ):void;

		function set dataLoading( value:Boolean ) : void;
		function get dataLoading():Boolean;

		function set recordID(value:int):void;
		function get recordID():int;
	}
}