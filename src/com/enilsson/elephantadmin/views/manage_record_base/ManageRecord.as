package com.enilsson.elephantadmin.views.manage_record_base
{
	import com.enilsson.elephantadmin.interfaces.IOptionView;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModel;
	import com.enilsson.elephantadmin.views.manage_record_base.model.RecordModuleConfiguration;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.containers.Canvas;
	import mx.core.IFactory;
	import mx.effects.Move;
	import mx.events.StateChangeEvent;
	import mx.states.SetStyle;
	import mx.states.State;
	import mx.states.Transition;

	public class ManageRecord extends Canvas
	{
		protected var searchGrip:ModuleGrip;
		protected var optionsGrip:ModuleGrip;
		protected var searchBox:SearchBox;
		protected var optionsBox:OptionsBox;
		protected var recordPanel:RecordPanel;

		private var showSearch:State;
		private var showOptions:State;
		private var slideTransition:Transition;

		[Embed (source="/assets/images/admin_panel/magnifier_small.png")]
		private static var SEARCHGRIP_ICON:Class;

		[Embed (source="/assets/images/admin_panel/options_small.png")]
		private static var OPTIONSGRIP_ICON:Class;

		public function ManageRecord()
		{
			super();

			verticalScrollPolicy = 'off';
			addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, stateChangeHandler);
		}


		/**
		 * Set the module configuration by passing in the parameters to the presentation model
		 */
		[Bindable]
		public function get presentationModel() : RecordModel { return _presentationModel; }
		public function set presentationModel( model:RecordModel ) : void
		{
			if(model && model != _presentationModel)
			{
				_presentationModel = model;
				
				if( ! _pmWatcher )
					_pmWatcher = BindingUtils.bindProperty(this, 'currentState', _presentationModel, "viewState");	
				else
					_pmWatcher.reset(presentationModel);
					
				passPresentationModel();
			}
		}
		private var _presentationModel : RecordModel;
		private var _pmWatcher : ChangeWatcher;

		public function configuration(value:RecordModuleConfiguration):void
		{
			presentationModel.configure( value );
		}

		/**
		 * Set the itemRenderer to pass through the search box
		 */
		[Bindable] private var _searchListItemRenderer:IFactory;
		public function set searchListItemRenderer ( value:IFactory ):void
		{
			_searchListItemRenderer = value;
		}

		public function get searchListItemRenderer ():IFactory
		{
			return _searchListItemRenderer;
		}

		override protected function createChildren():void
		{
			if( !searchGrip )
			{
				searchGrip = new ModuleGrip();
				searchGrip.styleName = 'grip';
				searchGrip.label = 'SEARCH';
				searchGrip.icon = SEARCHGRIP_ICON;
				searchGrip.toolTip = 'Show the search list';
				searchGrip.mouseChildren = false;
				this.addChild(searchGrip);

				searchGrip.addEventListener(MouseEvent.CLICK, searchGripClickHandler);
			}

			if( !optionsGrip )
			{
				optionsGrip = new ModuleGrip();
				optionsGrip.styleName = 'grip';
				optionsGrip.label = 'OPTIONS';
				optionsGrip.icon = OPTIONSGRIP_ICON;
				optionsGrip.toolTip = 'Show the record options';
				optionsGrip.mouseChildren = false;
				this.addChild(optionsGrip);

				optionsGrip.addEventListener(MouseEvent.CLICK, optionsGripClickHandler);
			}

			if( !optionsBox )
			{
				optionsBox = new OptionsBox();
				optionsBox.styleName = 'optionsBox';
				this.addChild( optionsBox );
			}

			if( !searchBox )
			{
				searchBox = new SearchBox();
				searchBox.styleName = 'searchBox';
				this.addChild( searchBox );

				searchBox.addEventListener(SearchBox.ADD_RECORD, addRecordClickHandler);
			}

			if( !recordPanel )
			{
				recordPanel = new RecordPanel();
				recordPanel.styleName = 'recordPanel';
				this.addChild( recordPanel );
			}

			this.initialiseStates();

			super.createChildren();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
		}

		override protected function measure():void
		{
			super.measure();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			searchGrip.width = 25;
			searchGrip.percentHeight = 100;
			searchGrip.x = 0;
			searchGrip.y = 0;

			optionsGrip.width = 25;
			optionsGrip.percentHeight = 100;
			optionsGrip.x = width - 25;
			optionsGrip.y = 0;

			searchBox.width = this.getExplicitOrMeasuredWidth() / 2 - 40;
			searchBox.percentHeight = 100;
			searchBox.y = 0;
			searchBox.x = 32;

			searchBox.itemRenderer = _searchListItemRenderer;

			optionsBox.width = this.getExplicitOrMeasuredWidth() / 2 - 40;
			optionsBox.percentHeight = 100;
			optionsBox.y = 0;
			optionsBox.x = width - optionsBox.width - 32;

			recordPanel.width = this.getExplicitOrMeasuredWidth() / 2 - 27;
			recordPanel.minWidth = 485;
			recordPanel.height = height + 1;
			recordPanel.y = 0;
		}

		/**
		 * Override the existing addChild function to add any mxml children directly to the options box
		 */
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if(child is IOptionView)
				this.optionsBox.addChild( child );
			else
				super.addChild(child);

			return child;
		}

		/**
		 * Initialise the states and transitions for this module once the children have been created
		 */
		private function initialiseStates():void
		{
			showSearch = new State();
			showSearch.name = 'showSearch';
			
			var movePanelRight:SetStyle = new SetStyle( recordPanel, 'right', 27 );
			showSearch.overrides = [ movePanelRight ];
			
			showOptions = new State();
			showOptions.name = 'showOptions';
			
			var movePanelLeft:SetStyle = new SetStyle( recordPanel, 'left', 27 );
			showOptions.overrides = [ movePanelLeft ];
			
			this.states = [showSearch, showOptions];
			
			slideTransition = new Transition();

			var move:Move = new Move(recordPanel);
			move.duration = 600;

			slideTransition.effect = move;

			this.transitions = [slideTransition];
		}
		
		private function passPresentationModel():void
		{
			searchBox.presentationModel = this.presentationModel;
			optionsBox.presentationModel = this.presentationModel;
			recordPanel.presentationModel = this.presentationModel;
		}

		private function searchGripClickHandler ( event:MouseEvent ):void
		{
			presentationModel.viewState = 'showSearch';
		}
		
		private function optionsGripClickHandler ( event:MouseEvent ):void
		{
			presentationModel.viewState = 'showOptions';
		}

		private function addRecordClickHandler ( event:Event ):void
		{
			presentationModel.addNewRecord();
		}

		private function stateChangeHandler ( event:StateChangeEvent ):void
		{
			searchGrip.currentState = event.newState == 'showOptions' ? 'off' : 'on';
			optionsGrip.currentState = event.newState == 'showSearch' ? 'off' : 'on';
		}
	}
}