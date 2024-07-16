if not GOMatic then
	GrOM.guiUnloaded = true
	local f = CreateFrame("Frame", "GOMatic", UIParent, "BackdropTemplate")
	f:SetBackdrop(BACKDROP_TUTORIAL_16_16)
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
