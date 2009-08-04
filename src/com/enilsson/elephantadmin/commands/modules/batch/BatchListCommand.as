package com.enilsson.elephantadmin.commands.modules.batch
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.events.modules.batch.BatchListEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.views.modules.batch.renderers.CheckWrapper;
	
	import mx.collections.ArrayCollection;

	public class BatchListCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var e : BatchListEvent = event as BatchListEvent;
			
			switch(e.type) 
			{
				case BatchListEvent.ADD_CHECKS_TO_NEW_BATCH:
					addChecksToCheckBatchList( e.checks );
				break;
				case BatchListEvent.REMOVE_CHECKS_FROM_NEW_BATCH:
					removeChecksFromBatchChecklist( e.checks );
				break;
				case BatchListEvent.MARK_CHECKS_IN_BATCH:
					markChecksInBatch( e.checks, true );
				break;
			}
		}
		
		
		/**
		 * @param checks	Array of CheckListItemWrapper
		 */
		private function addChecksToCheckBatchList( checks : Array ) : void
		{
			// mark the checks to be added as 'inBatch' so any itemRenderer
			// can pick it up
			var checkObjects : Array = [];
			for each( var c : CheckWrapper in checks ) {
				if(! _model.batch.newBatchCheckList.contains(c.check) ) {
					_model.batch.newBatchCheckList.addItem(c.check);
					checkObjects.push( c.check );
				} 
			}
						
			markChecksInBatch( checkObjects, true );
			// Workaround for firing off events to variables in PMs binding to this ArrayCollection
			_model.batch.newBatchCheckList = new ArrayCollection(_model.batch.newBatchCheckList.source);
		}
		
		private function removeChecksFromBatchChecklist( checks : Array )  : void
		{
			if(_model.batch.newBatchCheckList)
			{
				// if checks have been passed, remove only those
				if(checks)
				{
					var list : ArrayCollection = _model.batch.newBatchCheckList;
					
					for each( var checkObject : Object in checks ) {
						
						for( var i : int = 0; i < list.length; i++) {
							if( list[i].id == checkObject.id ) {
								list.removeItemAt(i);
								break;
							}
						}			 
					}
					
					markChecksInBatch( checks, false );
					// Workaround for firing off events to variables in PMs binding to this ArrayCollection
					_model.batch.newBatchCheckList = new ArrayCollection(_model.batch.newBatchCheckList.source);					
				}
				// otherwise remove all the checks
				else {
					_model.batch.newBatchCheckList = new ArrayCollection();
					markAllChecksNotInBatch();
				}
			}			
		}
		
		private function markAllChecksNotInBatch() : void {
			if( _model.batch.checkList ) {
				for each(var w : CheckWrapper in _model.batch.checkList ) {
					w.inBatch = false;
				}
			}
		}
		
		private function markChecksInBatch( checks : Array, setInBatch : Boolean ) : void
		{
			if( checks && _model.batch.checkList )
			{
				for each( var wrapper : CheckWrapper in _model.batch.checkList ) {					
					for each( var c : Object in checks ) {						
						if(c.id == wrapper.check.id) {
							wrapper.inBatch = setInBatch;					
							break;	
						}
					}
				}
			}	
		}
				
		private var _model : EAModelLocator = EAModelLocator.getInstance();		
	}
}