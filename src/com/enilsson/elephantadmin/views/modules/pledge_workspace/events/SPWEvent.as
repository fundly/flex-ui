package com.enilsson.elephantadmin.views.modules.pledge_workspace.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.views.modules.pledge_workspace.model.PledgeWorkspaceVO;
	
	import flash.events.Event;
	
	import org.osflash.thunderbolt.Logger;

	public class SPWEvent extends CairngormEvent
	{
		static public const ADD_NEW:String 			= 'pledgeworkspace_addnew';
		static public const ADD_EXISTING:String 	= 'pledgeworkspace_addexisting';
		static public const ADD_SHARED:String 		= 'pledgeworkspace_addshared';
		static public const EDIT:String 			= 'pledgeworkspace_edit';
		static public const RESTORE_SAVED:String	= 'pledgeworkspace_restoresaved';

		public var params:PledgeWorkspaceVO;
		
		public function SPWEvent( type:String, params:PledgeWorkspaceVO = null )
		{
			super( type );

			this.params = params ? params : new PledgeWorkspaceVO();
			this.params.action = type;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			var event:SPWEvent =  new SPWEvent(this.type, this.params);
			return event;
		}

		
	}
}