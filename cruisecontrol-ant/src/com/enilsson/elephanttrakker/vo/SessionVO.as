package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.SessionVO")]
	public class SessionVO implements IValueObject
	{
		public function SessionVO(data:Object)
		{
			this.data = data;
			this.fname = data.fname;
			this.lname = data.lname;
			this.fullname = data.fname + ' ' + data.lname;
			this.email = data.email;
			this.user_id = data.user_id;
			this.phone = data._phone;
			this.firstlogin = data._firstlogin;
			this.acl = data.acl;
			this.groups = data.groups;
		}
		
		[Bindable] public var data:Object;
		[Bindable] public var fname:String;
		[Bindable] public var lname:String;
		[Bindable] public var fullname:String;
		[Bindable] public var email:String;
		[Bindable] public var user_id:Number;
		[Bindable] public var phone:String;
		[Bindable] public var firstlogin:Number;
		[Bindable] public var acl:Object;
		[Bindable] public var groups:Object;
		
	}
}