package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	
	/**
	 * A collection of data for the My Downline module
	 */	
	[Bindable]	
	public class MyDownlineViewClass
	{
		public var errorVO:ErrorVO;
		
		public var gettingDownline:Boolean = false;
		
		public var graphShow:Boolean = false;
		public var downlineXML:XML;
		public var graph:Graph;
		public var isEmpty:Boolean = false;
		
		public var parentGraphShow:Boolean = false;
		public var parentXML:XML;
		public var parentGraph:Graph;
		public var isParentsEmpty:Boolean = false;		

	}
}