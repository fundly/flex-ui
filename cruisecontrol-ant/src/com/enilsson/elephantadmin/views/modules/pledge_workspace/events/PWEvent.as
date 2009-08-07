package com.enilsson.elephantadmin.views.modules.pledge_workspace.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.model.PledgeWorkspaceModel;
	
	import flash.events.Event;
	
	import org.osflash.thunderbolt.Logger;

	public class PWEvent extends CairngormEvent
	{
		static public const GET_CONTACT:String 			= 'pwe_getcontactdata';
		static public const GET_PLEDGE:String 			= 'pwe_getpledgedata';
		static public const SAVE:String	 				= 'pwe_save';
		static public const LOOKUP_INPUT_SEARCH:String 	= 'pwe_lookupinputsearch';
		static public const GET_LABEL:String			= 'pwe_getlabel';
		static public const DO_TRANSACTION:String 		= 'pwe_dotransaction';
		static public const SEND_EMAIL:String 			= 'pwe_sendemail';
		static public const DUP_SEARCH:String 			= 'pwe_dupsearch';
		static public const DELETE_SAVED_PLEDGE:String 	= 'pwe_delsavedpledge';
		
		public var e:String;
		public var model:PledgeWorkspaceModel;
		public var params:Object;
		
		public function PWEvent( e:String, model:PledgeWorkspaceModel, params:Object = null )
		{
			super( e );

 			this.e = e;
			this.model = model;
			this.params = params;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			var event:PWEvent =  new PWEvent( e, model, params );
			return event;
		}
	}
}