package com.enilsson.elephantadmin.views.modules.batch.renderers
{
	[Bindable]
	public class CheckWrapper
	{
		public var inBatch : Boolean;
		public var check : Object;
		
		public function CheckWrapper( check : Object )
		{
			this.check = check;
		}

	}
}