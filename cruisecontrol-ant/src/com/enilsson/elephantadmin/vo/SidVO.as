package com.enilsson.elephantadmin.vo
{
	[Bindable]
	public class SidVO
	{
		public function SidVO( result:Object )
		{
			this.table_name = result.table_name;
			
			if(result.hasOwnProperty(this.table_name))
				this.data = result[this.table_name]['1'];
			else
				this.empty = true;
		}
		
		public var data:Object;
		public var table_name:String;
		public var empty:Boolean = false;
	}
}