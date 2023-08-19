netstream.Hook("merchantUI", function(instance, template, id)
	vgui.Create("nutMerchant"):open(instance, template, id)
end)

netstream.Hook("merchantTemplateUI", function(templates)
	vgui.Create("nutMerchantTemplateEditor"):open(templates)
end)

netstream.Hook("merchantInstanceUI", function(instance, data, entity)
	vgui.Create("nutMerchantInstanceEditor"):open(instance, data, entity)
end)

netstream.Hook("nutMerchantMessage", function(text, err)
	if (nut.gui.merchant) then
		nut.gui.merchant:message(text, err)
	end;
end)
