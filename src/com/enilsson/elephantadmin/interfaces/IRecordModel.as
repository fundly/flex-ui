package com.enilsson.elephantadmin.interfaces
{
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModuleConfiguration;
	
	import mx.collections.ArrayCollection;
	import mx.events.ListEvent;
	
	public interface IRecordModel
	{
		function configure( value:RecordModuleConfiguration ):void;

		function set viewState ( value:String ):void;
		function get viewState():String;
		
		function set records ( value:ArrayCollection ):void;
		function get records ():ArrayCollection;

		function set selectedRecord ( value:Object ):void;
		function get selectedRecord ():Object;

		function set formVariables ( value:Object ):void;
		function get formVariables ():Object;

		function set recordID ( value:int ):void;
		function get recordID ():int;

		function set auditTrail ( value:ArrayCollection ):void;
		function get auditTrail ():ArrayCollection;

		// Functions for list navigation and manipulation
		function searchListSelectedIndexChange ( event:ListEvent ):void;
		function clearSearch():void;
		function indexSearch( searchLetter:String ):void;
		function searchRecords( searchTerm:String, searchOption:Object ):void;
		function newPage( selectedPage:int ):void;
	}
}