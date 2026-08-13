--Mothmech Disrupter "Ein"
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	--(Quick Effect) When a Level 1 monster activates a Special Summoning
	--effect: discard or Special Summon this card, then Special Summon that
	--monster to your field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.stealcon)
	e1:SetTarget(s.stealtg)
	e1:SetOperation(s.stealop)
	c:RegisterEffect(e1)
	--If Special Summoned while you control a Machine: shuffle 1 card from the
	--GYs to the Deck during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.machinecon)
	e2:SetTarget(s.regtg)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
s.listed_names={id}

--"that monster" is the monster that ACTIVATED the effect, not the one it would
--summon. That is what makes the timing work: as a Quick Effect this resolves
--before the summoning effect does, so the activating monster is still sitting
--in a hand, GY or Deck where it can be Special Summoned -- and the original
--effect then fizzles for want of its card.
function s.stealcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsMainPhase() then return false end
	if not re:IsMonsterEffect() then return false end
	if re:GetCategory()&CATEGORY_SPECIAL_SUMMON==0 then return false end
	local rc=re:GetHandler()
	return rc:IsLevel(1)
end
function s.stealtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.stealop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Aerol8.DiscardOrSummon(e,tp,{discard=aux.Stringid(id,2),summon=aux.Stringid(id,3)})
	--Only if it is not already on the field: you cannot Special Summon
	--something that is already summoned.
	if rc and not rc:IsOnField() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and rc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP)
	end
	Aerol8.LockSpecialSummon(e:GetHandler(),tp,aux.Stringid(id,5))
end

function s.machinecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,nil)
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,6))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.eptdop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--The lock is tied to using either effect, not just the first.
	Aerol8.LockSpecialSummon(e:GetHandler(),tp,aux.Stringid(id,5))
end
function s.eptdop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
