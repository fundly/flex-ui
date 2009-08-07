package com.enilsson.elephanttrakker.models.viewclasses
{
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Overview module
	 */	
	[Bindable]
	public class OverviewViewClass
	{
		public function OverviewViewClass()
		{
		}
		
		public var viewState:String = '';
		
		// variables for the announcements section
		public var announcements:ArrayCollection;
		public var selectedAnnouncement:Object = { title: 'Loading text...', date: '', description: '' };
		
		// variables for the fundraising chart section
		public var showChart:Boolean = false;
		public var fundraising:ArrayCollection = new ArrayCollection();
		public var chartData:ArrayCollection = new ArrayCollection();
		public var startMonth:int = -1;
		public var endMonth:int = 0;
		public var firstLabel:String = '';
		public var lastLabel:String = '';
		public var newGoalLine:int;
		public var goalLineErrorMsg:Boolean = false;
		public var goalLineProcessing:Boolean = false;
		
		public var isProcessing:Boolean = false;

	}
}