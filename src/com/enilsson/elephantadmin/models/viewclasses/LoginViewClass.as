package com.enilsson.elephantadmin.models.viewclasses
{
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	
	
	/**
	 * A collection of data for the Login View screen
	 */
	[Bindable]
	public class LoginViewClass
	{
		public function LoginViewClass()
		{
		}
		
		public var loginScreen:DisplayObject;
		
		public var loginProcessing:Boolean = false;
		
		// login form variables
		public var loginEmail:String = '';
		public var loginPwd:String = '';
		public var loginFormState:String = 'Default';		

		// Login error message variables
		public var loginErrorVisible:Boolean = false;
		public var loginErrorStyle:String = 'errorBox';
		public var loginErrorMessage:String = 'Error Message';
		
		// Captcha variables
		public var captchaVisible:Boolean = false;
		public var captchaData:ByteArray = new ByteArray();

		// forgot details variables
		public var forgotErrorVisible:Boolean = false;
		public var forgotErrorStyle:String = 'errorBox';
		public var forgotErrorMessage:String = 'Error Message';

	}
}