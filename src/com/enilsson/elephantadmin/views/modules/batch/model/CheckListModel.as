package com.enilsson.elephantadmin.views.modules.batch.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.enilsson.elephantadmin.events.modules.batch.BatchEvent;
	import com.enilsson.elephantadmin.events.modules.batch.BatchListEvent;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.events.PaginatorEvent;
	
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class CheckListModel extends AbstractPM
	{
		public static const ORDER_FIELDS :  Array = [
			{ label: 'Amount', value: 'checks.amount' },
			{ label: 'Pledge Date', value: 'checks__pledge_id.pledge_date' },
			{ label: 'Full Name', value: 'checks.full_name' }
		];
		
		public static const SORT_OPTIONS : Array = [ 
			{label: 'Descending', value:'DESC'},
			{label: 'Ascending', value:'ASC'} 
		];
		
		public static const SEARCH_OPTIONS : Array = [
			{label: 'FULL NAME', value:'checks.full_name', type:'any'},
			{label: 'AMOUNT', value: 'checks.amount', type:'exact'}
		]
		
		public var checkListTotal:int;
		public var checkListLoading:Boolean;

		[Bindable(event="updateTitle")]
		public function get title():String
		{
			var plural:String = checkListTotal > 1 ? 's' : '';
			var title:String;

			if(checkListTotal < itemsPerPage)
			{
				title = checkListTotal + ' check' + plural;
			}
			else
			{
				var startIndex:String = (_model.batch.checkListFrom + 1).toString();
				var toIndex:int =  _model.batch.checkListFrom + itemsPerPage;
				var toIndexString:String = toIndex < checkListTotal ? toIndex.toString() : checkListTotal.toString();
				
				title = startIndex;
				title += '-' + toIndexString;
				title += ' of ' + checkListTotal + ' check' + plural;
			}
			return title;
		}

		// List of unfulfilled check contributions
		public var checkList:ArrayCollection = new ArrayCollection();

		public function CheckListModel( domainModel : EAModelLocator ):void
		{
			super( domainModel );
		}

		override public function set domainModel(domainModel:IModelLocator):void
		{
			_model = EAModelLocator( domainModel );
			super.domainModel = domainModel;
		}

		public function get itemsPerPage() : Number {
			return _model.itemsPerPage;
		}

		public function getCheckList(event:PaginatorEvent = null):void
		{
			if(event) {
				_model.batch.checkListFrom = event.index * itemsPerPage;
			} else {
				_model.batch.checkListFrom = 0;
			}
			new BatchEvent(BatchEvent.GET_CHECK_LIST).dispatch();
		}

		public function addAllChecksToBatch() : void 
		{
			new BatchListEvent( BatchListEvent.ADD_CHECKS_TO_NEW_BATCH, checkList.toArray() ).dispatch();
		}
		
		public function sortChecks( orderField : String, order : String = null) : void 
		{
			if(orderField)
				_model.batch.checkListOrderField = orderField;
			if(order)
				_model.batch.checkListOrder = order;
			else
			{
				if(_model.batch.checkListOrder == "DESC")
					_model.batch.checkListOrder = "ASC";
				else
					_model.batch.checkListOrder = "DESC";
			}
			
			new BatchEvent(BatchEvent.GET_CHECK_LIST).dispatch();
		}
		
		public function searchCheckList( option : Object, value : String ) : void
		{
			value = value.replace("$", "");
			value = value.replace(",", "");			
			
			_model.batch.checkListSearchOption = { column: option.value, type: option.type, value : value };
			getCheckList();
		}
		
		public function clearSearch() : void
		{
			_model.batch.checkListSearchOption = null;
			getCheckList();
		}

		private function checkListUpdated(checkList:ArrayCollection):void
		{
			this.checkList = checkList;
			dispatchEvent(new Event("updateTitle"));
		}

		override protected function setUpWatchers():void
		{
			addWatcher( BindingUtils.bindSetter(checkListUpdated, _model, ["batch","checkList"] ), "checkList" );
			addWatcher( BindingUtils.bindProperty(this, "checkListTotal", _model, ["batch","checkListTotal"] ), "checkListTotal" );
			addWatcher( BindingUtils.bindProperty(this, "checkListLoading", _model, ["batch", "checkListLoading" ] ), "checkListLoading" );
		}

		[Bindable(event="modelChanged")]
		private var _model:EAModelLocator;
	}
}