--Hummech House
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon: 2+ Level 1 Winged Beast/Insect monsters
	Xyz.AddProcedure(c,s.matfilter,1,2,nil,nil,Xyz.InfiniteMats)
	c:EnableReviveLimit()
	--If Xyz Summoned: detach all materials; apply effects by this card's Type(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON
		+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xyzcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id}

function s.matfilter(c,xyzc)
	return c:IsLevel(1) and c:IsRace(RACE_WINGEDBEAST|RACE_INSECT)
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetOverlayCount()>0 end
	c:RemoveOverlayCard(tp,c:GetOverlayCount(),c:GetOverlayCount(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.thfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_WINGEDBEAST|RACE_INSECT) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp,code)
	return c:IsLevel(1) and c:IsRace(RACE_WINGEDBEAST|RACE_INSECT) and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--The bullets are not a choice: every one whose Type this card currently has
--applies, in printed order. Machine is its printed Type; Winged Beast and
--Insect arrive from Techneas' and Rescuer's material-inheritance grants, which
--is what makes a tri-type House pay off three times.
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	--Machine: add 1, then optionally Special Summon 1 with a different name
	if c:IsRace(RACE_MACHINE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			local code=tc:GetCode()
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,code)
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,code)
				if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
			end
		end
	end
	--Winged Beast: gain 1000 DEF, also recover 1 Level 1 Winged Beast in the End Phase
	if c:IsRace(RACE_WINGEDBEAST) then
		s.gainstat(c,EFFECT_UPDATE_DEFENSE,1000,aux.Stringid(id,1))
		s.regrecover(c,tp,RACE_WINGEDBEAST,aux.Stringid(id,2))
	end
	--Insect: gain 2000 ATK, also recover 1 Level 1 Insect in the End Phase
	if c:IsRace(RACE_INSECT) then
		s.gainstat(c,EFFECT_UPDATE_ATTACK,2000,aux.Stringid(id,3))
		s.regrecover(c,tp,RACE_INSECT,aux.Stringid(id,5))
	end
end
function s.gainstat(c,code,amount,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(desc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(code)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(amount)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.regrecover(c,tp,race,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(desc)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(race)
	e1:SetOperation(s.eprecop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.recfilter(c,race)
	return c:IsLevel(1) and c:IsRace(race) and c:IsAbleToHand()
end
function s.eprecop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	if not Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE,0,1,nil,race) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.recfilter,tp,LOCATION_GRAVE,0,1,1,nil,race)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
