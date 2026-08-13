--Ultimech Locator "AI-ers"
--Aerol-8 / "mech" custom set
Duel.LoadScript("aerol8_common.lua")
local s,id=GetID()
function s.initial_effect(c)
	Aerol8.InstallTrackers()
	--(Quick Effect) If a monster effect has been activated this turn: add 1
	--"Aerol" Spell/Trap from your Deck or GY to your hand, then either Special
	--Summon or discard this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	--Hard once per turn. Without it copies chain each other indefinitely: the
	--condition is satisfied by the previous copy's own activation, and it
	--recurs "Aerol" cards out of the GY, so the loop never runs dry.
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_AEROL}

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Aerol8.MonsterEffectActivated()
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_AEROL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	Aerol8.DiscardOrSummon(e,tp,{discard=aux.Stringid(id,2),summon=aux.Stringid(id,1)})
end
