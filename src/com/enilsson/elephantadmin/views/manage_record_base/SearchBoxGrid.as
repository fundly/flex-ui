package com.enilsson.elephantadmin.views.manage_record_base
{
	import mx.controls.DataGrid;

	public class SearchBoxGrid extends DataGrid
	{
		public function get gridListItems() : Array { 
			return this.listItems;
		} 		
	}
}