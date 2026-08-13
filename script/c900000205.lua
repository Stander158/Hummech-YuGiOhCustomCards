--Dragonflymech Attachment
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a Level 1/Rank 1/Link 1 monster
	aux.AddEquipProcedure(c,nil,Aerol8.IsTier1Faceup)
	--The equipped monster gains 500 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--If it is an Insect, you take no battle damage from battles involving it
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetCondition(s.insectcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Sent to the GY because the equipped monster left the field: during the
	--End Phase, add 1 "Dragonflymech" monster from your Deck or GY, then
	--optionally mill 1
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.regtg)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_DRAGONFLYMECH}

function s.insectcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec~=nil and ec:IsRace(RACE_INSECT)
end
--This used to hang a flag effect off EVENT_LEAVE_FIELD and read it back in the
--End Phase, and it never fired. Two reasons: by the time the equip target has
--left, GetEquipTarget() is already nil, so the flag was never registered; and a
--flag set on a card on its way out does not survive into the GY, where it is a
--new card. REASON_LOST_TARGET is the engine's own reason for an Equip Spell
--going to the GY because it lost its target, which is exactly the condition.
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_LOST_TARGET)
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
--Registers the End Phase payout, the same delayed pattern the rest of the set
--uses, rather than trying to keep state on a card that has changed location.
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	return c:IsSetCard(SET_DRAGONFLYMECH) and c:IsMonster() and c:IsAbleToHand()
end
function s.tgfilter(c)
	return c:IsLevel(1) and c:IsMonster() and c:IsAbleToGrave()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	--"You can add": minimum of 0 so declining is allowed.
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,0,1,nil)
	if #g==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #tg>0 then Duel.SendtoGrave(tg,REASON_EFFECT) end
	end
end
