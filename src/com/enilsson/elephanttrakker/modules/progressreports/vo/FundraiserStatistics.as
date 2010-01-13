package com.enilsson.elephanttrakker.modules.progressreports.vo
{
	[Bindable]
	[RemoteClass(alias="FundraiserStatistics")] 
	public class FundraiserStatistics
	{
		public var fullname : String;
		public var fid : String;
		public var total_contributed : Number;
		public var users_in_downline : Number;
	}
}