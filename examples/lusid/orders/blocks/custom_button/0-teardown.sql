/*

---------------------------
Custom Button Teardown
---------------------------

Description:

-- This query deletes the custom action view created in 2-create-custom-button.sql
-- Wait 5 seconds after delete before running 
-- This give the view time to reset on the Luminesce grid

More details:

    https://github.com/finbourne/luminesce-examples/blob/master/examples/view-management/7-delete-a-view.sql

*/


@@providerName = select 'order_blotter_custom_action_example.Set_contingent_order_id';

@delete_model_portfolios_view = use Sys.Admin.SetupView with @@providerName
--provider={@@providerName}
--deleteProvider
----

select 1 as deleting_view

enduse;

select * from @delete_model_portfolios_view;