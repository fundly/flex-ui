package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.LoginVO")]
	public class LoginVO implements IValueObject
	{
		[Bindable] public var email:String;
		[Bindable] public var pwd:String;
		[Bindable] public var captcha:String;
		
		public function LoginVO(email:String, password:String, captcha:String) 
		{
			this.email = email;
			this.pwd = password;
			this.captcha = captcha;
		}
		
		public function toArray():Array
		{
			return new Array(email, pwd, captcha);
		}
		
		public function toString():String
		{
			return email + ',' + pwd + ',' + captcha;
		}

	}
}