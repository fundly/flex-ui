package com.enilsson.elephantadmin.views.modules.reporting.base
{
	[RemoteClass(alias="reporting.ReportVO")]
	public class ReportVO
	{
		public var startTime:int;
		public var endTime:int;
		
		public var sortBy:String;
		public var recordPerPage:int;
		public var page:int;
		public var showRefunds:Boolean;
		public var showSharedCredit:Boolean;
	
		public var filter:int;

		public var groupID:int;
		public var eventID:int;
		public var pledgeID:int;
		public var userID:int;
		public var batchID:int;

		public var export:Boolean;
		public var exportTitle:String;
		public var exportHeaders:Array = [];
		public var exportFields:Array = [];
		public var exportTimeOffset:int;
		public var exportData:Object = {};
	}
}