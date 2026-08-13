--Dragonflymech Carrier
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Contact Fusion: return 5 Level 1/Rank 1/Link 1 Winged Beast/Insect
	--monsters you control, in your GY or banished, to the Deck or Extra Deck
	Fusion.AddProcFunRep(c,s.matfilter,5,true)
	Fusion.AddContactProc(c,Aerol8.CarrierMaterials,Aerol8.CarrierConsume,s.splimit)
	--If Fusion Summoned: apply effects by this card's Type(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ANNOUNCE+CATEGORY_TODECK+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.fusioncon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id}

--Fusion Material requirement: 5 Level 1/Rank 1/Link 1 monsters, any Type.
--The contact route narrows this further on its own, because its material pool
--(Aerol8.CarrierMaterials) is already restricted to Winged Beast and Insect --
--AddContactProc checks the pool against this same requirement.
function s.matfilter(c)
	return Aerol8.IsTier1(c)
end
--"Must be either Fusion Summoned, or Special Summoned by [the contact route]."
--Fusion Summons out of the Extra Deck are allowed; any other Special Summon is
--only allowed from outside the Extra Deck, i.e. revival after a proper Summon.
--The contact procedure bypasses EFFECT_SPSUMMON_CONDITION entirely.
--Mirrors Blue-Eyes Twin Burst Dragon (2129638).
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
		or e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
--Fires for BOTH routes. A contact fusion is summoned through
--EFFECT_SPSUMMON_PROC, which yields a plain Special Summon rather than
--SUMMON_TYPE_FUSION, so testing the summon type would silently miss it.
--Leaving the Extra Deck is the test that covers a real Fusion Summon and the
--contact route alike, while excluding revival from the GY.
function s.fusioncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end

--Bullets apply in printed order for every Type this card currently has. Note
--Machine appears twice: it declares first and shuffles last, so a plain
--Machine Carrier declares one name and shuffles it, while a tri-type Carrier
--declares three names before the shuffle.
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local names={}
	if c:IsRace(RACE_MACHINE) then
		table.insert(names,Duel.AnnounceCard(tp))
	end
	if c:IsRace(RACE_WINGEDBEAST) then
		s.gainstat(c,EFFECT_UPDATE_DEFENSE,2000,aux.Stringid(id,1))
		table.insert(names,Duel.AnnounceCard(tp))
	end
	if c:IsRace(RACE_INSECT) then
		s.gainstat(c,EFFECT_UPDATE_ATTACK,1000,aux.Stringid(id,2))
		table.insert(names,Duel.AnnounceCard(tp))
	end
	--Final Machine bullet: shuffle every card with a declared name during the
	--End Phase, from the field, either GY, or banishment.
	if c:IsRace(RACE_MACHINE) and #names>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetCategory(CATEGORY_TODECK)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(names)
		e1:SetOperation(s.epshuffleop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
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
function s.namefilter(c,names)
	if not c:IsAbleToDeck() then return false end
	for _,code in ipairs(names) do
		if c:IsCode(code) then return true end
	end
	return false
end
function s.epshuffleop(e,tp,eg,ep,ev,re,r,rp)
	local names=e:GetLabelObject()
	if not names then return end
	local g=Duel.GetMatchingGroup(s.namefilter,tp,
		LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,
		LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,nil,names)
	if #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
