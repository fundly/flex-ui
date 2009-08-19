package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	public class UserVO implements IValueObject
	{
		public var id:int;
		public var email:String;
		public var fname:String;
		public var lname:String;
		public var address1:String;
		public var address2:String;
		public var city:String;
		public var state:String;
		public var zip:String;
		public var phone:String;
		public var goal:String;
	}
}