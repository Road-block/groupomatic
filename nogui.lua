if not GOMatic then
	GrOM.guiUnloaded = true
	local f = CreateFrame("Frame", "GOMatic")
	GrOM.OnLoad(f)
	f:SetScript("OnEvent", GrOM.OnEvent)
	function GrOM.UpdateButtons()end
	function GrOM.UpdateSavesPane()end
	function GrOM.GetCurrentRestoreMethod()end
	GrOM.LoadGUIFunctions = nil
else
	GrOM.LoadGUIFunctions()
	GrOM.LoadGUIFunctions = nil
end
