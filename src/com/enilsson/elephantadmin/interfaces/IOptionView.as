package com.enilsson.elephantadmin.interfaces
{	
	import com.enilsson.elephantadmin.interfaces.IRecordModel;

	public interface IOptionView
	{
		function get label() : String;
		function set label( value : String ) : void;
		
		function get presentationModel():IRecordModel;
		function set presentationModel( value:IRecordModel ) : void;
	}
}