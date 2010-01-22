package com.enilsson.elephantadmin.views.modules.app_options.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class AppOptionsModel 
	{
		public var siteOptions : ArrayCollection;
		
		// the users displayed on the Progress Report Modules screen 
		public var currentUsers : ArrayCollection;
		public var totalUsers 	: int;
	}
}