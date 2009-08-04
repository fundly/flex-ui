package com.enilsson.elephantadmin.models.viewclasses
{
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	
	
	[Bindable]
	public class DownlineViewClass
	{
		public function DownlineViewClass()
		{
		}
		
		public var userID:Number;
		
		public var graphShow:Boolean = false;

		public var downlineXML:XML;
		public var graph:Graph;
	}
}