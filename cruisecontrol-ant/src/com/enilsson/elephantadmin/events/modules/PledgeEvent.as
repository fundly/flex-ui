package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.vo.IValueObject;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	
	import flash.events.Event;

	public class PledgeEvent extends RecordModuleEvent
	{
		static public const GET_CONTRIBUTIONS:String = 'pledgeGetContributions';
		static public const LOOKUPINPUT_SEARCH:String = 'pledgeLookupInputSearch';
		static public const GET_LABEL:String = 'pledgeGetLabel';
		static public const UPSERT_CHECKREFUND:String = 'upsertCheckRefund';
		static public const DELETE_CHECKREFUND:String = 'deleteCheckRefund';

		public function PledgeEvent( type:String, model:RecordModel, vo:Object = null )
		{
			super( type , model , vo);
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return PledgeEvent(super.clone());
		}
	}
}