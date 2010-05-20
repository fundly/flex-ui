package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	
	[Bindable]
	public class MyHistoryViewClass
	{
		public function MyHistoryViewClass()
		{
		}
		
		public var numPledges:int = 0;
		public var numContribs:int = 0;
		public var numCheckContribs:int = 0;
		public var numSavedCalls:int = 0;
		
		public var vStackViewState:int = 0;
		public var initQuickStats : Boolean = true;
		public var initPledges : Boolean = true;
		public var initSavedCalls : Boolean = true;
		public var initExport : Boolean = true;
		public var initContributions : Boolean = true;

		public var pledges:ArrayCollection;
		public var transactions:ArrayCollection;
		public var checks:ArrayCollection;
		public var contributions:ArrayCollection;
		public var user_storage:ArrayCollection;
		public var isSorting:Boolean = false;
		
		// quick stats
		public var quickstats_chart:Object;
		
		public var numDonors:int = 0;
		public var totalPledged:Number = 0;
		public var totalContribs:int = 0;
		public var avPerDonor:Number = 0;
		public var downline:Number = 0;
		
		public var topDonors:Object;
		
		// variables to gate the my history data
		public var startDate:Date;
		public var endDate:Date;
		
		public var errorVO:ErrorVO;
		public var lastQuery:CairngormEvent;
		public var lastSavedQuery:CairngormEvent;
		
		public var exportTable:String;
	}
}