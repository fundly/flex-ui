package com.enilsson.common.components
{
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;

	public class SharedItemGridColumn extends DataGridColumn
	{
		public function SharedItemGridColumn(columnName:String=null)
		{
			super(columnName);
			this.itemRenderer = new ClassFactory( SharedItemGridRenderer );
		}
		
	}
}