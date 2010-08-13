package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[Bindable]
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.PledgeVO")]
	public class PledgeVO implements IValueObject
	{
		public var tr_users_id:Number;
		public var contact:Object = {};
		public var pledge:Object = {};
		public var contribution:Object = {};
	}
}