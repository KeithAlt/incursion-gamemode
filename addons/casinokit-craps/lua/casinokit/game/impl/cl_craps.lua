local a=CasinoKit.L;local b=CasinoKit.class("CrapsCl","CardGameCl")function b:getGameFriendlyName()return"Craps"end;function b:getGameFriendlySubtext()return a("craps_minbet",{amount=self:getMinBet()})end;function b:getMinBet()local c=self:getTableEntity()return IsValid(c)and c:GetMinBet()or 5 end;function b:getRollInterval()local c=self:getTableEntity()return IsValid(c)and c:GetRollInterval()or 5 end;function b:addGameSettings(d)d:integer("Minimum bet","minbet",self:getMinBet(),5,10000)d:integer("Roll intervals","rollinterval",self:getRollInterval(),5,180)b.super.addGameSettings(self,d)end;b.htmlHelp=[[
<h2>Craps rules</h2>
<p>
	Click <a href="javascript:openRules()">here</a> to open Craps rules.
</p>
<script>
	function openRules() {
		gmod.OpenUrl('https://en.wikipedia.org/wiki/Craps#Bank_craps')
	}
</script>
]]