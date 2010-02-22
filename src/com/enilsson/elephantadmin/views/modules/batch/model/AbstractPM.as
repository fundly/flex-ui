package com.enilsson.elephantadmin.views.modules.batch.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.binding.utils.ChangeWatcher;
	
	[Bindable]
	public class AbstractPM extends EventDispatcher
	{
		// Array of changewatchers
		protected var watchers:Object = {};

		// Array of AbstractPMs
		protected var children:Array = [];
		
		// Reference to the domain model
		protected var _domainModel:IModelLocator;

		private var _isFirstShow:Boolean = true;

		public function AbstractPM( domainModel : IModelLocator, target : IEventDispatcher = null )
		{
			super(target);
			this.domainModel = domainModel;
			createChildren();
		}

		protected function createChildren():void
		{
			
		}

		public function set domainModel( domainModel : IModelLocator ):void
		{
			_domainModel = domainModel;
			resetWatchers();

			// Notify all children of the new domainModel
			for each(var child:AbstractPM in children)
			{
				child.domainModel = domainModel;
			}
		}
		public function get domainModel():IModelLocator
		{
			return _domainModel;
		}

		protected final function resetWatchers() : void
		{
			clearWatchers();
			setUpWatchers();
		}

		protected function clearWatchers() : void
		{
			// unwatch and delete reference to watchers to for GC
			for(var name:String in watchers)
			{
				if( watchers.hasOwnProperty(name) && watchers[name] )
					ChangeWatcher(watchers[name]).unwatch();
			}
			watchers = [];
		}

		/**
		 *  Function to be overridden with list of bindings
		 */ 
		protected function setUpWatchers() : void
		{
			
		}
		
		protected function addWatcher(watcher:ChangeWatcher, name:String) : void
		{
			if(watcher != null && name != null) {
				removeWatcherByName( name );
				watchers[name] =  watcher;
			}
		}

		protected function removeWatcherByName(name:String) : void
		{
			if(name != null && watchers.hasOwnProperty(name) )
			{
				ChangeWatcher(watchers[name]).unwatch();
				delete watchers[name];
			}
		}

		public function getWatcherNames():Array
		{
			var names:Array = [];
			for(var name:String in watchers)
			{
				names.push(name);
			}
			return names;
		}

		public function set currentState(value:String):void
		{
			_currentState = value;
			for each(var child:AbstractPM in children)
			{
				child.currentState = _currentState;
			}
		}
		public function get currentState():String
		{
			return _currentState;
		}
		private var _currentState:String;

		public function addChild( pm : AbstractPM ) : void
		{
			children.push( pm );
		}

		public function removeChild( pm : AbstractPM ) : void
		{
			children.splice( children.indexOf( pm ) ,1 );
		}

		public function showHandler() : void
		{
			if(_isFirstShow = true )
			{
				firstShowHandler();
				return;
			}
		}

		public function firstShowHandler(): void
		{
			_isFirstShow = false;
		}
	}
}