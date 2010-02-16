package com.enilsson.elephantadmin.vo
{
	[Bindable]
	[RemoteClass(alias="admin.UIAccessVO")]
	public class UIAccessVO
	{
		public var dataExport		: Boolean;
		public var recordWrite		: Boolean;
		public var reportingAccess	: Boolean;
		public var reportingExport	: Boolean;
		
		public function allowAll() : void { setAll( true ); }
		public function denyAll() : void { setAll( false );	}
		
		private function setAll( value : Boolean ) : void {
			dataExport = value;
			recordWrite = value;
			reportingAccess = value;
			reportingExport = value;
		}
	}
}