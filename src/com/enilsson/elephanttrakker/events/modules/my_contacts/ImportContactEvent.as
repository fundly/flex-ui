package com.enilsson.elephanttrakker.events.modules.my_contacts
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class ImportContactEvent extends CairngormEvent
	{
		static public var IMPORT_CONTACTS:String = 'import_contacts';
		static public var FETCH_CONTACTS:String = 'fetch_contacts';
		static public var CONTACTS_IMPORTED:String = 'contacts_imported';
		static public var DELETE_IMPORTED:String = 'delete_imported';
		
		
		public var e:String;
		public var obj:Object;
		
		public function ImportContactEvent(e:String = 'fetch_contacts', obj:Object  = null)
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
			return new ImportContactEvent( e , obj);
		}

	}
}