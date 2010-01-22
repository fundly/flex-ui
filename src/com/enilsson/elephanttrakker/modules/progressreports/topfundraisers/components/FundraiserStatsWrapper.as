package com.enilsson.elephanttrakker.modules.progressreports.topfundraisers.components
{
	[Bindable]
	public class FundraiserStatsWrapper
	{
		public var data : Object;
		public var position : int;
		public var icon : Class;
		
		public function FundraiserStatsWrapper( data : Object, position : int, icon : Class = null ) {
			this.data = data;
			this.position = position;
			this.icon = icon;
		}

	}
}