package com.enilsson.elephantadmin.commands.modules.app_options
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.business.RecordsDelegate;
	import com.enilsson.elephantadmin.events.modules.app_options.GetUsersEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.RecordsVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class GetUsersCommand implements ICommand
	{
		private var _model : EAModelLocator = EAModelLocator.getInstance();
		private var _event : GetUsersEvent;
		
		public function execute(event:CairngormEvent):void {
			
			_event = event as GetUsersEvent;
			if(!_event) return;
			
			if( _event.type == GetUsersEvent.GET_USERS )
				getUsers();
		}
		
		public function getUsers() : void {
			
			var vo : RecordsVO = new RecordsVO( 
				'tr_users<_fid:fname:lname:_show_stats>',
				null,
				'tr_users.lname ASC',
				( _event.currentPage * _model.itemsPerPage ),
				_model.itemsPerPage,
				'P');
				
			var responder : Responder = new Responder( handleGetUsersResult, handleGetUsersFault );
			var delegate : RecordsDelegate = new RecordsDelegate( responder ); 
			delegate.getRecords( vo );
			
			_model.dataLoading = true;
		}
		
		public function handleGetUsersResult( event : ResultEvent ) : void {
			
			var users : ArrayCollection = new ArrayCollection();
						
			for( var i : String in event.result.tr_users) {
				users.addItem( event.result.tr_users[i] ); 
			}
			
			_model.dataLoading = false;
			_model.appOptions.currentUsers 	= users;
			_model.appOptions.totalUsers	= event.result.total_rows;
		}
		public function handleGetUsersFault( event : FaultEvent ) : void {
			_model.dataLoading = false;
		}
	}
}
