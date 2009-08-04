package com.enilsson.elephanttrakker.events.login
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.vo.LoginVO;
	
	import flash.events.Event;	

	public class LoginEvent extends CairngormEvent
	{
		static public var EVENT_LOGIN:String = 'login';
		static public var EVENT_LOGIN_FORGOT:String = 'forgot';
		
		public var loginAttempt:LoginVO;
		public var e:String;
		
		public function LoginEvent(e:String, loginObj:LoginVO)
		{
			super( e );
			this.e = e;
			this.loginAttempt = loginObj;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new LoginEvent(e, loginAttempt);
		}
		
	}
}