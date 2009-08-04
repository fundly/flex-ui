package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class ExportContactEvent extends CairngormEvent
	{
		static public var EXPORT_CONTACTS:String = 'export_contacts';
		
		public var e:String;
		public var obj:Object;
		
		public function ExportContactEvent(e:String = 'export_contacts', obj:Object  = null)
		{
			super( e , obj );
			
			this.e = e;
			this.obj = obj;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new ExportContactEvent( e , obj);
		}

	}
}