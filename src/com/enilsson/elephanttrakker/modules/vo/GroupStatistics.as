package com.enilsson.elephanttrakker.modules.vo
{
	[Bindable]
	[RemoteClass(alias="GroupStatistics")] 
	public class GroupStatistics
	{
		public var name : String;
		public var number_pledges : Number;
		public var total_pledged : Number;
		public var number_contributions : Number;
		public var total_contributed : Number;
	}
}