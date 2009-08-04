package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	[RemoteClass(alias="StruktorItemVO")]
	[Bindable]
	public dynamic class StruktorItemVO implements IValueObject
	{
		public var id:Number;
		public var sid:String;

		public var created_on:Number;
		public var created_by_id:Number;
		public var created_by:String;

		public var modified_on:Number;
		public var modified_by_id:Number;
		public var modified_by:String;

		public var mod_e_read:Number;
		public var mod_o_read:Number;
		public var mod_g_read:Number;

		public var mod_e_write:Number;
		public var mod_o_write:Number;
		public var mod_g_write:Number;

		public var mod_group_id:Number;
	}
}