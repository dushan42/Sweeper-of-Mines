local model = Self_GetComponent("Model")

function OnFlag(message)

	Model_SetIsVisible(model, message.value)
	
end
