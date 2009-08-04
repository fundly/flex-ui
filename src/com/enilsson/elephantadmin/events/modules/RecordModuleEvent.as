package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	import com.enilsson.elephantadmin.vo.RecordVO;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	import com.enilsson.elephantadmin.vo.SearchVO;

	import flash.events.Event;

	public class RecordModuleEvent extends CairngormEvent
	{
		static public const GET_RECORDS:String = 'recordModuleGetRecords';
		static public const GET_FULL_RECORD:String = 'recordModuleGetFullRecord';
		static public const GET_AUDIT_TRAIL:String = 'recordModuleGetAuditTrail';
		static public const GET_DELETED_RECORD:String = 'recordModuleGetDeletedRecord';
		static public const SEARCH_RECORDS:String = 'recordModuleSearchRecords';
		static public const UPSERT:String = 'recordModuleUpsert';
		static public const DELETE:String = 'recordModuleDelete';
		static public const RESTORE:String = 'recordModuleRestore';

		public var model:RecordModel;

		public var recordVO:RecordVO;
		public var recordsVO:RecordsVO;
		public var searchVO:SearchVO;
		public var params:Object;

		public function RecordModuleEvent( type:String, model:RecordModel, vo:Object = null )
		{
			super( type );

			// Sets the model the command should access
			this.model = model;

			// Sets the VO of event according to the type of received VO
			// If unknown VO, it is saved as generic object "params"
			if(vo is RecordVO)
				this.recordVO = RecordVO(vo);
			else if(vo is RecordsVO)
				this.recordsVO = RecordsVO(vo);
			else if(vo is SearchVO)
				this.searchVO = SearchVO(vo);
			else 
				this.params = vo;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			var event:RecordModuleEvent =  new RecordModuleEvent(this.type, this.model);
			event.recordsVO = this.recordsVO;
			event.recordVO = this.recordVO;
			event.searchVO = this.searchVO;
			event.params = this.params;

			return event;
		}
	}
}