package com.enilsson.elephantadmin.vo
{
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.enilsson.elephantadmin.vo.SessionVO")]
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
			this.acl = data.acl;
			this.admin_acl = data.admin_acl;
			this.groups = data.groups;
			
			if(data.ui_access) {
				this.uiAccess = data.ui_access as UIAccessVO;
			}
			else {
				this.uiAccess = new UIAccessVO();
			}
		}
		
		public var data:Object;
		public var fname:String;		
		public var lname:String;
		public var fullname:String;
		public var email:String;
		public var user_id:uint;
		public var phone:String;
		public var acl:Object;
		public var admin_acl:Object;
		public var groups:Object;
		public var uiAccess:UIAccessVO;
	}
}