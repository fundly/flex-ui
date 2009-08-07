package com.enilsson.elephantadmin.views.modules.search
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class SearchResult
	{
		
		public var totalRecords			: int 		= 0;
		public var page					: ArrayCollection = new ArrayCollection();
		
		public function clear() : void
		{
			totalRecords = 0;
			page.removeAll();
		}
	}
}