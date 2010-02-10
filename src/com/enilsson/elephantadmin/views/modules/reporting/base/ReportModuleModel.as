package com.enilsson.elephantadmin.views.modules.reporting.base
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.DataGridEvent;
	import mx.managers.CursorManager;
	
	[Bindable]
	public class ReportModuleModel
	{
		public static const FILTER_NONE				: int = -1;
		public static const FILTER_ALL				: int = 0;
		public static const FILTER_CC 				: int = 1;
		public static const FILTER_CHECK			: int = 2;
		public static const FILTER_PAYPAL			: int = 3;
		public static const FILTER_DONATION_WIDGET	: int = 4;

		public var allGroups:ArrayCollection;
		public var userGroups:Array;
		public var itemsPerPage:int
		public var gatewayURL:String
		public var gatewayBaseURL:String;
		public var instanceID:int;
		public var recordID:int;
		
		public function ReportModuleModel() {
			filter = ReportModuleModel.FILTER_ALL;
		}

		public function set dataLoading(value:Boolean):void
		{
			_dataLoading = value;

			if(value)
				CursorManager.setBusyCursor();
			else
				CursorManager.removeBusyCursor();
		}
		private var _dataLoading:Boolean;
		public function get dataLoading():Boolean
		{
			return _dataLoading;
		}
		public var searching:Boolean;
		public var exporting:Boolean;
		public var timezoneOffset:int;

		public var gridRecords:ArrayCollection;
		public var gridSelectedItem:Object;
		public var gridCurrentPage:int;
		public var gridTotalRecords:int;
		public var gridSearchTerm:String;

		public var group:int	= 0;
		
		public function set filter( value : int ) : void { _filter = value; }
		public function get filter() : int { return _filter; }
		private var _filter : int = FILTER_NONE;

		public function init():void
		{
			timezoneOffset = new Date().getTimezoneOffset() * 60;
		}

		public function generate():void
		{
			dataLoading = true;
		}

		public function export():void
		{
			exporting = true;
		}

		public function exportGrid(columns:Array):void
		{
			exporting = true;
		}

		public function newPage(event:Event):void
		{
			gridCurrentPage = event.currentTarget.selectedPage;
		}

		public function sortRecords(event:DataGridEvent):void
		{
			
		}
		
		public function generateFirstPage() : void {
			gridCurrentPage = 0;
			generate();
		}
	}
}